{ config, lib, pkgs, homeModules, inputs, rootPath, ... }@configArgs:

let
  inherit (lib)
    concatStringsSep
    ;

  commonConfig = config.lib.custom.commonConfig configArgs;

in
{
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
    let
      inherit (commonConfig.nix.settings)
        substituters
        trusted-public-keys
        experimental-features
        log-lines
        ;
    in
    {
      inherit (commonConfig.nix) package;
      # https://github.com/573/nix-config-1/commit/8ee0a73a17f56e56f79c90c4d7af439ee48dbfeb#
      # TODO Rework this, is experimental-features still valid or is it extra-experimental-features now ?
      extraOptions = ''
        keep-derivations = true
        keep-outputs = true
        experimental-features = ${concatStringsSep " " experimental-features}
        flake-registry =
        log-lines = ${toString log-lines}
        substituters = ${concatStringsSep " " substituters}
        trusted-public-keys = ${concatStringsSep " " (trusted-public-keys.content)}
      '';
    };

  # FIXME: update when released
  system.stateVersion = "23.05";

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
