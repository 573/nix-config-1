{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.custom.base.non-nixos;

  substituters = [
    "https://cache.nixos.org"
    "https://gerschtli.cachix.org"
    "https://nix-on-droid.cachix.org"
    "https://hydra.iohk.io"
    "https://srid.cachix.org"
    "https://nickel.cachix.org"
    "https://cachix.cachix.org"
    "https://nix-community.cachix.org"
    "https://niv.cachix.org"
    "https://573-bc.cachix.org"
    "https://jupyterwith.cachix.org"
  ];
  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
    "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
    "nickel.cachix.org-1:ABoCOGpTJbAum7U6c+04VbjvLxG9f0gJP5kYihRRdQs="
    "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "niv.cachix.org-1:X32PCg2e/zAm3/uD1ScqW2z/K0LtDyNV7RdaxIuLgQM="
    "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs="
    "jupyterwith.cachix.org-1:/kDy2B6YEhXGJuNguG1qyqIodMyO4w8KwWH4/vAc7CI="
  ];
in

{

  ###### interface

  options = {

    custom.base.non-nixos = {
      enable = mkEnableOption "config for non NixOS systems";

      installNix = mkEnableOption "nix installation" // { default = true; };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home = {
      packages = mkIf cfg.installNix [ pkgs.nix ];
      sessionVariables.NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };

    nix.registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nix-config.flake = inputs.self;
    };

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

    targets.genericLinux.enable = true;

    xdg.configFile."nix/nix.conf".text = ''
      substituters = ${concatStringsSep " " substituters}
      trusted-public-keys = ${concatStringsSep " " trustedPublicKeys}
      trusted-users = root nix-on-droid
      experimental-features = nix-command flakes
      log-lines = 30
    '';

  };

}
