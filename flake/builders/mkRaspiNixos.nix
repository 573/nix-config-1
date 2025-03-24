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
  inherit (pkgsFor.${system}.lib) removeSuffix hasSuffix;
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
    "${rootPath}/hosts/${if hasSuffix "vm" name then (removeSuffix "vm" name) else name}/configuration.nix"
    "${rootPath}/hosts/${if hasSuffix "vm" name then (removeSuffix "vm" name) else name}/hardware-configuration.nix"

    {
      _file = ./mkRaspiNixos.nix;

      custom.base.general.hostname = if hasSuffix "vm" name then (removeSuffix "vm" name) else name;

      lib.custom = customLibFor.${system};

      nixpkgs.pkgs = pkgsFor.${system};
    }
  ] ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/nixos";
}
