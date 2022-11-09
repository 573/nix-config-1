{ inputs, rootPath, forEachSystem }:

let
  pkgsFor = forEachSystem (system: import ./nixpkgs.nix { inherit inputs rootPath system; });

  pkgsNixOnDroidFor = forEachSystem (system: import ./nixpkgs.nix { inherit inputs rootPath system; nixOnDroid = true; });

  customLibFor = forEachSystem (system: import "${rootPath}/lib" {
    pkgs = pkgsFor.${system};
  });

  homeModulesFor = forEachSystem (system:
    [
      {
        _file = ./default.nix;
        lib.custom = customLibFor.${system};
      }
    ]
    ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/home"
  );

  wrapper = builder: system: name: args:
    inputs.nixpkgs.lib.nameValuePair
      name
      (import builder {
        inherit inputs rootPath system pkgsFor pkgsNixOnDroidFor customLibFor homeModulesFor name args;
      });

  simpleWrapper = builder: system: name: wrapper builder system name { };
in

{
  mkNixOnDroid = simpleWrapper ./builders/mkNixOnDroid.nix;

  mkApp = wrapper ./builders/mkApp.nix;
}
