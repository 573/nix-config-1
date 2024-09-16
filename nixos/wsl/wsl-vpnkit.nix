/**
see ./../programs/docker.nix for similar issue
*/
{ config
, lib
, pkgs
, inputs
, unstable
, ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    optionalAttrs
    ;

/**
Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
*/


  # FIXME FIXME https://github.com/NixOS/nixpkgs/issues/5725#issuecomment-72851235
  # FIXME is workaround until upstream has the PR accepted, see https://github.com/nix-community/NixOS-WSL/issues/262#issuecomment-1825648537
  wsl-vpnkit =
    let inherit (unstable)
      lib
      findutils
      pstree
      resholve
      wsl-vpnkit;
    in
    wsl-vpnkit.override {
      resholve =
        resholve
        // {
          mkDerivation = attrs @ { solutions, ... }:
            resholve.mkDerivation (lib.recursiveUpdate attrs {
              src = inputs.wsl-vpnkit;

              solutions.wsl-vpnkit = {
                inputs =
                  solutions.wsl-vpnkit.inputs
                  ++ [
                    findutils
                    pstree
                  ];

                execer =
                  solutions.wsl-vpnkit.execer
                  ++ [ "cannot:${pstree}/bin/pstree" ];
              };
            });
        };
    };


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

          path = [ pkgs.iputils ];
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

          wantedBy = [ "multi-user.target" ];
        };

        wsl-vpnkit = {
          enable = true;
          description = "wsl-vpnkit";

          serviceConfig = {
            ExecStart = "${wsl-vpnkit}/bin/wsl-vpnkit";
            Type = "idle";
            Restart = "always";
            KillMode = "mixed";
          };
        };
      };
    };
  };
}
