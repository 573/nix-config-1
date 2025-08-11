{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    optionalAttrs
    ;

  usbipd-win-auto-attach = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dorssel/usbipd-win/v4.2.0/Usbipd/WSL/auto-attach.sh";
    hash = "sha256-AiXbRWwOy48mxQxxpWPtog7AAwL3mU3ZSHxrVuVk8/s=";
  };

  cfg = config.custom.wsl.usbip;
in
{
  options.custom.wsl.usbip = {
    enable =
      mkEnableOption "Customisation of USB/IP integration";

    autoAttach = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = [ "4-1" ];
      description = "Auto attach devices with provided Bus IDs.";
    };

    snippetIpAddress = lib.mkOption {
      type = lib.types.str;
      default = "$(grep nameserver /etc/resolv.conf | cut -d' ' -f2)";
      example = "127.0.0.1";
      description = ''
        not working is (https://github.com/nix-community/NixOS-WSL/commit/f5a6c03518b839113a9e61888e0adbd489c3118f#diff-773365379831e0cce53043c065981efbf0c76f33ca575955ab512cb762c19742R24):
        $(ip route list | sed -nE 's/(default)? via (.*) dev eth0 proto kernel/\2/p') 
        This snippet is used to obtain the address of the Windows host.
      '';
    };
  };

  config = mkIf (cfg.enable) {

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs.linuxPackages)
        usbip
        ;
      inherit (pkgs.usbutils)
        out
        ;
    };

    # https://github.com/nix-community/NixOS-WSL/issues/662#issuecomment-3114880659
    # TODO possibly redundant, update nixos-wsl flake first 
    /*extraBin = [
    { src = "${lib.getExe' pkgs.coreutils-full "ls"}"; }
    { src = "${lib.getExe pkgs.bash}"; }
    { src = "${lib.getExe' pkgs.linuxPackages.usbip "usbip"}"; }
  ];*/

    services.udev.enable = true;

    systemd = {
      services."usbip-auto-attach@" = {
        description = "Auto attach device having busid %i with usbip";

        scriptArgs = "%i";
        path = builtins.attrValues {
          inherit (pkgs)
            iproute2
            ;
          inherit (pkgs.linuxPackages)
            usbip
            ;
        };

        script = ''
            busid="$1"
            ip="${cfg.snippetIpAddress}"

            echo "Starting auto attach for busid $busid on $ip."
            source ${usbipd-win-auto-attach} "$ip" "$busid"
        '';
      } // (lib.optionalAttrs (config.custom.wsl.wsl-vpnkit.enable) {
        #after = [ "wsl-vpnkit-auto.target" ]; FIXME how
        # https://search.nixos.org/options?channel=24.05&show=systemd.services.%3Cname%3E.after&from=0&size=50&sort=relevance&type=packages&query=systemd.services
        # "If the specified units are started at the same time as this unit, delay this unit until they have started."
        # name being network there https://github.com/nix-community/NixOS-WSL/blob/f5a6c03/modules/usbip.nix
        after = [ "wsl-vpnkit.target" ];
      });

    } // (lib.optionalAttrs (config.custom.wsl.wsl-vpnkit.enable) {
      # https://search.nixos.org/options?channel=24.05&show=systemd.targets.%3Cname%3E.wants&from=0&size=50&sort=relevance&type=packages&query=systemd.targets
      # https://search.nixos.org/options?channel=24.05&show=systemd.services.%3Cname%3E.wants&from=0&size=50&sort=relevance&type=packages&query=systemd.services
      # "systemd.services.<name>.wants"
      # "Start the specified units when this unit is started."
      # name being multi-user there https://github.com/nix-community/NixOS-WSL/blob/f5a6c03/modules/usbip.nix
      targets.wsl-vpnkit.wants = map (busid: "usbip-auto-attach@${busid}.service") cfg.autoAttach;
    });
  };
}
