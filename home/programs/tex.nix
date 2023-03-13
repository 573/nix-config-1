{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.tex;
in

{

  ###### interface

  options = {

    custom.programs.tex = {
      enable = mkEnableOption "tex config";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home = {
      packages = [
        #pkgs.texliveBookPub
        #pkgs.texlab # DONT come with texlab.enable and ltex.enable in nixvim
        #pkgs.ltex-ls
        (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-minimal latexmk; })
      ];
    };

  };

}
