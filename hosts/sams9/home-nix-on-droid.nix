{
  config,
  lib,
  pkgs,
  nixos-2405,
  ...
}:
let
  inherit (lib)
    attrValues
    ;
in

{
  custom = {
    base = {
      general.lightWeight = true;

      non-nixos = {
        enable = true;
        installNix = true;
        #builders = [
        #  "ssh://private.maiziedemacchiato aarch64-linux - 4"
        #];
      };

    };

    development = {
      direnv.enable = true;
      nix.nix-on-droid.enable = true;
    };

    programs = {
      #yazi.enable = lib.mkForce false;
      #tex.enable = true;
      #hledger.enable = true;



      shell = {
      envExtra = lib.mkBefore ''
        . "/etc/profiles/per-user/nix-on-droid/etc/profile.d/nix-on-droid-session-init.sh"
      '';

        logoutExtra = ''
          count="$(ps -e | grep proot-static | wc -l)"
          if [[ -z "$SSH_TTY" && "$SHLVL" == 1 && "$count" == 1 ]]; then
            ps -e | grep -E " ssh(d|-agent)$" | awk '{print $1}' | xargs -I % kill %
          fi
        '';
        # for ssh smartphone nix -version, probably redundant though https://github.com/search?q=repo%3Anix-community%2Fnix-on-droid%20nix-on-droid-session-init.sh&type=code
        #      envExtra = ''
        #        . "${config.home.profileDirectory}/etc/profile.d/nix-on-droid-session-init.sh"
        #      '';
      };

      #      ssh = {
      #        cleanKeysOnShellStartup = false;
      #        controlMaster = "no";
      #        modules = [ "private" ];
      #      };

      # FIXME: tmux does not start
      tmux.enable = lib.mkForce false;

    };
  };

  home = {
    packages = attrValues {
      # with pkgs; [
      /*
        (writeShellScriptBin "tailscale" ''
            ${pkgs.sysvtools}/bin/pidof tailscaled &>/dev/null || {
           echo "starting tailscaled"
           nohup ${pkgs.busybox}/bin/setsid ${pkgs.tailscale}/bin/tailscaled -tun userspace-networking </dev/null &>/dev/null & jobs -p %1
          }

          [[ -n $1 ]] && {
           ${unstable.tailscale}/bin/tailscale "$@"
           }
        '')
      */
      #hydra-check
      #pandoc
      #nixd
      #mermaid-cli
      #chafa
      #      asciinema
      inherit (pkgs)
        nix-inspect
        ;

      inherit (nixos-2405)
        zellij
	;
    };

#    activation =
#      let
#        inherit config;
#      in
#      {
#        copyFont =
#          let
#            font_src = "${pkgs.carlito}/share/fonts/truetype/.";
#            font_dst = "${config.home.homeDirectory}/texmf/fonts/truetype/Carlito";
#          in
#          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
#            	       test -e "${font_dst}" && comm -1 -3 <(sha1sum ${font_src}/*.ttf|cut -d' ' -f1) <(sha1sum ${font_dst}/*.ttf|cut -d' ' -f1) &>/dev/null
#            	if [ $? -ne 0 ]
#            	then
#            	  mkdir -p "${font_dst}"
#            	  cp -R "${font_src}" "${font_dst}"
#            	fi
#                  '';
#      };
  };

  # FIXME: without overrides produces warnings
  home.language = {
    collate = lib.mkForce null;
    ctype = lib.mkForce null;
    messages = lib.mkForce null;
    numeric = lib.mkForce null;
    time = lib.mkForce null;
  };

  #home.file.".ssh/environment".text = ''
  #  # https://serverfault.com/a/593487
  #  BASH_ENV=~/.profile
  # rather to activation
  #PATH=/data/data/com.termux.nix/files/usr/etc/profiles/per-user/nix-on-droid/bin:"$PATH"
  #'';

  xdg.enable = true;
}
