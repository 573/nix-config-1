{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  cfg = config.custom.programs.nixbuild;
in

{

  ###### interface

  options = {

    custom.programs.nixbuild.enable = mkEnableOption "nixbuild config";

  };


  ###### implementation
  config = mkIf cfg.enable
    (mkMerge [
      (mkIf (cfg.custom.base.non-nixos) {
        programs.ssh.extraConfig = ''
          Host eu.nixbuild.net
            PubkeyAcceptedKeyTypes ssh-ed25519	
            ServerAliveInterval 60
            IPQoS throughput
            IdentityFile /root/.ssh/my-nixbuild-key
        '';

        custom.base.non-nixos.builders = [
	"eu.nixbuild.net aarch64-linux - 100 1 benchmark big-parallel"
        ];
      })

      {
        home.packages = with pkgs; [
          rlwrap
        ];
      }
    ]);
}
