{
  inputs,
  rootPath,
  system,
  pkgsNixOnDroidFor,
  customLibFor,
  homeModulesFor,
  name,
  ...
}:

let
  inherit (pkgsNixOnDroidFor.${system}) lib;
  inherit (pkgsNixOnDroidFor.${system}.stdenv) isLinux isAarch64;
in

inputs.nix-on-droid.lib.nixOnDroidConfiguration {
  pkgs = pkgsNixOnDroidFor.${system};
  modules = [
    "${rootPath}/hosts/${name}/nix-on-droid.nix"

    {
      _file = ./mkNixOnDroid.nix;

      options.lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = { };
        description = ''
          This option allows modules to define helper functions,
          constants, etc.
        '';
      };

      config.lib.custom = customLibFor.${system};
    }
  ];

  extraSpecialArgs = {
    inherit inputs rootPath;
    unstable = inputs.unstable.legacyPackages.${system};
    homeModules = homeModulesFor.${system};
  };
}
