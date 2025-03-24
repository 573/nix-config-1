{ pkgs, ... }:

{
  custom = {
    base.general.lightWeight = true;

    development.nix.nixos.enable = true;

    # https://blog.yaymukund.com/posts/nixos-raspberry-pi-nixbuild-headless/
    programs.nixbuild.enable = true;
  };
}
