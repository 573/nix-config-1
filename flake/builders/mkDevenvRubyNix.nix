{
  system,
  rootPath,
  pkgsInsecFor,
  name,
  ...
}:

let
  pkgs = pkgsInsecFor.${system};

  ruby = pkgs."ruby-2.4.0";

  gems = pkgs.bundlerEnv {
    name = "gemset";
    inherit ruby;
    gemfile = "${rootPath}/home/misc/Gemfile";
    lockfile = "${rootPath}/home/misc/Gemfile.lock";
    # TODO Find out, why moving the generated gemset.nix to some other folder does not work
    gemset = "${rootPath}/flake/builders/gemset.nix";
    groups = [
      "default"
      "production"
      "development"
      "test"
    ];
  };
in
pkgs.mkShell {
  buildInputs = builtins.attrValues {
    inherit
      gems
      ruby
      ;
    inherit (pkgs)
      bundix
      ;
  };

  shellHook = ''
    chmod +x ${rootPath}/home/misc/britta-filter.rb
    ${rootPath}/home/misc/britta-filter.rb
  '';
}
