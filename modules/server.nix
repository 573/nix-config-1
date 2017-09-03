{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      30033 10011 41144 # TS3
      80 443 # httpd
    ];

    allowedUDPPorts = [
      9987 # TS3
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services = {
    fail2ban.enable = true;

    httpd = {
      enable = true;
      logPerVirtualHost = true;
      enablePHP = true;
      adminAddr = "tobias.happ@gmx.de";
    };

    mysql = {
      # set password with:
      # SET PASSWORD FOR root@localhost = PASSWORD('password');
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/var/db/mysql";
    };

    openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = false;
      extraConfig = ''
        MaxAuthTries 3
      '';
    };

    teamspeak3.enable = true;
  };

  users.users.tobias.openssh.authorizedKeys.keyFiles = [
    ../misc/id_rsa.tobias-login.pub
  ];
}
