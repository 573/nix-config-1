{ #self
#, nixpkgs
#, config
#, lib
  pkgs
, depPkgs
, inputs
, ...
}#@inputs
:
{
  # TODO is hostname the entry in ssh config or the output of hostname command ?
  hostname = "smartphone";
  profiles.system = {
    user = "nix-on-droid";
    sshUser = "nix-on-droid";
    # TODO nix-store not found, but ssh smartphone -vv works now: $SSH_TTY is set
    sshOpts = [ "-v" ]; # https://github.com/serokell/deploy-rs/issues/292 [ "-oControlMaster=no" ];
    # i. e. super.stdenv.targetPlatform.system
    # NOTE pkgs is here a set where the it is deployed to, deploy-rs has to come from a set where the deploy tool comes from
    # path = inputs.deploy-rs.lib.x86_64-linux.activate.custom inputs.latest.legacyPackages.aarch64-linux.hello "./bin/hello";
    #path = pkgs.deploy-rs.lib.activate.custom                  pkgs.hello                                        "./bin/hello";
    #path = depPkgs.deploy-rs.lib.activate.custom pkgs.ipfetch "./bin/ipfetch";
    # TODO it is crucial to find here out the correct arch still see also https://github.com/bbigras/nix-config/blob/9d1c904/nix/deploy.nix
    path = inputs.deploy-rs.lib.x86_64-linux.activate.custom pkgs.tealdeer "./bin/tealdeer";
    #path = pkgs.deploy-rs.lib.activate.custom                  inputs.latest.legacyPackages.aarch64-linux.hello "./bin/hello";
  };
}
/*
let
  activateNixOnDroid =
    configuration:
    deploy-rs.lib.aarch64-linux.activate.custom
      configuration.activationPackage
      "${configuration.activationPackage}/activate";
in
{
deploy.nodes = {
  "sams9" = {
    hostname = "sams9"; # Replace with your device's hostname or IP (I use `dnsmaq` for local DNS)
    profiles.system = {
      sshUser = "nix-on-droid";
      user = "nix-on-droid";
      magicRollback = true;
      sshOpts = [ "-p" "8022" ]; # Adjust port if necessary (Step 1 dependent)
      path = activateNixOnDroid self.nixOnDroidConfigurations.sams9;
    };
  };
};

  };
}*/
