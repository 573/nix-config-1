{
  pkgs,
  config,
  lib,
  zellij,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  inherit (pkgs) runCommand makeWrapper;

  cfg = config.custom.programs.zellij;
in

{

  ###### interface

  options = {

    custom.programs.zellij = {
      enable = mkEnableOption "zellij config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final zellij.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    # TODO zellij gh/discussions/3077
    custom.programs.zellij.finalPackage = config.custom.programs.zellij.package; 
    programs.zellij = {
      enable = true;
 # https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages
      package = let
        zellij-zen = runCommand "zellij-zen" {
	  nativeBuildInputs = [ makeWrapper zellij ];
	} ''
        mkdir -p $out/bin
        makeWrapper ${zellij}/bin/zellij $out/bin/zellij \
	--add-flags "-l compact options --no-pane-frames"
	'';
      in zellij-zen;
  };
  };
}
