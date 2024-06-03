{ config, lib, pkgs, homeModules, inputs, rootPath, ... }@configArgs:

let
  sshdTmpDirectory = "${config.user.home}/sshd-tmp";
  sshdDirectory = "${config.user.home}/sshd";
  # UseDNS no\nUsePrivilegeSeparation no\nUsePAM no\nForceCommand eval ". /etc/profiles/per-user/nix-on-droid/etc/profile.d/nix-on-droid-session-init.sh" ; if [ -n "$SSH_ORIGINAL_COMMAND" ]; then $(eval "$SSH_ORIGINAL_COMMAND"); else exec "$SHELL"; fi
  sshdConfig = ''
    UsePAM=no\nForceCommand eval ". ${config.home-manager.config.home.profileDirectory}/etc/profile.d/nix-on-droid-session-init.sh" ; nice -n20 nix-store --serve --write\nHostKey ${sshdDirectory}/ssh_host_ed25519_key\nPort 8022\n
  '';

  commonConfig = config.lib.custom.commonConfig configArgs;

  inherit (lib)
    concatStringsSep
    ;
in
{
  # FIXME: Move sshd config to nix-on-droid
  # DONE It is practical that this way all the files are still accessible
  build.activation.sshd = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
    $DRY_RUN_CMD cat "${rootPath}/files/keys/id_ed25519.daniel.pub" > "${config.user.home}/.ssh/authorized_keys"
    $DRY_RUN_CMD cat "${rootPath}/files/keys/id_ed25519.danielwdws.pub" >> "${config.user.home}/.ssh/authorized_keys"
    $DRY_RUN_CMD echo "eu.nixbuild.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM" >> "${config.user.home}/.ssh/known_hosts"

    if [[ ! -d "${sshdDirectory}" ]]; then
      $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "${sshdTmpDirectory}/ssh_host_ed25519_key" -N ""
      $VERBOSE_ECHO "Writing sshd_config..."
      $DRY_RUN_CMD echo -e "${sshdConfig}" > "${sshdTmpDirectory}/sshd_config"

      $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
    fi
  '';

  environment = {
    etcBackupExtension = ".nod-bak";
    motd = null;
    packages = with pkgs; [
      diffutils
      findutils
      gawk
      gnugrep
      gnused
      gnutar
      hostname
      man
      ncurses
      procps
      psmisc
      # TODO Maybe do sshd-start here as gerschtli does
      gzip
      which
      micro
      (writeScriptBin "debug-ssl" ''
        #!${runtimeShell}

        openssl s_client -connect nixos.org:443
      '')
      (writeScriptBin "sshd-start" ''
        #!${runtimeShell}

        echo "Starting sshd in non-daemonized way on port 8022"
        ${openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
      '')
      kalker
    ];
  };

  home-manager = {
    inherit (commonConfig.homeManager.baseConfig)
      backupFileExtension
      extraSpecialArgs
      sharedModules
      useGlobalPkgs
      useUserPackages
      ;

    config = commonConfig.homeManager.userConfig "sams9" "nix-on-droid";
  };

  nix =
    # Disabling the extraOptions part now as of gha run # 149
    let
      inherit (commonConfig.nix.settings)
        trusted-public-keys
        experimental-features
        log-lines
        ;
    in
    {
      inherit (commonConfig.nix) nixPath package registry;
      inherit (commonConfig.nix.settings) substituters;
      trustedPublicKeys = trusted-public-keys;
      # https://nixos.org/manual/nix/stable/command-ref/conf-file#conf-experimental-features nix --version 2.15.2
      # see https://github.com/nix-community/nix-on-droid/blob/ae0569f/modules/environment/nix.nix#L107 and https://github.com/nix-community/nix-on-droid/issues/166
      extraOptions = ''
        		  keep-derivations = true
        		  keep-outputs = true
        		  experimental-features = ${concatStringsSep " " experimental-features}
        	  flake-registry =
        		  log-lines = ${toString log-lines}
        	  '';
    };

  # FIXME: update when released
  system.stateVersion = "23.11";

  terminal.font =
    let
      fontPackage = pkgs.nerdfonts.override {
        fonts = [ "UbuntuMono" ];
      };
      fontPath = "/share/fonts/truetype/NerdFonts/UbuntuMonoNerdFont-Regular.ttf";
    in
    fontPackage + fontPath;

  time.timeZone = "Europe/Berlin";

}
