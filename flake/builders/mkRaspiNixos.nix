{
  inputs,
  rootPath,
  system,
  pkgsFor,
  customLibFor,
  homeModulesFor,
  name,
  ...
}:
let
  inherit (pkgsFor.${system}.stdenv) isLinux isAarch64;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  /**
    see ./../../flake.nix attribute `specialArgs` and `flakeLib`

    IDEA inject `specialArgs` there get from this functions (./mkNixos.nix) parameters and attach here via `// specialArgs`
  */
  specialArgs = {
    inherit inputs rootPath;
    homeModules = homeModulesFor.${system};
    #image = true;
  };

  modules = [
    /**
      anything in `specialArgs` should be available via i. e. ./../../hosts/DANIELKNB1/configuration.nix function's parameters set, i. e. `{ ..., unstable, ... }:` when `unstable =` declared in `specialArgs`
    */
    "${rootPath}/hosts/${name}/configuration.nix"
    "${rootPath}/hosts/${name}/hardware-configuration.nix"

    {
      _file = ./mkImage.nix;

      custom.base.general.hostname = name;

      lib.custom = customLibFor.${system};

      nixpkgs.pkgs = pkgsFor.${system};
    }
  ] ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/nixos";
}
