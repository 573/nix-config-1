{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib)
    attrNames
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.development.direnv;

  devShells = attrNames inputs.self.devShells.${pkgs.system};
in

{
  ###### interface

  options = {

    custom.development.direnv.enable = mkEnableOption "direnv setup";

  };

  ###### implementation

  config = mkIf cfg.enable {

#    home.packages = [
#      (config.lib.custom.mkScript "lorri-init" ./lorri-init.sh [ ] { _doNotClearPath = true; })

#      (config.lib.custom.mkZshCompletion "lorri-init" ./lorri-init-completion.zsh { inherit devShells; })
#    ];

    programs = {
      direnv = {
        enable = true;

        enableBashIntegration = true;

        nix-direnv.enable = true;

        stdlib = ''
          # from https://github.com/direnv/direnv/wiki/Customizing-cache-location
          declare -A direnv_layout_dirs
          direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
              local hash="$(${pkgs.coreutils}/bin/sha1sum - <<<"$PWD" | cut -c-7)"
              local path="''${PWD//[^a-zA-Z0-9]/-}"
              echo "''${XDG_CACHE_HOME:-"$HOME/.cache"}/direnv/layouts/''${hash}''${path}"
            )}"
          }
        '';
      };
    };

#    services.lorri.enable = true;

  };

}
