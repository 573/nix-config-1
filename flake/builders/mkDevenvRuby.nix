{ system, rootPath, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};

  ruby = inputs.nixpkgs-ruby.lib.packageFromRubyVersionFile {
    file = "${rootPath}/home/misc/.ruby-version";
    inherit system;
  };

  gems = pkgs.bundlerEnv {
    name = "gemset";
    inherit ruby;
    gemfile = "${rootPath}/home/misc/Gemfile";
    lockfile = "${rootPath}/home/misc/Gemfile.lock";
    # TODO Find out, why moving the generated gemset.nix to some other folder does not work
    gemset = "${rootPath}/flake/builders/gemset.nix";
    groups = [ "default" "production" "development" "test" ];
  };
in
pkgs.mkShell {
  buildInputs = [
    gems
    ruby
    pkgs.bundix
  ];
}
