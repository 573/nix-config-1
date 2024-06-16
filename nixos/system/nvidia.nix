
{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.system.nvidia;
in

{

  ###### interface

  options = {

    custom.system.nvidia.enable = mkEnableOption "nvidia config";

  };


  ###### implementation

  config = mkIf cfg.enable {
      hardware.opengl = {
        enable = true;
        driSupport32Bit = true;
      };
      # TODO Separate nvidia.nix
      /*  hardware.opengl = {
        driSupport = true;
        };

        # Load nvidia driver for Xorg and Wayland
        services.xserver.videoDrivers = [ "nvidia" ];
        #nixpkgs.config.cudaSupport = true;

        hardware.nvidia = {
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = false;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of 
        # supported GPUs is at: 
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = false;

        # Enable the Nvidia settings menu,
              	# accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        environment.systemPackages = with pkgs; [
        cudatoolkit
        ];
      */
  };

}
