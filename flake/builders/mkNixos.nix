{ inputs, rootPath, system, pkgsFor, customLibFor, homeModulesFor, name, ... }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  /**
  see ./../../flake.nix attribute `specialArgs` and `flakeLib`

  IDEA inject `specialArgs` there get from this functions (./mkNixos.nix) parameters and attach here via `// specialArgs`
  */
  specialArgs = {
    inherit inputs rootPath;
    homeModules = homeModulesFor.${system};
  };

  modules = [
    /**
    anything in `specialArgs` should be available via i. e. ./../../hosts/DANIELKNB1/configuration.nix function's parameters set, i. e. `{ ..., unstable, ... }:` when `unstable =` declared in `specialArgs`
    */
    "${rootPath}/hosts/${name}/configuration.nix"
    "${rootPath}/hosts/${name}/hardware-configuration.nix"

    /**
    IDEA: This is just an anonymous module, so it might be possible to prefix it with it's own parameter set, just as in 

    ```nix
    { inputs, rootPath, system, pkgsFor, customLibFor, homeModulesFor, name, <possibly other params>, ... }:
    {
      _file = ./mkNixos.nix;

      ...
    }
    ```

    What I don't know yet if this would just be redundant to just using ./mkNixos.nix's header ?
    */
    {
      _file = ./mkNixos.nix;

      custom.base.general.hostname = name;

      lib.custom = customLibFor.${system};

      nixpkgs.pkgs = pkgsFor.${system};
    }
  ]
  ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/nixos";
}
