{ config, lib, ... }:

let
  inherit (lib)
    concatMapStringsSep
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.system.firewall;
in

{

  ###### interface

  options = {

    custom.system.firewall = {
      enable = mkEnableOption "firewall";

      dropPackets = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          List of IPs or subnets, whose ssh packages are dropped by default.
        '';
      };

      openPortsForIps = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              ip = mkOption {
                type = types.str;
                description = ''
                  IP to open port for.
                '';
              };

              port = mkOption {
                type = types.int;
                description = ''
                  Port to open.
                '';
              };

              protocol = mkOption {
                type = types.enum [
                  "tcp"
                  "udp"
                ];
                default = "tcp";
                description = ''
                  Protocol.
                '';
              };
            };
          }
        );
        default = [ ];
        description = ''
          Open ports for specific IPs.
        '';
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.etc."fail2ban/filter.d/port-scan.conf".text = ''
      [Definition]
      failregex = rejected connection: .* SRC=<HOST>
    '';

    networking.firewall = {
      enable = true;
      allowPing = true;

      extraCommands =
        concatMapStringsSep "\n" (
          address: "iptables -A INPUT -p tcp -s ${address} --destination-port 22 -j DROP"
        ) cfg.dropPackets
        + "\n"
        + concatMapStringsSep "\n" (
          option:
          "iptables -I INPUT -p ${option.protocol} -s ${option.ip} --dport ${toString option.port} -j ACCEPT"
        ) cfg.openPortsForIps;
    };

    services.fail2ban = {
      enable = true;

      jails = {
        ssh-iptables = ''
          bantime  = 86400
        '';

        port-scan = ''
          filter   = port-scan
          action   = iptables-allports[name=port-scan]
          bantime  = 86400
          maxretry = 2
        '';
      };
    };

  };

}
