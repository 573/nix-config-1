/**
Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

For `[haskellPackages]` parameter determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{ config, lib, pkgs, /*haskellPackages,*/ inputs, ... }:

let
  inherit (lib)
    attrValues
    mkEnableOption
    mkIf
    mkForce
    ;

/**
Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
*/
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.custom.programs.arbtt;
in
{

  ###### interface

  options = {

    custom.programs.arbtt.enable = mkEnableOption "arbtt config";

  };


  ###### implementation

  config = mkIf cfg.enable {
    # FIXME https://github.com/toonn/nix-config/blob/master/home/home.nix
    home.packages = attrValues {
      inherit (inputs.ghc-nixpkgs-unstable.legacyPackages.${system}.haskell.packages.ghc965)
        arbtt
        ;
    };

    systemd.user = {
      services = {
        "arbtt-capture" = {
          Service = {
            # https://github.com/nix-community/home-manager/tree/release-24.05/modules/services
            Environment =
              let
                path = builtins.concatStringsSep ":"
                  (map (p: "${lib.getBin p}/bin")
                    (attrValues { inherit (inputs.ghc-nixpkgs-unstable.legacyPackages.${system}.haskell.packages.ghc965) arbtt; inherit (pkgs) coreutils; } # with pkgs; []
                    )
                  );
              in
              "PATH=${path}";
            ExecStart =
              let
                script
                  # TODO more config: https://github.com/NixOS/nixpkgs/blob/release-21.05/nixos/modules/services/monitoring/arbtt.nix
                  = pkgs.writeShellScript "arbtt-capture-start" ''
                  set -e
                  DATADIR="''${XDG_DATA_HOME:-$HOME/.local/share/arbtt}"
                  LOG="''${DATADIR}/''$(date +%Y).capture"
                  mkdir -p "''${DATADIR}"
                  arbtt-capture --logfile="''${LOG}"
                '';
              in
              "${script}";
            Restart = "always";
          };
          Unit = {
            Description = "Arbtt capture service";
            PartOf = [ "graphical-session.target" ];
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
      startServices = mkForce "sd-switch";
    };
  };

}
