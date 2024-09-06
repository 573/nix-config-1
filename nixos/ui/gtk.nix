{ config
, lib
, inputs
, pkgs
, ...
}:
let
  inherit
    (lib)
    mkIf
    mkEnableOption
    ;
  cfg = config.custom.ui.gtk;
in
{
  options.custom.ui.gtk = {
    enable = mkEnableOption "gtk config" // { default = true; };
  };

  config = mkIf (cfg.enable) {
    # https://github.com/nix-community/home-manager/issues/3113#issuecomment-1194883746
    programs.dconf.enable = true;
  };
}
