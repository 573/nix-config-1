/**
  Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

  For `[haskellPackages]` parameter determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{
  config,
  lib,
  pkgs,
  libreoffice-postscript,
  rootPath,
  unstable,
  nixos-unstable,
  inputs,
  homeDir,
  withNps,
  ...
}:
let
  inherit (lib)
    attrValues
    mkDefault
    ;
  inherit (pkgs)
    writeScriptBin
    runtimeShell
    ;
  # different approach here: https://pmiddend.github.io/posts/nixgl-on-ubuntu
  ausweisapp = config.lib.custom.wrapProgram {
    name = "ausweisapp";
    source = pkgs.ausweisapp;
    path = "/bin/AusweisApp";
    #   fixGL = true;
  };
in
/**
  Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

  If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
*/
#inherit (pkgs.stdenv.hostPlatform) system;
{

  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      non-nixos.enable = true;
    };

    development = {
      nix.home-manager.enable = true;
    };

    programs = {
      sops-nix.enable = true;

      # nix-podman-stacks.enable = true;

      shell.initExtra = ''
        #. ${config.home.homeDirectory}/.aliases.sh
      '';

      #hledger.enable = true;

      audio.enable = true;

      #arbtt.enable = true;

      #zellij.enable = true;

      #alacritty.enable = true;

      #mpv.enable = true;

      nixbuild.enable = true;

      neovim = {
        enable = true;
        # TODO should user- and hostname be rather module params
        nixd.expr.home-manager = ''
          	(builtins.getFlake "${inputs.self}").homeConfigurations."dani@maiziedemacchiato".options
        '';
      };
    };
  };

  programs.keepassxc.enable = true;

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
  };

  #xsession = {
  #  enable = true;
  #  # the default is fine here, then I only need to create ~/.xsession file in Archlinux
  #  windowManager.i3 = {
  #    enable = true;
  #  };
  #};

  # slock needs group "nogroup" to work, https://www.reddit.com/r/suckless/comments/qpupu2/slock_doesnt_work_if_compiled_from_git/hk0qz3l/
  #  home.activation = {
  #    alertNoGroup = ''
  #      ${pkgs.getent}/bin/getent group nogroup || echo Please run groupadd nogroup for slock to work !
  #    '';
  #  };

  #  news = {
  #  display = "show";
  #  entries = [
  #      {
  #    gg    time = "2023-09-14T14:04:00+00:00";
  #        message = ''
  #	slock⋅needs⋅group⋅"nogroup"⋅to⋅work,⋅https://www.reddit.com/r/suckless/comments/qpupu2/slock_doesnt_work_if_compiled_from_git/hk0qz3l/
  #
  #	Run the following to test if the system is prepared:
  #	${pkgs.getent}/bin/getent⋅group⋅nogroup⋅||⋅echo⋅Please⋅run⋅groupadd⋅nogroup⋅for⋅slock⋅to⋅work⋅!
  #	'';
  #	}
  #	];
  #	};

  home = {
    enableDebugInfo = false; # Enabled that for https://github.com/NixOS/nixpkgs/issues/271991
    homeDirectory = homeDir;
    username = "dani";

    packages = attrValues {
      # FIXME error: gnome2.pango (overlay ?)
      #inherit (inputs.talon.packages.x86_64-linux) default;
      # with pkgs; [
      inherit (pkgs)
        shellharden
        shfmt
        abcde
        cups-filters
        autorandr
        mons
        maim
        xdotool
        xclip
        # on archlinux not working anymore as wpa_supplicant on archlinux that
        # is used with netctl brings its own pcsclite package thus breaking
        # either wpa_supplicant (pacman) or keepassxc yubikey (nix)
        # maybe numtide/system-manager will solve that problem (also use
        # home-manager option then)
        # for now will use pacman managed keepassxc
        #keepassxc
        arandr
        xterm
        # TODO https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/ https://wiki.hyprland.org/Nix/Hyprland-on-other-distros/ https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/8 https://wiki.archlinux.org/title/Display_manager
        pcmanfm
        #chafa
        #simple-scan # memory error, potential workaround: https://github.com/NixOS/nixpkgs/issues/149812
        #tint2 # rather use at service definition themselves
        #simple-scan # DONT bc simple-scan requires sane-backends which in turn requires udev rules to be in place for the scanner to be detected, so on non-nixos installations of home-manager this simply cannot work. also a mix of non-nixos host provided sane-backends vs simple-scan will not work, rather using host's simple-scan until https://github.com/NixOS/nixpkgs/issues/271989 gets recognition
        #sane-frontends.out
        # sane-backends only "worked" due to leftover udev files from a non-nixos host provided sane installation I removed without rebooting and so tricked the system into belief it had scanner access via standalone home-manager
        # paths only seem to be there but aren't in use (version 1.0.32 of sane-backends in nixos-22.11)
        # ls $(dirname $(realpath $(which scanimage)))/../etc/udev
        # ls $(dirname $(realpath $(which scanimage)))/../sbin
        #sane-backends # DONT bc simple-scan requires sane-backends which in turn requires udev rules to be in place for the scanner to be detected, so on non-nixos installations oof home-manager this simply cannot work. also a mix of non-nixos host provided sane-backends vs simple-scan will not work
        #ocrfeeder # import pdf dialog crashes, broken on NixOS-WSL as well
        ##pdfsandwich # archlinux rather, gscan2pdf, ocrmypdf
        # TODO cuneiform build broken in 26.05
	#cuneiform
        normcap
        ##gImageReader # archlinux rather
        gdb
        #libreoffice-qt.out
        libcdio-paranoia
        #mpvScripts.chapterskip
        #mpvScripts.quality-menu
        source-code-pro
        #spotify-player
        #gtt
        notepad-next
        reader
        ;

      inherit (nixos-unstable)
        tutanota-desktop
        ;

      inherit (unstable)
        tesseract
        ocrmypdf
        #teams-for-linux
        ;

      inherit (pkgs.usbutils)
        out
        ;

      inherit (pkgs)
        libxcvt
        xrandr
        ;

      #inherit (libreoffice-postscript)
      #  libreoffice
      #  ;

      # see: https://github.com/nix-community/home-manager/issues/605#issuecomment-1678754229
      # see: https://discourse.nixos.org/t/latest-update-breaks-nerdfonts-declared-in-home-manager/57244/8
      nerdfonts = pkgs.nerd-fonts.ubuntu-mono; # TODO nerd-fonts.monaspace

      ausweisapp = config.lib.nixGL.wrap ausweisapp;
    };

    sessionPath = [
      #"${config.home.homeDirectory}/projects/sedo/devops-scripts/bin"
    ];

    #sessionVariables = {
    #  # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
    #  LOCALE_ARCHIVE_2_11 = mkDefault "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
    #  LOCALE_ARCHIVE_2_27 = mkDefault "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
    #};
  };

  # not started as of release-23.05
  #programs.tint2 = {
  #  enable = true;
  #  extraConfig = ''
  #    # are we enabled ?
  #  '';
  #};

  fonts.fontconfig.enable = true;

  xdg.enable = true;

  # templates (arch linux) in /etc/xdg/openbox/ (autostart and also rc.xml which is for key shortcuts)
  # TODO read https://konfou.xyz/posts/nixos-without-display-manager/
  xdg.configFile = {
    "openbox/rc.xml".source = "${rootPath}/home/openbox/rc.xml";

    "openbox/autostart".text = ''
      # FIXME rather store path ? https://search.nixos.org/packages?query=pcmanfm or https://search.nixos.org/packages?query=pcmanfm-qt
      ${pkgs.pcmanfm}/bin/pcmanfm -d &

       ${pkgs.tint2}/bin/tint2 &

      # only archlinux' version of xsecurelock has suid bit set
      # still DONT I'll use the home-manager managed user systemd service here
      #xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &
      systemctl start --user xss-lock
    '';
  };

  #  nix.package = pkgs.nixVersions.nix_2_33;

  # https://github.com/google/xsecurelock/issues/102#issuecomment-621432204
  #home.sessionVariables.XSECURELOCK_PAM_SERVICE = "lxdm";

  # see https://sourcegraph.com/github.com/thiagokokada/nix-configs@e9980c5b31c1aae55c5cb9465fb15137349f7680/-/blob/home-manager/desktop/i3/screen-locker.nix?L24:13
  services.screen-locker = {
    enable = true;
    lockCmdEnv = [
      "XSECURELOCK_PAM_SERVICE=lxdm"
    ];
    xautolock.enable = false;
    lockCmd = "xsecurelock";
    xss-lock.extraOptions = [
      "-n /usr/lib/xsecurelock/dimmer"
      "-l"
    ];
  };

  news.entries = [
    {
      time = "2025-11-15T14:04:00+00:00";
      condition = true; # builtins.pathExists config.home.file.".local/share/PowerShell/Home-Manager-Managed.ps1".source;
      message = ''
        	  hm-managed screen-locker uses the archlinux managed xsecurelock, as only the latter has suid bit set
        	'';
    }
  ];

  # https://github.com/Tarow/nix-podman-stacks/blob/22fba5ab55fdbd1a6c0e7d8985c9a2983204bc3d/modules/extension.nix#L294
  # https://github.com/Tarow/nix-podman-stacks/blob/main/modules/paperless/default.nix
  services.podman = {
    enable = true;
    settings.containers.network.dns_bind_port = 1153;
  };

  systemd.user.sockets.podman = {
    Install.WantedBy = [ "sockets.target" ];
    Socket = {
      SocketMode = "0660";
      ListenStream = "/run/user/1000/podman/podman.sock";
    };
  };
  systemd.user.services.podman = {
    Install.WantedBy = [ "default.target" ];
    Service = {
      Delegate = true;
      Type = "exec";
      KillMode = "process";
      Environment = [ "LOGGING=--log-level=info" ];
      ExecStart = "${lib.getExe pkgs.podman} $LOGGING system service";
    };
  };

  services.podman.containers =
    let
      name = "paperless";
      dbName = "${name}-db";
      brokerName = "${name}-broker";
      socketProxy = "docker-socket-proxy";
      gotenbergName = "${name}-gotenberg";
      tikaName = "${name}-tika";

      storage = "${config.home.homeDirectory}/stacks/${name}";

      category = "General";
      description = "Document Management System";
      displayName = "Paperless-ngx";
      # See <https://docs.paperless-ngx.com/administration/#create-superuser>
      secretKeyFile = config.sops.secrets."paperless/secret_key".path;
      db.passwordFile = config.sops.secrets."paperless/db_password".path;
      hostIP4Address = "0.0.0.0"; # "0.0.0.0";
      # TODO use uid
      hostUid = 1000;
      storageBaseDir = "${config.home.homeDirectory}/stacks";
      # FIXME better place
      externalStorageBaseDir = "/tmp";
    in
    {
         /* ${socketProxy} = {
          image = "ghcr.io/tecnativa/docker-socket-proxy:v0.4.2";

          volumes = [ "/run/user/1000/podman/podman.sock:/var/run/docker.sock:ro" ];

            extraConfig = {
              Unit = {
          Requires = ["podman.socket"];
          };
          };

          environment = {
            CONTAINERS = 1;
            SERVICES = 1;
            TASKS = 1;
            INFO = 1;
            IMAGES = 1;
            NETWORKS = 1;
            VERSION = 1;
            PING = 1;
            EVENTS = 1;
            CONFIGS = 1;
            POST = 0;
          };

          ports = [ "2375:2375" ];
        };
	*/

      ${name} = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.15";

        extraConfig = {
          Unit = {
            Requires = [
              dbName
              brokerName
            ];
            StartLimitIntervalSec = "120";
            StartLimitBurst = 5;
                Wants = [ "sops-nix.service" ];
                After = [ "sops-nix.service" ];
          };

          Service = {
            RestartSec = "5s";
          };

          #Container.UserNS = true;
        };

network = "paperless";

        volumes = [
          "${storage}/data:/usr/src/paperless/data"
          "${storage}/media:/usr/src/paperless/media"
          "${storage}/export:/usr/src/paperless/export"
          "${storage}/consume:/usr/src/paperless/consume"
          "${db.passwordFile}:${db.passwordFile}"
          "${secretKeyFile}:${secretKeyFile}"
          "${config.sops.secrets."paperless/admin_password".path}:${
            config.sops.secrets."paperless/admin_password".path
          }"
        ];
        environment = {
          PAPERLESS_REDIS = "redis://${brokerName}:6379";
          PAPERLESS_DBHOST = dbName;
          USERMAP_UID = 0;
          USERMAP_GID = 0;
          PAPERLESS_TIME_ZONE = "Etc/UTC";
          PAPERLESS_FILENAME_FORMAT = "{{created_year}}/{{correspondent}}/{{title}}";
          #PAPERLESS_URL = config.services.podman.containers.${name}.traefik.serviceUrl;
          PAPERLESS_DBUSER = "paperless";
          PAPERLESS_DBPASS_FILE = db.passwordFile;
          PAPERLESS_SECRET_KEY_FILE = secretKeyFile;
          PAPERLESS_ADMIN_USER = "admin";
          PAPERLESS_ADMIN_MAIL = "admin@example.com";
          PAPERLESS_ADMIN_PASSWORD_FILE = config.sops.secrets."paperless/admin_password".path;

          #PAPERLESS_TIKA_ENABLED = true;
          #PAPERLESS_TIKA_ENDPOINT = "http://${tikaName}:9998";
          #PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://${gotenbergName}:3000";
        };

        ports = [ "8000:8000" ];

      };

      ${brokerName} = {
        image = "docker.io/redis:8.0";
	network = "paperless";
	};

      ${dbName} = {
        image = "docker.io/postgres:16";
        environment = {
          POSTGRES_DB = "paperless";
          POSTGRES_USER = "paperless";
          #PGPASSFILE = db.passwordFile;
          POSTGRES_PASSWORD_FILE = db.passwordFile;
        };
	network = "paperless";
        volumes = [
          "${db.passwordFile}:${db.passwordFile}"
          "${storage}/db:/var/lib/postgresql/data"
        ];
        # https://github.com/Tarow/nix-podman-stacks/blob/22fba5ab55fdbd1a6c0e7d8985c9a2983204bc3d/modules/extension.nix#L163
        #env.POSTGRES_PASSWORD = db.passwordFile;

      };
      /*
            ${tikaName}.image = "docker.io/apache/tika:3.3.1.0";

            ${gotenbergName} = {
              image = "docker.io/gotenberg/gotenberg:8.34.0";
              exec = "gotenberg --chromium-disable-javascript=true --chromium-allow-list=file:///tmp/.*";
            };
      */
    };
  
    services.podman.networks.paperless = {
          driver = "bridge";
        };
  
  /*
    # see https://github.com/nix-community/home-manager/pull/4801
    services.podman.networks.caddy_routing = {
      driver = "bridge";
      subnet = "172.21.1.0/24";
    };

    services.podman.containers.caddy = {
      image = "ghcr.io/n-hass/caddy-cloudflare:latest";
      description = "Caddy web server";
      environmentFile = [ "${homeDir}/caddy/.env" ];
      network = [ "caddy_routing" ];
      networkAlias = [ "caddy" ];
      ports = [
        "8080:82"
        "8443:443"
      ];
      volumes = [
        "${homeDir}/caddy/Caddyfile:/etc/caddy/Caddyfile:ro"
        "${homeDir}/caddy/config:/config"
        "${homeDir}/caddy/data:/data"
      ];
      autoUpdate = "registry";
      extraConfig.Service = {
        TimeoutStopSec = 60;
      };
      addCapabilities = [ "NET_RAW" ];
    };
  */
}
