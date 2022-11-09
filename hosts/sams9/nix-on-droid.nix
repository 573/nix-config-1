{ config, lib, pkgs, homeModules, inputs, rootPath, ... }: {
  environment.etcBackupExtension = ".nod-bak";

  environment.packages = with pkgs; [
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
    gzip
    which
  ];

  home-manager = {
    backupFileExtension = "hm-bak";
    config = "${rootPath}/hosts/sams9/home-nix-on-droid.nix";
    extraSpecialArgs = { inherit inputs rootPath; };
    sharedModules = homeModules;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  system.stateVersion = "22.05";

  time.timeZone = "Europe/Berlin";
}
