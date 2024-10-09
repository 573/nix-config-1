{
  system,
  rootPath,
  pkgsFor,
  name,
  args,
  ...
}:

let
  pkgs = pkgsFor.${system};

  ignoringVulns = x: x // { meta = (x.meta // { knownVulnerabilities = [ ]; }); };

  ruby =
    (args.packageFromRubyVersionFile {
      file = "${rootPath}/home/misc/.ruby-version";

      inherit system;
    }).override
      {
        openssl = pkgs.openssl_1_1.overrideAttrs ignoringVulns;
      };

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
}
