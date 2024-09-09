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

  /**

  # Example

  ```nix
  mkApp = wrapper ./builders/mkApp.nix
  ```

  A function (i. e. `mkApp` or `mkHome`) declared like that might be called like:

  ```nix
  mkHome "x86_64-linux" "dani@maiziedemacchiato"  	
  ```

  # Arguments

  - [builder] Path of a nix file
  - [system] String describing the system to build attribute set for (i. e. `"aarch64-linux"`)
  - [name] String to name the config for example i. e. `dani@maiziedemacchiato`, see `homeConfigurations` in flake.nix
  - [args] Attribute set of further arguments
  */
  wrapper = builder: system: name: args:
    inputs.nixpkgs.lib.nameValuePair
      name
      (import builder {
        inherit inputs rootPath system pkgsFor pkgsNixOnDroidFor customLibFor homeModulesFor name args;
      });

  /**
  wraps `wrapper` simplified in a manner that `wrapper`'s parameter `args` is an empty attribute set (`{}`)
  */
  simpleWrapper = builder: system: name: wrapper builder system name { };
in

{
  mkHome = simpleWrapper ./builders/mkHome.nix;
  mkNixOnDroid = simpleWrapper ./builders/mkNixOnDroid.nix;
  mkNixos = simpleWrapper ./builders/mkNixos.nix;

  mkApp = wrapper ./builders/mkApp.nix;
  mkDevenvJvmLang = wrapper ./builders/mkDevenvJvmLang.nix;
  mkDevenvDeno = wrapper ./builders/mkDevenvDeno.nix;
  mkDevenvFlutter = wrapper ./builders/mkDevenvFlutter.nix;
  mkDevenvRuby = wrapper ./builders/mkDevenvRuby.nix;
  mkDevenvHaskell = wrapper ./builders/mkDevenvHaskell.nix;
  mkDevenvOcaml = wrapper ./builders/mkDevenvOcaml.nix;
  mkDevenvRust = wrapper ./builders/mkDevenvRust.nix;
  mkDevenvRustWasm32 = wrapper ./builders/mkDevenvRustWasm32.nix;
  mkDevenvMachnix = wrapper ./builders/mkDevenvMachnix.nix;
  mkDevenvJulia = wrapper ./builders/mkDevenvJulia.nix;
  mkDevenvJupyenv = wrapper ./builders/mkDevenvJupyenv.nix;
}
