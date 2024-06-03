
{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.nixbuild;
in

{

  ###### interface

  options = {

    custom.programs.nixbuild.enable = mkEnableOption "nixbuild config";

  };


  ###### implementation

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rlwrap
    ];

  # use root's .ssh here as nix-daemon runs with root permissions
  programs.ssh.extraConfig = ''
  Host eu.nixbuild.net
    PubkeyAcceptedKeyTypes ssh-ed25519i
    ServerAliveInterval 60
    IPQoS throughput
    IdentityFile /root/.ssh/my-nixbuild-key
'';

#environment.systemPackages = with pkgs; [
#  rlwrap
#];

nix.settings = {
  builders = "eu.nixbuild.net aarch64-linux - 100 1 benchmark big-parallel";
};
  };

}
