{ config, lib, pkgs, homeModules, inputs, rootPath, ... }@configArgs:
# TODO https://github.com/search?q=repo%3AGerschtli%2Fnix-config%20custom.base.desktop&type=code
let
  inherit (lib)
    genAttrs
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    mkOption
    types
    ;

  inherit (lib.lists)
    optional
    ;

  cfg = config.custom.base.general;

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{
  # See https://sourcegraph.com/github.com/michalrus/dotfiles/-/blob/machines/_shared_/features/canoscan-lide-20/default.nix?L34:11
  # but also https://discourse.nixos.org/t/whats-the-difference-between-extraargs-and-specialargs-for-lib-eval-config-nix/5281/2
  disabledModules = [ "services/hardware/sane.nix" ];

  imports = [
    inputs.home-manager.nixosModules.home-manager
    # Is in 23.05
    #    "${inputs.latest}/nixos/modules/services/web-apps/photoprism.nix"

    # FIXME Can this be guarded somehow as well ?
    inputs.nixos-wsl.nixosModules.wsl
    # TODO could this be elevated to use unstable home-manager modules in parallel to release-XX as well ?
    (args@{ config, lib, pkgs, ... }:
      import "${inputs.nixpkgs.outPath}/nixos/modules/services/hardware/sane.nix"
        (args // { pkgs = inputs.nixos-2211.legacyPackages.${pkgs.system}; })
      # above works, but FIXME does not work (again) in unstable yet
      #(args // { pkgs = inputs.unstable.legacyPackages.${pkgs.system}; })
    )
  ];


  ###### interface

  options = {
    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      wsl = mkEnableOption "nixos-wsl specific config";

      hostname = mkOption {
        type = types.enum [ "DANIELKNB1" "twopi" ];
        description = "Host name.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {

      boot.tmp.cleanOnBoot = true;

      console.keyMap = "de";

      custom = {
        system.firewall.enable = true;
      };

      documentation.nixos.enable = false;

      environment = {
        defaultPackages = [ ];
        shellAliases = mkForce { };
      };

      home-manager = {
        inherit (commonConfig.homeManager.baseConfig)
          backupFileExtension
          extraSpecialArgs
          sharedModules
          useGlobalPkgs
          useUserPackages
          ;

        users = genAttrs ([ "root" ] ++ optional (!cfg.wsl) "dani" ++ optional cfg.wsl "nixos") (commonConfig.homeManager.userConfig cfg.hostname);
      };

      i18n.supportedLocales = [
        "C.UTF-8/UTF-8"
        "de_DE.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];

      networking = {
        hostName = cfg.hostname;
        usePredictableInterfaceNames = false;
      };

      nix = {
        settings = {
          inherit (commonConfig.nix.settings)
            experimental-features
            flake-registry
            log-lines
            substituters
            trusted-public-keys
            ;

          trusted-users = [ "root" ] ++ optional (!cfg.wsl) "dani" ++ optional cfg.wsl "nixos";
        };

        inherit (commonConfig.nix)
          nixPath
          package
          registry
          ;
      };

      system = {
        configurationRevision = inputs.self.rev or "dirty";
        stateVersion = "23.11";
      };

      time.timeZone = "Europe/Berlin";

      # for NixOS-WSL in case of own user, see https://github.com/nix-community/NixOS-WSL/blob/4840f5d/modules/wsl-distro.nix#L89C5-L93C7
      users.users = {
        dani = {
          uid = config.custom.ids.uids.dani;
          extraGroups = [ "wheel" ];
          isNormalUser = true;
        };
      };
    }

    (mkIf (cfg.wsl) {

      custom.wsl.usbip.enable = true;

      custom.system.boot.enable = mkForce false;

      wsl = {
        enable = true;
        # see https://github.com/nix-community/NixOS-WSL/blob/4840f5d/modules/wsl-distro.nix#L17
        #defaultUser = "dkahlenberg";
        # FIXME Disabled due to Windows Update 21.11.23
        # FIXME wsl-vpnkit / journalctl: "cannot connect to host: fork/exec /nix/store/ifayrgnd020y38gssz3x4y3sld0sdry5-gvproxy-0.7.1/bin/gvproxy-windows.exe: exec format error"
        interop.register = true;

        # https://github.com/nix-community/NixOS-WSL/commit/7f6189c658963fce68ab38fa9200729a6328f280
        usbip = {
          enable = true;
          autoAttach = [ "1-1" "1-2" ];
        };

        wslConf.user.default = "nixos";

        # FIXME disabled until https://www.catalog.update.microsoft.com/Search.aspx?q=KB5020030, https://support.microsoft.com/en-us/topic/november-15-2022-kb5020030-os-builds-19042-2311-19043-2311-19044-2311-and-19045-2311-preview-237a9048-f853-4e29-a3a2-62efdbea95e2 https://devblogs.microsoft.com/commandline/the-windows-subsystem-for-linux-in-the-microsoft-store-is-now-generally-available-on-windows-10-and-11/, native systemd needs these versions
        # FIXME Disabled due to Windows Update 21.11.23
        nativeSystemd = true;
        # docker-native = { # https://github.com/573/nix-config-1/actions/runs/6403582504/job/17382383615#step:8:164, "Additional workarounds are no longer required for Docker to work. Please use the standard `virtualisation.docker` NixOS options."
        #  enable = true;
        #};
      };

      services = {
        syncthing = {
          enable = true;
          overrideFolders = true;
          overrideDevices = true;
          # see https://nixos.wiki/wiki/Syncthing
          user = "nixos";
          configDir = "/home/nixos/.config/syncthing";
          # https://search.nixos.org/options?channel=unstable&show=services.syncthing.settings&from=0&size=50&sort=alpha_asc&type=packages&query=services.syncthing
          settings = {
            options = {
              # https://docs.syncthing.net/users/faq.html#should-i-keep-my-device-ids-secret 
              announceLANAddresses = false;
              globalAnnounceEnabled = false;
	      # https://forum.syncthing.net/t/enable-nat-traversal-what-does-it-do/13044/4
              natEnabled = false;
            };
            devices = {
              "Newer Laptop" = {
                id = "FDBTMR3-XQDMU6L-AJF6WBP-WC65GPB-ZS67G4Q-7KWG3LY-2JGOSL7-Z4QUJQF";
              };
              "Phone" = {
                id = "A3G3H6Q-RF3GJOT-AXXJSNJ-ZZCC2WW-3R55I3Y-XR5EJD7-S6RQAXT-FI6HWA2";
                label = "SM-G950F";
              };
              "Older Lenovo" = {
                id = "JVIDDEN-NPYWDCO-V37UT56-ICT46YW-MIGUWO3-AHANFTX-LYJX7Y4-S5G7UQ2";
              };
            };
            folders = {
              "xbvei-t7pxz" = {
                devices = [ "Newer Laptop" "Phone" "Older Lenovo" ];
                path = "~/Musicupload";
                id = "xbvei-t7pxz";
                label = "Musicupload";
              };
              "v9gme-7b6ou" = {
                devices = [ "Newer Laptop" "Phone" "Older Lenovo" ];
                path = "~/lebenslauf-cv.git";
                id = "v9gme-7b6ou";
                label = "Lebenslauf Git-Dir";
              };
              "ph2s3-y0cec" = {
                devices = [ "Newer Laptop" "Phone" "Older Lenovo" ];
                path = "~/lebenslauf-cv";
                id = "ph2s3-y0cec";
                label = "Lebenslauf";
              };
              "n9duo-eqmww" = {
                devices = [ "Newer Laptop" "Phone" "Older Lenovo" ];
                path = "~/stories";
                id = "n9duo-eqmww";
                label = "Stories";
              };
              "7zqso-s3dap" = {
                devices = [ "Newer Laptop" "Phone" "Older Lenovo" ];
                path = "~/stories";
                id = "7zqso-s3dap";
                label = "Stories Git-Dir";
              };
            };
          };
        };
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

      environment.defaultPackages = [ pkgs.wslu ];

      # TODO idea: https://github.com/nix-community/NixOS-WSL/pull/203
      #      environment.systemPackages = [ pkgs.tailscale ];

      # see https://github.com/sakai135/wsl-vpnkit/blob/5084c6d/wsl-vpnkit.service
      # see flake/nixpkgs.nix regarding changes regarding Windows-Update 21.11.23
      systemd.services.wsl-vpnkit = {
        enable = true;
        description = "wsl-vpnkit";
        after = [ "network.target" ];
        #wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.wsl-vpnkit}/bin/wsl-vpnkit";
          Restart = "always";
          RestartSec = "30s";
          KillMode = "mixed";
        };
      };

      # https://github.com/nix-community/NixOS-WSL/issues/246#issuecomment-1577173622
      # to run: NIX_LD_LIBRARY_PATH=/usr/lib/wsl/lib/ /usr/lib/wsl/lib/nvidia-smi
      #programs.nix-ld.enable = true;
      # see  https://github.com/nix-community/NixOS-WSL/discussions/92
      programs.nix-ld = {
        enable = true;
        package = pkgs.nix-ld-rs;
        # TODO https://github.com/Mic92/dotfiles/blob/1b76848e2b5951bc9041af95a834a08b68e146fd/nixos/modules/nix-ld.nix
        libraries = with pkgs; [
          stdenv.cc.cc # for libstdc++.so.6
        ];
      };
      /*environment.variables = {
        NIX_LD_LIBRARY_PATH = lib.mkDefault (lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
        ]);
        #NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; #"${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
        NIX_LD = lib.mkDefault pkgs.stdenv.cc.bintools.dynamicLinker;
      };*/

      hardware.opengl = {
        enable = true;
        driSupport32Bit = true;
      };

      # FIXME Windows-Update 21.11.23
      #services.tailscale.enable = true;

      # https://github.com/nix-community/NixOS-WSL/discussions/71
      security.sudo.wheelNeedsPassword = true;
    })

  ]);

}
