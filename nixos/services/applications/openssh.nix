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

    # FIXME see https://search.nixos.org/options?channel=25.11&query=programs.ssh.knownHosts#show=option%253Aprograms.ssh.knownHosts,
    #  but declare in nixos/programs/nixbuild.nix
    services.openssh = {
      settings = {
        PermitRootLogin = mkIf (!cfg.rootLogin) "no";
        X11Forwarding = cfg.forwardX11;
        PasswordAuthentication = false;
      };
      enable = true;
      openFirewall = true;
      extraConfig = "MaxAuthTries 3";
    };

    users.users = {
      root.openssh.authorizedKeys.keyFiles = mkIf cfg.rootLogin [
        "${rootPath}/files/keys/id_ed25519.daniel.pub"
        "${rootPath}/files/keys/id_ed25519.danielwdws.pub"
        "${rootPath}/files/keys/id_ed25519.daniel.nixondroid.pub"
        "${rootPath}/files/keys/id_ed25519.guitar.pub"
      ];

      dani.openssh.authorizedKeys.keyFiles = [
        "${rootPath}/files/keys/id_ed25519.daniel.pub"
        "${rootPath}/files/keys/id_ed25519.danielwdws.pub"
        "${rootPath}/files/keys/id_ed25519.daniel.nixondroid.pub"
        "${rootPath}/files/keys/id_ed25519.guitar.pub"
      ];
    };

  };

}
