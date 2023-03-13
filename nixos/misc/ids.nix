{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mapAttrs
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.custom.ids;

  mapIds = mapAttrs (_name: id: if cfg.enable then id else null);
in

{

  ###### interface

  options = {

    custom.ids = {
      enable = mkEnableOption "custom uids and gids" // { default = true; };

      uids = mkOption {
        type = types.attrs;
        readOnly = true;
        description = ''
          The user IDs used in custom NixOS configuration.
        '';
      };

      gids = mkOption {
        type = types.attrs;
        readOnly = true;
        description = ''
          The group IDs used in custom NixOS configuration.
        '';
      };
    };

  };


  ###### implementation

  config = {

    custom.ids = {
      uids = mapIds {
        # WORKAROUND After first installation needs fix bc had uid 1000 earlier, see https://github.com/NixOS/nixpkgs/issues/12170
        # i. e. uid 1000 gid 1000 or gid 100
        # https://github.com/nix-community/NixOS-WSL/pull/85
        # default user gets 1000 in modules/wsl-distro.nix
        # see nixos/base/nixoswsl.nix, line 
        dkahlenberg = 1000;
      };

      gids = mapIds { };
    };

  };

}
