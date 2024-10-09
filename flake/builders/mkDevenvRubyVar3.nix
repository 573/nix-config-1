{
  system,
  rootPath,
  inputs,
  name,
  args,
  ...
}:

let
  pkgs = import args.nixpkgs {
    inherit system;
    config.permittedInsecurePackages = [
      "openssl-1.1.1w"
    ];
    overlays = [ args.nixpkgs-ruby-overlay ];
  };
  rubyNix = inputs.ruby-nix.lib pkgs;
  ruby = pkgs."ruby-2.4.0";
  # takes another pkgs set, not ours with custom config
  #ruby = packageFromRubyVersionFile {
  #    file = "${rootPath}/home/misc/.ruby-version";

  #    inherit system;
  #  };

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
pkgs.mkShell rec {
  inherit
    (rubyNix {
      inherit ruby;
      name = "old-ruby-app";
    })
    env
    ;

  buildInputs = builtins.attrValues {
    inherit env gems;
    inherit (pkgs) bundix;
  };
}
