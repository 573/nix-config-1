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

  PGDATA = "${toString ./.pgdata}";

  shellHook = ''
    set -o errexit -o noclobber -o nounset

    # Remove traces of running server when exiting this shell hook
    cleanup() {
      pg_ctl stop
      # comment to keep db files
      rm --force --recursive "$PGDATA"
    }
    trap cleanup EXIT

    # Create database cluster
    initdb --auth-local=trust --auth-host=trust

    # Start server
    pg_ctl --log="$PGDATA/db.log" --options="-c unix_socket_directories='$PGDATA'" start

    # Create test database
    db_name=test
    createdb "$db_name" --host="$PGDATA"

    # Enable pgTAP
    psql --command="CREATE EXTENSION pgtap" --dbname="$db_name" --host="$PGDATA"

    # Connect to database
    psql --dbname="$db_name" --host="$PGDATA"

    # Return from Bash after exiting psql
    exit
  '';
}
