{ config, lib, pkgs, inputs, rootPath, ... }:
{
  custom = {
    base = {
      non-nixos.enable = true;
      general = {
        termux = true;
      };
    };
  };

  home = {
    homeDirectory = "/data/data/com.termux/files/home";
    username = "u0_a210";
  };
}
