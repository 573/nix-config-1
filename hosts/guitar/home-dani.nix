/**
  Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

  For `[latest]` and `[unstable]` parameters determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{
  lib,
  pkgs, # latest,
  unstable,
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
      desktop = {
        enable = true;
	laptop = true;
      };

    };

    programs = {
      nixbuild.enable = true;
    };

    development = {
      nix.nixos.enable = true;
    };
  };

  programs = {
    alacritty.enable = true;

    wezterm = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  home.packages = attrValues {
    #with pkgs; [   
    inherit (pkgs)
      shellharden
      shfmt
      sqlite
      xsel
      difftastic
      nix-prefetch
      pcmanfm
      ;
  };
  xdg.enable = true;
}
