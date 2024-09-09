/**
see ./../../flake/builders/mkNixos.nix line `++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/nixos";` and ./../../flake/default.nix `customLibFor` declaration

Same as written in ./../../flake/builders/mkNixos.nix should apply here (regarding `specialArgs` injection) as the anonymous module is a module next to `"${rootPath}/hosts/${name}/configuration.nix"` there
*/
{ config, lib, /* unstable,*/ pkgs, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.docker;
in

{
  #  imports = [
  #    (args@{ pkgs, ... }:
  #      import "${inputs.unstable.outPath}/nixos/modules/services/hardware/nvidia-container-toolkit"
  #        (args // { pkgs = inputs.unstable.legacyPackages.${pkgs.system}; }))
  #  ];

  ###### interface

  options = {

    custom.programs.docker.enable = mkEnableOption "docker";

  };


  ###### implementation

  config = mkIf cfg.enable {
    #hardware.nvidia-container-toolkit.enable = true; # renamed here: https://github.com/NixOS/nixpkgs/commit/471ff2c33c99bf88eb87430df2251f73d94181d0
    # https://github.com/nix-community/NixOS-WSL/issues/433
    # https://github.com/nix-community/NixOS-WSL/pull/478
    virtualisation = {
      docker = {
        enable = true;
        #package = pkgs.docker_24; #unstable.docker_25;
        #       enableNvidia = true;

        storageDriver = "overlay2";
        # https://github.com/NVIDIA/nvidia-docker/issues/942
        #virtualisation.docker.enableNvidia = true;
        # TODO Encapsulate in work.enable the case where rootless is not used
        rootless = {
          enable = true;
          # for the "whole" discussion of it (rootless or not) i. e. https://discourse.nixos.org/t/docker-rootless-with-nvidia-support/37069
          setSocketVariable = true; # false for driver exact support
          /*	daemon.settings = {
                                        				runtimes = {
                                                					nvidia = {
                                    			path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
                                  			};
                                        				};
            };
                                              	    */
        };
      };
    };

    # https://github.com/nix-community/NixOS-WSL/blob/0fa9268bf9a903498cb567e6d4d01eb945f36f6e/tests/docker/docker-native.nix#L9

    users.users.nixos.extraGroups = [ "docker" ];

    # https://discourse.nixos.org/t/gpu-enabled-docker-containers-in-nixos/23870/2
    systemd.enableUnifiedCgroupHierarchy = false;

  };

}
