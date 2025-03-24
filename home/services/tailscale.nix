{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    attrValues
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.tailscale;
in
{
#imports

  options = {
    custom.services.tailscale.enable = mkEnableOption "tailscale config";
  };

  config = mkIf cfg.enable {

    home = {
    packages = attrValues {
      tailscale = pkgs.writeShellApplication {
        name = "nod-tailscale";

	runtimeInputs = attrValues {
	  inherit (pkgs)
	    sysvtools
	    busybox
	    tailscale
	    ;
	};

	text = ''
	  pidof tailscaled &>/dev/null || {
            echo "starting tailscaled"
            nohup setsid tailscaled -tun userspace-networking </dev/null &>/dev/null & jobs -p %1
          }

          [[ -n $1 ]] && {
            tailscale "$@"
          }
	'';
    };
  };
  };
  };
}
