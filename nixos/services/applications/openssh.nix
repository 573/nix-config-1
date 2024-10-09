{
  config,
  lib,
  rootPath,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.openssh;
in

{

  ###### interface

  options = {

    custom.services.openssh = {
      enable = mkEnableOption "openssh";

      rootLogin = mkEnableOption "root login via pubkey";

      forwardX11 = mkEnableOption "x11 forwarding";
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    services.openssh = {
      inherit (cfg) forwardX11;
      enable = true;
      openFirewall = true;
      permitRootLogin = mkIf (!cfg.rootLogin) "no";
      passwordAuthentication = false;
      extraConfig = "MaxAuthTries 3";
    };

    users.users = {
      root.openssh.authorizedKeys.keyFiles = mkIf cfg.rootLogin [
        "${rootPath}/files/keys/id_ed25519.daniel.pub"
        "${rootPath}/files/keys/id_ed25519.danielwdws.pub"
      ];

      dani.openssh.authorizedKeys.keyFiles = [
        "${rootPath}/files/keys/id_ed25519.daniel.pub"
        "${rootPath}/files/keys/id_ed25519.danielwdws.pub"
      ];
    };

  };

}
