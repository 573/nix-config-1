# https://paperless.blog/easy-postgresql-testing-with-pgtap-and-nix
# https://ipetkov.dev/blog/building-with-sqlx-on-nix/
# https://github.com/PostgREST/postgrest/blob/main/shell.nix

{
  args,
  system,
  pkgsFor,
  ghcpkgsFor,
  name,
  ...
}:
let
  pkgs = pkgsFor.${system};
  #postgrest = ghcpkgsFor.${system}.postgrest;
  unstable = args.unstable;
in
pkgs.mkShell {
  inherit name;
  packages = builtins.attrValues {
    postgresenv = pkgs.postgresql.withPackages (postgresqlPackages: builtins.attrValues {
      inherit
        (postgresqlPackages)
        pgtap
        ;
    });

    inherit
      (pkgs)
      bashInteractive
      jqp
      postgrest
      ;

    #inherit
    #  postgrest
    #  ;
  };

  # FIXME                  https://github.com/NixOS/nix/issues/5169 toString only works in repl
  #PGDATA = "$PWD/pgdata"; # "${toString ./.}/pgdata";

  shellHook = let
     db_name = "test";
     postgrestconf = "tutorial.conf";
     tokenwriter = pkgs.writeShellApplication {
	     name = "tokenwriter";
	     text = ''
    # Allow "tr" to process non-utf8 byte sequences
    export LC_CTYPE=C

    # Read random bytes keeping only alphanumerics and add the secret to the configuration file
    echo "jwt-secret = \"$(< /dev/urandom tr -dc A-Za-z0-9 | head -c32)\"" > ${postgrestconf}

    cat <<-EOF >> ${postgrestconf}
	db-uri = "postgres://authenticator:mysecretpassword@localhost:5432/${db_name}"
	db-schemas = "api"
	db-anon-role = "web_anon"
	db-pre-request = "${auth_check_token_fn}"
	EOF
		     '';
     };
     auth_check_token_fn = "auth.check_token";
  in ''
    set -o errexit -o noclobber -o nounset

    export PGDATA="$(pwd)/pgdata"

    ${tokenwriter}/bin/tokenwriter

    # Remove traces of running server when exiting this shell hook
    cleanup() {
      pg_ctl stop
      # comment to keep db files
      rm "$PGDATA" --force --recursive
      rm ${postgrestconf} --force
    }
    trap cleanup EXIT

    # Create database cluster
    initdb --auth-local=trust --auth-host=trust

    # Start server
    pg_ctl --log="$PGDATA/db.log" --options="-c unix_socket_directories='$PGDATA'" start

    # Create test database
    #db_name=${db_name}
    createdb "${db_name}" --host="$PGDATA"

    # Enable pgTAP
    psql --command="CREATE EXTENSION pgtap" --dbname="${db_name}" --host="$PGDATA"

    # https://stackoverflow.com/questions/10969953/how-to-output-a-multiline-string-in-bash?#comment127404278_10970616
    psql --dbname="${db_name}" --host="$PGDATA" -- << "END_OF_SQL"
    -- https://docs.postgrest.org/en/v12/tutorials/tut0.html
    \c ${db_name}

    create schema api;

    create table api.todos (
		    id int primary key generated by default as identity,
		    done boolean not null default false,
		    task text not null,
		    due timestamptz
		    );

    insert into api.todos (task) values ('finish tutorial 0'), ('pat self on back');

    create role web_anon nologin;

    grant usage on schema api to web_anon;
    grant select on api.todos to web_anon;

    create role authenticator noinherit login password 'mysecretpassword';
    grant web_anon to authenticator;

    -- https://docs.postgrest.org/en/v12/tutorials/tut1.html
    -- run this in psql using the database created
    -- in the previous tutorial

    create role todo_user nologin;
    grant todo_user to authenticator;

    grant usage on schema api to todo_user;
    grant all on api.todos to todo_user;

    create schema auth;
    -- https://jwt.io/ => payload "role":  "todo_user"
    grant usage on schema auth to web_anon, todo_user;

    create or replace function ${auth_check_token_fn}() returns void
	language plpgsql
	as $$
    begin
        --                          https://jwt.io/ => payload "email":  "disgruntled@mycompany.com"
        if current_setting('request.jwt.claims', true)::json->>'email' = 'disgruntled@mycompany.com' then
          raise insufficient_privilege
	    using hint = 'Nope, we are on to you';
        end if;
end
$$;
END_OF_SQL

    # https://dba.stackexchange.com/a/126510/52882,
    # IFS=''' read -r -d ''' returns non-zero on EOF, https://unix.stackexchange.com/a/622786/102072 for
    # what makes IFS=''' read -r -d ''' work in this case, still prefer cat
    VAR=$(psql -t --dbname="${db_name}" --host="$PGDATA" -c "select extract(epoch from now() + '5 minutes'::interval) :: integer;")

    # https://stackoverflow.com/a/1655389/3320256
    cat << EOF
    Put the following lines in JWT Encoder ("PAYLOAD: DATA") and secret in "Sign JWT: Secret":
    {
      "role": "todo_user",
      "exp": $VAR,
      "email": "disgruntled@mycompany.com"
    }
    Export the token returned in "JSON Web Token" as an env variable used when making the POST request
EOF

    echo "after postgrest tutorial setup"

    postgrest ${postgrestconf}

    # Connect to database
    psql --dbname="${db_name}" --host="$PGDATA"

    pg_ctl status

    # Return from Bash after exiting psql
    exit
  '';
}
