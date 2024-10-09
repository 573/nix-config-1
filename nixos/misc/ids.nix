{ config, lib, ... }:

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
      enable = mkEnableOption "custom uids and gids" // {
        default = true;
      };

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
        #syncthing = 237;

        # WORKAROUND After first installation needs fix bc had uid 1000 earlier, see https://github.com/NixOS/nixpkgs/issues/12170
        # i. e. uid 1000 gid 1000 or gid 100
        # https://github.com/nix-community/NixOS-WSL/pull/85
        # default user gets 1000 in modules/wsl-distro.nix
        # see nixos/base/nixoswsl.nix, line 
        # DONT keeping nixos user for now in NixOS-WSL
        #dkahlenberg = 1000;

        # https://github.com/nix-community/NixOS-WSL/blob/0fa9268bf9a903498cb567e6d4d01eb945f36f6e/modules/wsl-distro.nix#L120
        nixos = 1000;
        dani = 1001;
        #funktionstester = 1000;
      };

      gids = mapIds {
        #syncthing = 237;
        #	scanner = 444;

        # leaving users gids on users group's gid (100) as creating for each user a gid that is the same as it's uid and that's group name is the same as the user's name seems highly redundant
        # Thus DONT i. e. nixos = 1000;: see https://unix.stackexchange.com/questions/319729/recommended-gid-for-users-group-in-linux-100-or-1000
        # WIP testing it in case resources are indeed only accessible for gid 1000
        nixos = 1000;
      };
    };

  };

}
