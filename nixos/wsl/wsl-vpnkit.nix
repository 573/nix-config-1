
{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib)
  mkIf
  mkEnableOption
  optionalAttrs
  ;

  cfg = config.custom.wsl.wsl-vpnkit;
in
{
  options.custom.wsl.wsl-vpnkit = {
    enable = mkEnableOption "See https://github.com/nix-community/NixOS-WSL/issues/262#issuecomment-1896110651" // optionalAttrs (config.custom.base.general.wsl) { default = true; };

    autoVPN = mkEnableOption "Auto-enable";

    checkURL = lib.mkOption {
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
    systemd = { 
	    services = {
	      wsl-vpnkit-auto = {
		      enable = cfg.autoVPN;
		      description = "wsl-vpnkit";

		      path = [pkgs.iputils];
		      script = ''
			has_internet () {
			  ping -q -w 1 -c 1 8.8.8.8 >/dev/null
			}

			has_company_network () {
			  ping -q -w 1 -c 1 ${cfg.checkURL} >/dev/null
			}

			is_active_wsl-vpnkit () {
			  systemctl is-active -q wsl-vpnkit.service
			}

			main () {
			  if is_active_wsl-vpnkit; then
			    if has_internet && ! has_company_network; then
			      echo "Stopping wsl-vpnkit..."
			      systemctl stop wsl-vpnkit.service
			    fi
			  else
			    if ! has_internet; then
			      echo "Starting wsl-vpnkit..."
			      systemctl start wsl-vpnkit.service
			    fi
			  fi
			}

			while :
			do
			  main
			  sleep 5
			done
		      '';

		      wantedBy = ["multi-user.target"];
	    };

	    wsl-vpnkit = {
	      enable = true;
	      description = "wsl-vpnkit";

	      serviceConfig = {
		ExecStart = "${pkgs.wsl-vpnkit}/bin/wsl-vpnkit";
		Type = "idle";
		Restart = "always";
		KillMode = "mixed";
	      };
	    };
       };
    };
  };
}
