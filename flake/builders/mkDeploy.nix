{ inputs
, rootPath
, system
, pkgsFor
, name
, ...
}:

let
  # splits "username@hostname"
  splittedName = inputs.nixpkgs.lib.splitString "__" name;

  devicename = builtins.elemAt splittedName 0;
  deployerSystem = builtins.elemAt splittedName 1;

in
  /**
    see also ./../../lib/common-config.nix `homeManager.baseConfig.extraSpecialArgs` there and `homeManager.userConfig`
  */



import "${rootPath}/hosts/${devicename}/deploy.nix" { inherit inputs; pkgs = pkgsFor.${system}; depPkgs = pkgsFor.${deployerSystem}; }


/*
      {
        hostname = "localhost";
   	  profiles.system = {
            user = "nix-on-droid";
   	    sshUser = "nix-on-droid";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.custom inputs.latest.legacyPackages.aarch64-linux.hello "./bin/hello";
          };
      }
*/
