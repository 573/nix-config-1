{
  config,
  pkgs,
  lib,
  rootPath,
  ...
}:

{

  # FIXME currently disabled due to Windows-Update 21.11.23
  # https://mynixos.com/nixpkgs/option/boot.binfmt.emulatedSystems
  # FIXME just too unstable: https://github.com/nix-community/NixOS-WSL/issues/552
  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; /* [ "armv7l-linux" ]; */ # list type misleading here as either or is only possible

  custom = {
    base.general.wsl = true;
    programs.docker.enable = true;
    # DONT the nixos-2211 hack might cause build problems finally, WIP investigating https://github.com/573/nix-config-1/actions/runs/10269489465/job/28415058034
    #    wsl = {
    #      scanner.enable = false;
    #      usbip.enable = false;
    #      yubikey.enable = false;
    #    };
    # [REINSTALL]
    #wsl.usbip.autoAttach = [ "1-2" ];
    # i. e. https://github.com/Gerschtli/nix-config/blob/ba690b64b54333c18eadd31b6d51cca8c7805fbe/hosts/argon/configuration.nix#L44
    # TODO get used to handling first, see example at https://github.com/oddlama/agenix-rekey/pull/28#issue-2331901837
    #agenix-rekey.enable = true;
    programs.nixbuild.enable = true;

    #services.tailscale.enable = true;
  };

  #services.paperless.enable = true;

/*
  # see https://discourse.nixos.org/t/ollama-not-found-but-installed/70097/3
  services.ollama = {
    enable = true;
    # https://ollama.com/library
    loadModels = [
      "deepseek-coder-v2:16b"
      "llama3.2:3b"
    ];
    package = pkgs.ollama;
    user = "ollama";
    group = "users";
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "0";
    };
  };

  # see https://wiki.nixos.org/wiki/Intel_Graphics but https://discourse.nixos.org/t/laptop-performance-on-nixos/42259/3
  services.xserver.videoDrivers = [ "modesetting" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # For modern Intel CPU's
      intel-media-driver # Enable Hardware Acceleration
      vpl-gpu-rt # Enable QSV
      # see https://search.nixos.org/packages?query=oneapi
      intel-compute-runtime

      # see https://discourse.nixos.org/t/video-acceleration-not-working-in-intel-iris-xe-graphic-13th-gen-i51340p/33367/2 and https://discourse.nixos.org/t/laptop-performance-on-nixos/42259/3
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # see https://wiki.archlinux.org/title/Hardware_video_acceleration#Configuring_VA-API
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };

  # see https://discourse.nixos.org/t/help-migrating-stuff-to-flakes/50027 and https://www.google.com/search?q=rocm+analog+for+intel+xe
  environment.systemPackages = with pkgs; [
    ollama
    adaptivecpp
    # see https://search.nixos.org/packages?query=spirv
    spirv-tools

    # see https://discourse.nixos.org/t/video-acceleration-not-working-in-intel-iris-xe-graphic-13th-gen-i51340p/33367/2 and https://discourse.nixos.org/t/laptop-performance-on-nixos/42259/3
    pciutils
    libva-utils
    sycl-info

    # see https://wiki.archlinux.org/title/Hardware_video_acceleration#Verification
    vdpauinfo

    # see https://wiki.archlinux.org/title/Hardware_video_acceleration#Verifying_Vulkan_Video
    vulkan-tools
  ];

  services.open-webui.enable = true;
*/ 

  systemd.tmpfiles.rules = [
    ''
      f /tmp/test/.nixd.json - - - - {"eval":{"depth":10,"target":{"args":["--expr","with import <nixpkgs> { }; callPackage /tmp/test/default.nix { }"],"installable":""}}}
    ''
  ];

  # if resources are accessible only with gid 1000so be it have it here (ubuntu)
  # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/config/users-groups.nix#L662
  users.groups = {
    nixos.gid = lib.mkForce config.custom.ids.gids.nixos;
  };
  users.users.nixos = {
    uid = lib.mkForce config.custom.ids.uids.nixos;
    extraGroups = [
      "nixos"
      "users"
    ];
    #isSystemUser = lib.mkForce true;
  };
}
