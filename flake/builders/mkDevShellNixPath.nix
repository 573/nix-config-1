{
  system,
  pkgsFor,
  inputs,
  name,
  #args,
  ...
}:

let
  pkgs = pkgsFor.${system};
  #jdk = args.jdk pkgs;
in

pkgs.mkShell {
  inherit name;

  shellHook = ''
    export NIX_PATH=${pkgs.lib.concatMapAttrsStringSep ":" (k: v: "${k}=${v}") inputs}
    '';
}
