{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.misc.util-bins;
in

{

  ###### interface

  options = {

    custom.misc.util-bins = {

      enable = mkEnableOption "some utility binaries";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      (config.lib.custom.mkScript
        "conf-status"
        ./conf-status.sh
        [ pkgs.git ]
        { }
      )

      (config.lib.custom.mkScript
        "$"
        ./dollar.sh
        [ ]
        { _doNotClearPath = true; }
      )

      (config.lib.custom.mkScript
        "system-update"
        ./system-update.sh
        (with pkgs; [ age git gnugrep gnused nvd ])
        { _doNotClearPath = true; }
      )

      (config.lib.custom.mkScript
        "kvm_display_handler_layout"
        ./kvm_display_handler_layout.sh
        (with pkgs; [ xorg.xrandr ])
        { _doNotClearPath = true; }
      )
    ];

  };

}
