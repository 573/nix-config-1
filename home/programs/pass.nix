{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.pass;

  # see https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/tools/security/pass/extensions/checkup.nix
  package = pkgs.pass.withExtensions (exts: [ exts.pass-checkup ]);
in

{

  ###### interface

  options = {

    custom.programs.pass = {
      enable = mkEnableOption "pass config";

      browserpass = mkEnableOption "browserpass";
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.gpg.enable = true;

    programs = {
      browserpass = {
        enable = cfg.browserpass;
        browsers = [ "chrome" ];
      };

      password-store = {
        inherit package;
        enable = true;
        settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      };
    };

  };

}
