{ inputs, rootPath }:

let
  homeModulesBuilder = { inputs, rootPath, customLib, ... }:
    [
      {
        lib.custom = customLib;
      }
    ]
    ++ customLib.getRecursiveNixFileList (rootPath + "/home");

  wrapper = builder: system: name: args:
    let
      flakeArgs = { inherit inputs rootPath system; };
      perSystem = import ./per-system.nix flakeArgs;

      homeModules = homeModulesBuilder (flakeArgs // perSystem);

      builderArgs = flakeArgs // perSystem // { inherit args homeModules name; };
    in
    inputs.nixpkgs.lib.nameValuePair name (import builder builderArgs);

  simpleWrapper = builder: system: name: wrapper builder system name { };
in

{
  mkNixOnDroid = simpleWrapper ./builders/mkNixOnDroid.nix;

  eachSystem = builderPerSystem:
    inputs.flake-utils.lib.eachSystem
      [ "aarch64-linux" ]
      (system:
        builderPerSystem {
          inherit system;
          mkApp = wrapper ./builders/mkApp.nix system;
          mkCheck = wrapper ./builders/mkCheck.nix system;
        }
      );
}
