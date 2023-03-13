{ config, lib, pkgs, rootPath, inputs, ... }: {

  custom = {
    base = {
      general.wsl = true;
    };

    development = {
      nix.nixos.enable = true;
    };
  };

  home.packages = with pkgs; [
    hadolint
  ];

  xdg.enable = true;
}
