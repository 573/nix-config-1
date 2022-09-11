{ config, lib, pkgs, homeModules, rootPath, ... }: {
  environment.etcBackupExtension = ".nod-bak";

  environment.packages = with pkgs; [
    gnutar
    gzip
  ];

  home-manager = {
    backupFileExtension = "hm-bak";
    config = rootPath + "/hosts/sams9/home-nix-on-droid.nix";
    extraSpecialArgs = { inherit rootPath; };
    sharedModules = homeModules;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.05";

  time.timeZone = "Europe/Berlin";
}
