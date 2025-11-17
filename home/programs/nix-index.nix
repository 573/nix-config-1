{
  config,
  lib,
  pkgs,
  inputs,
  ...
}@configArgs:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.nix-index;

  commonConfig = config.lib.custom.commonConfig configArgs;
in
{

  ###### interface

  options = {

    custom.programs.nix-index.enable = mkEnableOption "nix-index";

  };

  ###### implementation

  config = mkIf cfg.enable {

    home.file.".cache/nix-index/files".source =
      inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-database;

    programs.nix-index = {
      enable = true;

      package = pkgs.nix-index.override {
        nix = commonConfig.nix.package;
      };
    };

  };

}
