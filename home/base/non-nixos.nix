{ config, lib, pkgs, inputs, ... }@configArgs:

let
  inherit (lib)
    concatStringsSep
    mkAfter
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.base.non-nixos;

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{

  ###### interface

  options = {

    custom.base.non-nixos = {
      enable = mkEnableOption "config for non NixOS systems";

      installNix = mkEnableOption "nix installation" // { default = true; };


      builders = mkOption {
        type = types.listOf types.string;
        default = [ ];
        description = "Nix remote builders.";
      };
    };


  };


  ###### implementation

  config = mkIf cfg.enable {

    home = {
      packages = mkIf cfg.installNix [ config.nix.package ];
      sessionVariables.NIX_PATH = concatStringsSep ":" commonConfig.nix.nixPath;
      sessionVariables =
        #let
        #  # TODO see https://github.com/Gerschtli/nix-config/commit/e96975f6c86e4f96ca919488ed1a396177b0ae2a
        #  # -        "/nix/var/nix/profiles/per-user/${config.home.username}/home-manager"
        #  # +        "/home/${config.home.username}/.local/state/nix/profiles/home-manager"
        #  profiles = [ "/nix/var/nix/profiles/default" "$HOME/.nix-profile" ];
        #  dataDirs =
        #    lib.concatStringsSep ":" (map (profile: "${profile}/share") profiles);
        #in
        {
          #XDG_DATA_DIRS = "${dataDirs}\${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS";
          #MANPAGER = "less -FirSwX";
        };
    };

    nix = {
      settings = {
        inherit (commonConfig.nix.settings)
          experimental-features
          flake-registry
          log-lines
          substituters
          trusted-public-keys
          ;

        builders = concatStringsSep ";" cfg.builders;
        builders-use-substitutes = mkIf (cfg.builders != [ ]) true;
        trusted-users = [ config.home.username ];
      };

      inherit (commonConfig.nix)
        package
        registry
        ;
    };

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

    targets.genericLinux.enable = true;
  };

}
