{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkForce
    optionalAttrs
    ;

  cfg = config.custom.wsl;
in
{
  #imports = [ inputs.nix-ld-rs.nixosModules.nix-ld ];

  options.custom.wsl = {
    enable =
      mkEnableOption "Wsl settings"
      // optionalAttrs (config.custom.base.general.wsl) { default = true; };
  };

  config = mkIf (cfg.enable) {
    wsl = {
      enable = true;
      interop.register = true;
    };

    environment.defaultPackages = [ pkgs.wslu ];

    custom.system.boot.enable = mkForce false;

    # https://github.com/nix-community/NixOS-WSL/discussions/71
    security.sudo.wheelNeedsPassword = true;

    # https://github.com/nix-community/NixOS-WSL/issues/246#issuecomment-1577173622
    # to run: NIX_LD_LIBRARY_PATH=/usr/lib/wsl/lib/ /usr/lib/wsl/lib/nvidia-smi
    #programs.nix-ld.enable = true;
    # see  https://github.com/nix-community/NixOS-WSL/discussions/92
    # disabled nix-ld-rs with 24.11
    programs.nix-ld = {
      enable = true;
      # TODO https://github.com/Mic92/dotfiles/blob/1b76848e2b5951bc9041af95a834a08b68e146fd/nixos/modules/nix-ld.nix
      libraries = with pkgs; [
        stdenv.cc.cc # for libstdc++.so.6
      ];
    };

services.locate = {
  enable = true;
  package = pkgs.plocate; # use faster locate implementation
  prunePaths = [
    "/media"
    "/mnt/c" # don't index windows drives in WSL
    "/mnt/d"
    "/mnt/e"
    "/mnt/f"
    "/mnt/wsl"
    "/nix/store"
    "/nix/var/log/nix"
    "/tmp"
    "/var/spool"
    "/var/tmp"
  ];
};

    /*
      environment.variables = {
        NIX_LD_LIBRARY_PATH = lib.mkDefault (lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
        ]);
        #NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; #"${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
        NIX_LD = lib.mkDefault pkgs.stdenv.cc.bintools.dynamicLinker;
      };
    */
  };
}
