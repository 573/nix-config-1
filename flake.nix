{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; #/635a306fc8ede2e34cb3dd0d6d0a5d49362150ed"; # nvim broken in 8d447c5626cfefb9b129d5b30103344377fe09bc, see https://github.com/573/nix-config-1/actions/runs/4960709342/jobs/8876554875#step:6:3671
    #unstable.url = "github:NixOS/nixpkgs/c4d0026e7346ad2006c2ba730d5a712c18195aab";
    latest.url = "github:NixOS/nixpkgs/master"; # "github:NixOS/nixpkgs/master";
    staging.url = "github:NixOS/nixpkgs/staging"; # "github:NixOS/nixpkgs/2acce7dfdcf382757e6fe219e04668e7a63bf48a";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nix-on-droid = {
      # if all fails, stick to ../../release-22.05 again
      url = "github:t184256/nix-on-droid";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-formatter-pack.follows = "nix-formatter-pack";
      inputs.nmd.follows = "nix-formatter-pack/nmd";
    };

    flake-utils.url = "github:numtide/flake-utils";

    virtual-types-nvim = {
      flake = false;
      url = "https://github.com/jubnzv/virtual-types.nvim/archive/9ef9f31c58cc9deb914ee728b8bda8f217f9d1c7.tar.gz";
    };

    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib"; # &rev=d321deb4a9b05e9d81b79ac166274f4a6e7981bf"; # the commit used in neovim-nightly-overlay itself, i. e. https://github.com/nix-community/neovim-nightly-overlay/commit/e5a94bb91c94dc079e7c714494a0be7814b51c6d
      # FIXME Gerschtli rather follows nixpkgs for all inputs, should I too ?
      #inputs.nixpkgs.follows = "unstable";
      #inputs.flake-utils.follows = "flake-utils";
    };

    # TODO https://github.com/nix-community/neovim-nightly-overlay/blob/89fdda1/flake.nix#L39
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      #inputs.nixpkgs.follows = "unstable";
      #inputs.flake-parts.follows = "flake-parts";
      #inputs.hercules-ci-effects.follows = "hercules-ci-effects";
      #inputs.flake-compat.follows = "flake-compat";
      #inputs.neovim-flake.follows = "neovim-flake";
    };

    code-runner-nvim = {
      flake = false;
      url = "https://github.com/CRAG666/code_runner.nvim/archive/7cdeb206520c5afb2bd7655da981a9bcdc3f43f8.tar.gz";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "unstable";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";
      # follows small
    };

    telescope-makefile = {
      flake = false;
      url = "github:ptethng/telescope-makefile";
    };

    markid = {
      flake = false;
      url = "github:David-Kunz/markid";
    };

    fsread-nvim = {
      flake = false;
      url = "github:nullchilly/fsread.nvim";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "unstable";
    };

    nix-filter = {
      url = "github:numtide/nix-filter";
    };

    nvim-treesitter = {
      flake = false;
      url = "github:nvim-treesitter/nvim-treesitter";
    };

    nvim-cmp = {
      flake = false;
      url = "github:hrsh7th/nvim-cmp";
    };

    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixGL = {
      url = "github:guibou/nixGL";
      # follows nixpkgs (master)
    };

    # follows nixpkgs (master)
    nix-index-database.url = "github:Mic92/nix-index-database";

    duck-nvim = {
      flake = false;
      url = "github:tamton-aquib/duck.nvim";
    };

    nvim-lspconfig = {
      flake = false;
      url = "github:neovim/nvim-lspconfig";
    };

    deferred-clipboard-nvim = {
      flake = false;
      url = "github:EtiamNullam/deferred-clipboard.nvim";
    };

    murmur-lua-nvim = {
      url = "github:nyngwang/murmur.lua";
      flake = false;
    };

    filetype-nvim = {
      url = "https://github.com/nathom/filetype.nvim/archive/b522628a45a17d58fc0073ffd64f9dc9530a8027.tar.gz";
      flake = false;
    };

    statusline-action-hints-nvim = {
      url = "github:roobert/statusline-action-hints.nvim";
      flake = false;
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
    };

    # TODO Does using a fixed rev avoid rebuilds after each flake update ?
    emacs-overlay = {
      #.url = "github:nix-community/emacs-overlay/ffab139d704bdec0c1d894f667c0fb9fe6261b80";
      url = "github:nix-community/emacs-overlay/791acfa700b9f96c35635fde2a17a66b4ed88c9e";
      #inputs.nixpkgs-stable.follows = "nixpkgs";
      #inputs.nixpkgs.follows = "unstable";
      #inputs.flake-utils.follows = "flake-utils";
    };

    tree-grepper = {
      url = "github:BrianHicks/tree-grepper";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    # nix 2.11 assumed, nix-build-uncached also seems not to like this https://github.com/573/nix-config-1/actions/runs/3550769213/jobs/5964441134
    #sanemacs = {
    #  url = "https://raw.githubusercontent.com/Open-App-Library/Sanemacs/master/sanemacs.el";
    #  flake = false;
    #};

    devenv.url = "github:cachix/devenv";

    # TODO Switch to https://github.com/frioux/pup or https://github.com/htmlparser/htmlparser, needs go fixes
    pup = {
      url = "github:ericchiang/pup/681d7bb639334bf485476f5872c5bdab10931f9a";
      flake = false;
    };

    yt-dlp = {
      url = "github:yt-dlp/yt-dlp";
      flake = false;
    };

    nil = {
      url = "github:oxalica/nil";
    };

    impermanence.url = "github:nix-community/impermanence";

    talon = {
      url = "github:nix-community/talon-nix";
      inputs.nixpkgs.follows = "unstable";
      inputs.utils.follows = "flake-utils";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "unstable";
    };

    nixified-ai = {
      url = "github:nixified-ai/flake";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-parts.follows = "flake-parts";
      inputs.hercules-ci-effects.follows = "hercules-ci-effects";
    };

    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "unstable";
    };

    jupyenv.url = "github:573/jupyenv-aarch64-experimental";

    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ocaml-overlay = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.nixpkgs.follows = "latest";
    };

    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      flake = false;
    };

    mach-nix = {
      url = "github:DavHau/mach-nix"; # ?ref=3.5.0
      inputs.nixpkgs.follows = "unstable";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };

    nixd = {
      url = "github:nix-community/nixd";
      #inputs.nixpkgs.follows = "unstable";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-formatter-pack
    , ...
    } @ inputs:
    let
      rootPath = self;
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
      flakeLib = import ./flake {
        inherit inputs rootPath forEachSystem;
      };

      formatterPackArgsFor = forEachSystem (system: {
        inherit nixpkgs system;
        checkFiles = [ self ];

        config.tools = {
          deadnix = {
            enable = true;
            noLambdaPatternNames = true;
          };
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      });

      inherit (nixpkgs.lib) listToAttrs;
      inherit (flakeLib) mkApp mkHome mkNixOnDroid mkNixos mkDevenvJvmLang mkDevenvDeno mkDevenvFlutter mkDevenvOcaml mkDevenvRust mkDevenvMachnix mkDevenvJupyenv;
    in
    {
      homeConfigurations = listToAttrs [
        (mkHome "x86_64-linux" "dani@maiziedemacchiato")
      ];

      nixOnDroidConfigurations = listToAttrs [
        (mkNixOnDroid "aarch64-linux" "sams9")
      ];

      nixosConfigurations = listToAttrs [
        (mkNixos "x86_64-linux" "DANIELKNB1")
      ];

      apps = forEachSystem (system:
        listToAttrs [
          (
            # TODO Also try https://github.com/IllustratedMan-code/tick_egg_paper/blob/bf14af5/flake.nix#L44
            let
              inherit (inputs.jupyenv.lib.${system}) mkJupyterlabNew;
              jupyterlab = mkJupyterlabNew ({ ... }: {
                nixpkgs = inputs.nixpkgs;
                imports = [
                  ({ pkgs, ... }: {
                    kernel.python.science = {
                      enable = true;
                    };
                    #kernel.ocaml.minimal-example = {
                    #  enable = true;
                    #};
                    #kernel.julia.minimal-example = {
                    #  enable = true;
                    #  julia = pkgs.julia-bin;
                    #};
                    kernel.rust.minimal-example = {
                      enable = true;
                    };
                  })
                ];
              });
            in
            {
              name = "jupyenv-app";
              value = {
                program = "${jupyterlab}/bin/jupyter-lab";
                type = "app";
              };
            }
          )

          (mkApp system "nixos-shell" {
            file = ./files/apps/nixos-shell.sh;
            path = pkgs: with pkgs; [ nixos-shell gawk jq git ];
          })

          (mkApp system "setup" {
            file = ./files/apps/setup.sh;
            path = pkgs: with pkgs; [ coreutils curl git gnugrep hostname jq nixVersions.unstable openssh ];
            envs._doNotClearPath = true;
          })

        ]
      );

      checks = forEachSystem (system:
        {
          nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgsFor.${system};

          /*          neovim-check-config = pkgs.runCommand "neovim-check-config"
            {
              buildInputs = [ pkgs.git self.nixosConfigurations.DANIELKNB1.pkgs.neovim ];

            } ''
                 	    mkdir -p "$out"

                        # prevent E886 ('/home-shelter' error)
                 	    export HOME=$TMPDIR
                 	    # presumes prior devenv shell run in ~/debugpy-devshell/, https://github.com/mfussenegger/nvim-dap-python/blob/408186a/README.md#debugpy
                 	    export VIRTUAL_ENV=/home/dkahlenberg/debugpy-devshell/.devenv/state/venv
                 	    nvim --headless +":scriptnames | q" 2> "$out/nvim.log"

                        if [ -n "$(cat "$out/nvim.log")" ]; then
                   	      echo "output: "$(cat "$out/nvim.log")""
                   	      exit 1
                 	    fi
          '';
           	  */
        });

      # use like:
      # $ direnv-init jdk11
      # $ lorri-init jdk11
      devShells = forEachSystem (system: listToAttrs [
        ({
          name = "nixd";
          value = inputs.nixd.devShells.${system}.default;
        })
        (
          let
            pkgs = import inputs.unstable { inherit system; };
          in
          rec {
            name = "playwright";
            value = inputs.devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                ({ pkgs, ... }: {
                  packages = with pkgs;[ nodejs playwright-test ];
                  env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
                  enterShell = ''
                    		    # Remove playwright from node_modules, so it will be taken from playwright-test
                                        rm node_modules/@playwright/ -R
                    		  '';
                })
              ];
            };
          }
        )
        (mkDevenvJupyenv system "jupyenv" { })
        (mkDevenvJvmLang system "jvmlanguages-devenv" { })
        (mkDevenvDeno system "deno" { })
        (mkDevenvFlutter system "flutter" { })
        (mkDevenvOcaml system "ocaml" { })
        #(mkDevenvRuby system "ruby" { })
        (mkDevenvRust system "rust" { })
        #(mkDevenvHaskell system "haskell" { })
        (mkDevenvMachnix system "machnix" { })
        #(mkDevenvJulia system "julia" { })
      ]);

      formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsFor.${system});

      nixosModules.nixos-shell-vm = import ./files/nix/nixos-shell-vm.nix rootPath;

      packages =
        let
          cachixSpecBuilder = pkgs: spec: pkgs.writeText "cachix-deploy.json" (builtins.toJSON spec);

          cachixDeployOutput = builder: name: module: {
            ${module.pkgs.system}."cachix-deploy-spec-${name}" = cachixSpecBuilder module.pkgs {
              agents.${name} = builder module;
            };
          };

          cachixDeployOutputHomeManager = cachixDeployOutput (module: module.activationPackage);
          cachixDeployOutputNixondroid = cachixDeployOutput (module: module.activationPackage);
          cachixDeployOutputNixos = cachixDeployOutput (module: module.config.system.build.toplevel);
        in
        nixpkgs.lib.foldl
          nixpkgs.lib.recursiveUpdate
          { }
          (nixpkgs.lib.mapAttrsToList cachixDeployOutputNixos self.nixosConfigurations
          ++ [ (cachixDeployOutputNixondroid "sams9" self.nixOnDroidConfigurations.sams9) (cachixDeployOutputHomeManager "maiziedemacchiato" self.homeConfigurations."dani@maiziedemacchiato") ]);

    } // {
      herculesCI = inputs.hercules-ci-effects.lib.mkHerculesCI { inherit inputs; } {
        # Values for flake-parts options may be written here, including
        # non-Hercules-CI options, but those will only take affect in CI and the `hci`
        # command.

        # Automatic flake updates
        hercules-ci.flake-update = {
          enable = true;
          createPullRequest = true;
          autoMergeMethod = "merge";
          updateBranch = "flake-update";
          when = {
            hour = [ 10 ];
            minute = 0;
            dayOfWeek = [ "Mon" "Wed" ];
          };
        };

        # Some modules have options in `perSystem`
        #perSystem = { system, hci-effects, ... } = {
        # Many flakes call Nixpkgs, to set some `config` or `overlays`.
        # If yours needs that, it's best to reuse your pkgs here. Example:
        # _module.args.pkgs = pkgsFor.${system};
        #};
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://arm.cachix.org"
      "https://cache.nixos.org"
      "https://gerschtli.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://cachix.cachix.org"
      "https://nix-community.cachix.org"
      #"https://niv.cachix.org"
      "https://573-bc.cachix.org"
      #"https://tweag-jupyter.cachix.org"
      "https://tree-grepper.cachix.org"
      "https://coq.cachix.org"
      "https://ai.cachix.org"
      "https://nixpkgs-ruby.cachix.org"
      #"https://anmonteiro.nix-cache.workers.dev"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "arm.cachix.org-1:K3XjAeWPgWkFtSS9ge5LJSLw3xgnNqyOaG7MDecmTQ8="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      #"niv.cachix.org-1:X32PCg2e/zAm3/uD1ScqW2z/K0LtDyNV7RdaxIuLgQM="
      "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs="
      #"tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g="
      "tree-grepper.cachix.org-1:Tm/owXM+dl3GnT8gZg+GTI3AW+yX1XFVYXspZa7ejHg="
      "coq.cachix.org-1:5QW/wwEnD+l2jvN6QRbRRsa4hBHG3QiQQ26cxu1F5tI="
      "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
      #"ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
}
