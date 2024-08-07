{
  # FIXME https://github.com/cafkafk/fortune-kind/blob/b8dd6073ed41e0823271e3a073587cc7f60167db/flake.nixpkgs
  # formatter and rime
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };

    ####### FIXME Start using https://github.com/cafkafk/rime here ##########
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-2305.url = "github:NixOS/nixpkgs/nixos-23.05";
    # nixpkgs-unstable is cached (also nixos-unstable). Those are basically "the latest snapshot of master to have everything built and cached".
    # FIXME Remove pin, when https://github.com/NixOS/nixpkgs/pull/276887 is reverted, it broke hm, see https://github.com/nix-community/home-manager/issues/4875
#    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # seems plausible: https://github.com/NixOS/flake-registry/blob/895a65f8d5acf848136ee8fe8e8f736f0d27df96/flake-registry.json#L301-L311
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # PR 276887 is reverted, so /b2e4fd1049a3e92c898c99adc8832361fa7e1397"; #/635a306fc8ede2e34cb3dd0d6d0a5d49362150ed"; # nvim broken in 8d447c5626cfefb9b129d5b30103344377fe09bc, see https://github.com/573/nix-config-1/actions/runs/4960709342/jobs/8876554875#step:6:3671
    #unstable.url = "github:NixOS/nixpkgs/c4d0026e7346ad2006c2ba730d5a712c18195aab";
    # latest is not cached, also github:NixOS/nixpkgs points to master/latest so no branch spec needed
    latest.url = "github:NixOS/nixpkgs"; # "github:NixOS/nixpkgs/master";
    # or rather (bc I basically only need simple-scan and sane-backends) : https://lazamar.co.uk/nix-versions/?package=sane-backends&version=1.0.32&fullName=sane-backends-1.0.32&keyName=sane-backends&revision=1732ee9120e43c1df33a33004315741d0173d0b2&channel=nixos-22.11#instructions ?
    nixos-2211.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-2211-small.url = "github:NixOS/nixpkgs/nixos-22.11-small";
    nixos-2311.url = "github:NixOS/nixpkgs/nixos-23.11";

    # TODO Is this up-to-date for release-23.11 still ? ghc cached based on nixpkgs-unstable (i. e. https://lazamar.co.uk/nix-versions/?package=ghc&version=9.4.6&fullName=ghc-9.4.6&keyName=ghc&revision=9957cd48326fe8dbd52fdc50dd2502307f188b0d&channel=nixpkgs-unstable#instructions)
    # see how-to: https://discourse.nixos.org/t/cache-for-other-ghc-versions/18511
    ghc-nixpkgs-unstable.url = "github:NixOS/nixpkgs/e1ee359d16a1886f0771cc433a00827da98d861c";

    libreoffice-postscript.url = "github:NixOS/nixpkgs/eb090f7b923b1226e8beb954ce7c8da99030f4a8";

    # https://github.com/NixOS/nixpkgs/pull/274799
    # https://lazamar.co.uk/nix-versions/?channel=nixos-22.11&package=simple-scan
    # https://discourse.nixos.org/t/binary-cache-for-staging/23813/4
    # https://discourse.nixos.org/t/when-does-staging-hit-release-channels/11892
    # https://discourse.nixos.org/t/release-process-staging-branches/2799/4
    #glib-issue.url = "github:NixOS/nixpkgs/staging-next";

    home-manager-latest = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "latest";
    };
    home-manager-2211 = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixos-2211";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

        catppuccin = {
	  url = "github:catppuccin/nix";
	};

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "unstable";
    };

    nix-on-droid = {
      # if all fails, stick to ../../release-23.05 again, although looking at
      # https://github.com/nix-community/nix-on-droid/blob/nix-community-move/flake.nix nix-on-droids inputs anyway seem to follow (as of Dec 1, 2023):
      # - nixpkgs master branch
      # - home-managers master branch overridden aforementioneds nixpkgs (that is currently nixos-unstable)
      # - nix-formatter-packs master branch overridden aforementioneds nixpkgs (that is currently release-22.11)
      url = "github:nix-community/nix-on-droid";
      inputs.home-manager.follows = "home-manager"; # I'm overriding master@de3758e31a3a1bc79d569f5deb5dac39791bf9b6 (Sep 23, 2022) here
      inputs.nixpkgs.follows = "nixpkgs"; # I'm overriding master@9c64b91d14268cf20ea07ea7930479a75325af9f (Sep 24, 2022) here
      inputs.nix-formatter-pack.follows = "nix-formatter-pack";
      inputs.nmd.follows = "nmd";
    };
    org-extra-emphasis = {
    url = "github:QiangF/org-extra-emphasis";
    flake = false;
    };
org-mode-ox-odt = {
  url = "github:kjambunathan/org-mode-ox-odt";
  flake = false;
};

      flatpaks.url = "github:gmodena/nix-flatpak/main";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO https://github.com/search?q=repo%3AGerschtli%2Fnix-config+%22+age+%22&type=code
   homeage = {
      url = "github:jordanisaacs/homeage";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #flake-utils.url = "github:numtide/flake-utils";

    "virtual-types.nvim" = {
      flake = false;
      url = "https://github.com/jubnzv/virtual-types.nvim/archive/9ef9f31c58cc9deb914ee728b8bda8f217f9d1c7.tar.gz";
    };

    /*neovim-flake = {
      url = "github:nix-community/neovim-nightly-overlay"; # &rev=d321deb4a9b05e9d81b79ac166274f4a6e7981bf"; # the commit used in neovim-nightly-overlay itself, i. e. https://github.com/nix-community/neovim-nightly-overlay/commit/e5a94bb91c94dc079e7c714494a0be7814b51c6d
      # FIXME Gerschtli rather follows nixpkgs for all inputs, should I too ?
      #inputs.nixpkgs.follows = "unstable";
      #inputs.flake-utils.follows = "flake-utils";
    };*/

    # TODO https://github.com/nix-community/neovim-nightly-overlay/blob/89fdda1/flake.nix#L39
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      #inputs.nixpkgs.follows = "unstable";
      #inputs.flake-parts.follows = "flake-parts";
      #inputs.hercules-ci-effects.follows = "hercules-ci-effects";
      #inputs.flake-compat.follows = "flake-compat";
      #inputs.neovim-flake.follows = "neovim-flake";
    };

    nmd.url = "git+https://git.sr.ht/~rycee/nmd?ref=master";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "unstable";
    };

    "hledger-completion.bash" = {
      flake = false;
      url = "github:simonmichael/hledger?dir=hledger/shell-completion";
    };

    hledger-bin = {
      flake = false;
      url = "github:simonmichael/hledger?dir=bin";
    };

    fsread-nvim = {
      flake = false;
      url = "github:nullchilly/fsread.nvim";
    };

    ruby-nix = {
      url = "github:inscapist/ruby-nix";
    };

    bundix = {
      url = "github:inscapist/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      #inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "unstable";
    };

    nix-filter = {
      url = "github:numtide/nix-filter";
    };

    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nmd.follows = "nmd";
    };

    nixGL = {
      url = "github:guibou/nixGL";
      # follows nixpkgs (master)
    };

    # follows nixpkgs (master)
    nix-index-database.url = "github:Mic92/nix-index-database";

    "deferred-clipboard.nvim" = {
      flake = false;
      url = "github:EtiamNullam/deferred-clipboard.nvim";
    };

    "filetype.nvim" = {
      url = "https://github.com/nathom/filetype.nvim/archive/b522628a45a17d58fc0073ffd64f9dc9530a8027.tar.gz";
      flake = false;
    };

    "action-hints.nvim" = {
      url = "github:roobert/action-hints.nvim";
      flake = false;
    };

    "garbage-day.nvim" = {
      url = "github:Zeioth/garbage-day.nvim";
      flake = false;
    };

    # FIXME broken, https://www.reddit.com/r/NixOS/comments/175w44g/broken_flake_sorta/
    nixos-wsl = {
      url ="github:nix-community/nixos-wsl";
      #url ="github:nix-community/nixos-wsl?ref=refs/tags/23.5.5.0";
      # pinning due to https://github.com/nix-community/NixOS-WSL/issues/470
      #url = "github:nix-community/nixos-wsl/0b90c1d982d443358b3f7b3a303405449a2bfe54";
      #url = "github:nix-community/nixos-wsl?ref=refs/pull/478/head"; # fix: set wsl.useWindowsDriver when the nvidia-ctk is enabled
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      #inputs.flake-utils.follows = "flake-utils";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/c051c42e3325ac62e9bf83e72e3868db1e5f2e64";
    };

    emacs-overlay-cached = {
      url = "github:nix-community/emacs-overlay/bbe883e60c65dd9254d010e98a1a8a654a26f9d8";
      #url = "github:nix-community/emacs-overlay/2308be4351ab8a152248a48baebf22649c83a487";
    };

    # nix 2.11 assumed, nix-build-uncached also seems not to like this https://github.com/573/nix-config-1/actions/runs/3550769213/jobs/5964441134
    #sanemacs_el = {
    #  url = "https://sanemacs.com/sanemacs.el";
    #  flake = false;
    #};

    sane-defaults = {
      url = "https://raw.githubusercontent.com/magnars/.emacs.d/master/settings/sane-defaults.el";
      flake = false;
    };

    sensible-defaults = {
      url = "https://raw.githubusercontent.com/hrs/sensible-defaults.el/main/sensible-defaults.el";
      flake = false;
    };

    yt-dlp = {
      url = "github:yt-dlp/yt-dlp";
      flake = false;
    };

    impermanence.url = "github:nix-community/impermanence";

    talon = {
      url = "github:nix-community/talon-nix";
      inputs.nixpkgs.follows = "unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "unstable";
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
      url = "github:nix-community/nixd?ref=2.0.2";
      #url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-parts.follows = "flake-parts";
    };

    org-novelist = {
      url = "github:sympodius/org-novelist";
      flake = false;
    };

    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
    };

    rust-dev-template = {
      url = "github:the-nix-way/dev-templates/1117b469aa83bef9e29616b7c67d80b14beb2c14?dir=rust"; # reason for pin: error: flake input attribute 'nixpkgs' is a thunk while a string, Boolean, or integer is expected :: meaning the url is resolved to *.tar.gz thus ?/dir= uri would not work yet
    };

    clojure-dev-template = {
      url = "github:the-nix-way/dev-templates?dir=clojure";
    };

    ocaml-dev-template = {
      url = "github:the-nix-way/dev-templates?dir=ocaml";
    };

    git-issue = {
      url = "github:dspinellis/git-issue";
      flake = false;
    };

    firefox-addons = { url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"; inputs.nixpkgs.follows = "nixpkgs"; };

    mistty = {
      url = "github:szermatt/mistty";
      flake = false;
    };

    wsl-vpnkit = {
      # misusing the github api a bit here, see https://docs.github.com/de/rest/pulls/pulls?apiVersion=2022-11-28#get-a-pull-request--code-samples, a ?ref= would not work, but hash is correctly resolved to pull/250/commits/hash
      url = "github:sakai135/wsl-vpnkit/6845578336b5bcc3484f23dce51c4f6ac37baba6"; #28992229fedfa64979faa9ec84b1b4bcf5c8f449"; #/?dir=pulls/250";
      flake = false;
    };

    google-chrome = {
      url = "github:r-k-b/browser-previews";
    };

    ghc-wasm-meta.url = "gitlab:ghc/ghc-wasm-meta/master?host=gitlab.haskell.org";

    zig2nix.url = "github:Cloudef/zig2nix";

    nix-ld-rs.url = "github:Mic92/nix-ld";
    nixvim-config.url = "github:MikaelFangel/nixvim-config";

    nixvim = {
      url = "github:nix-community/nixvim";
      #  inputs.nixpkgs.follows = "nixpkgs";
    };

    ghciwatch = {
      url = "github:MercuryTechnologies/ghciwatch";
    };

    nvim-dd = {
      url = "github:yorickpeterse/nvim-dd";
      flake = false;
    };

    nano-emacs = {
      url = "github:rougier/nano-emacs";
      flake = false;
    };

    faster-nvim = {
      url = "github:pteroctopus/faster.nvim";
      flake = false;
    };

    deadcolumn-nvim = {
      url = "github:Bekaboo/deadcolumn.nvim";
      flake = false;
    };

    nix-inspect.url = "github:bluskript/nix-inspect";

    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
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
          statix = {
            enable = true;
            disabledLints = [ "repeated_keys" ];
          };
        };

      });

      inherit (nixpkgs.lib) listToAttrs;
      inherit (flakeLib) mkApp mkHome mkNixOnDroid mkNixos mkDevenvJvmLang mkDevenvDeno mkDevenvFlutter mkDevenvOcaml mkDevenvRust mkDevenvMachnix mkDevenvJupyenv mkDevenvRuby mkDevenvHaskell mkDevenvRustWasm32;
    in
    {
      homeConfigurations = listToAttrs [
        (mkHome "aarch64-linux" "u0_a210@localhost")
        (mkHome "x86_64-linux" "dani@maiziedemacchiato")
      ];

      nixOnDroidConfigurations = listToAttrs [
        (mkNixOnDroid "aarch64-linux" "sams9")
      ];

      nixosConfigurations = listToAttrs [
        (mkNixos "x86_64-linux" "DANIELKNB1")
        (mkNixos "aarch64-linux" "twopi")
      ];

      apps = forEachSystem (system:
        (listToAttrs [
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

          (mkApp system "nvim" rec {
            file = builtins.toFile "file" ''
              	    source @bashLib@
              	    nvim
              	    '';
            path = pkgs: with pkgs; (map (x: "${x.custom.programs.neovim.lightweight.outPath}") ((
              let inherit (pkgs.stdenv) isLinux isx86_64; in lib.optionals (isLinux && isx86_64) [
                self.nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos
                self.homeConfigurations."dani@maiziedemacchiato".config
              ]
            ) ++ (
              let inherit (pkgs.stdenv) isLinux isAarch64; in lib.optionals (isLinux && isAarch64) [
                self.nixOnDroidConfigurations.sams9.config.home-manager.config
              ]
            )));
          })

          ({
            name = "nixvim";
            value = let pkgs = inputs.nixpkgs.legacyPackages.${system}; in {
              program = builtins.toString (pkgs.writeShellScript "testnixvim" ''
                	        ${self.inputs.nixvim.packages."${system}".default}/bin/nvim
                	      '');
              type = "app";
            };
          })

          (mkApp system "emacs" rec {
            file = builtins.toFile "file" ''
              	    source @bashLib@
              	    emacs
              	    '';
            path = pkgs: with pkgs; (map (x: "${x.custom.programs.emacs.finalPackage.outPath}") ((
              let inherit (pkgs.stdenv) isLinux isx86_64; in lib.optionals (isLinux && isx86_64) [
                self.nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos
                self.homeConfigurations."dani@maiziedemacchiato".config
              ]
            ) ++ (
              let inherit (pkgs.stdenv) isLinux isAarch64; in lib.optionals (isLinux && isAarch64) [
                self.nixOnDroidConfigurations.sams9.config.home-manager.config
              ]
            )));
          })

          (mkApp system "nixos-shell" {
            file = ./files/apps/nixos-shell.sh;
            path = pkgs: with pkgs; [ nixos-shell gawk jq git ];
          })

          (mkApp system "setup" {
            file = ./files/apps/setup.sh;
            path = pkgs: with pkgs; [ coreutils curl git gnugrep hostname jq nixVersions.nix_2_19 openssh ];
            envs._doNotClearPath = true;
          })

        ]) // {
          nilApp = null;
        }
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
            pkgs = inputs.unstable.legacyPackages.${system};
          in
          rec {
            # TODO https://github.com/thenbe/neotest-playwright for configuration
            name = "playwright";
            value = inputs.devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                ({ pkgs, ... }: {
                  packages = with pkgs;[ nodejs playwright-test playwright-driver.browsers ];
                  env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
                  env.PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs}/bin/node";
                  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = 1;
                  enterShell = ''
                    		    # Remove playwright from node_modules, so it will be taken from playwright-test
                                        rm node_modules/@playwright/ -R
                    		  '';
                })
              ];
            };
          }
        )
        # AFAIU the pkgs used herein (mkDevenv*) are with the overlays as in flake/nixpkgs.nix etc. applied, also means any derivation defined therein can be used here then, but is a different derivation than i. e. some binary-cached elsewhere, which can lead to subtle differences i. e. (un)expected rebuilds. To use a binary-cached flake define here directly in flake.nix and add overlays when needed only.
        (mkDevenvJupyenv system "jupyenv" { })
        (mkDevenvJvmLang system "jvmlanguages-devenv" { })
        (mkDevenvDeno system "deno" { })
        (mkDevenvFlutter system "flutter" { })
        # TODO https://github.com/c-cube/iter
        (mkDevenvOcaml system "ocaml" { })
        (mkDevenvRuby system "ruby" { })
        (mkDevenvRust system "rust" { })
        (mkDevenvRustWasm32 system "rustwasm32" { })
        (mkDevenvHaskell system "haskell" { })

        (mkDevenvMachnix system "machnix" { })
        #(mkDevenvJulia system "julia" { })
      ] // ({
        # based on this https://github.com/cachix/devenv/pull/667#issuecomment-1656811711
        rustyShell =
          let
            # FIXME https://discourse.nixos.org/t/unexpected-11h-build-after-auto-update/39907/9
            pkgs = import inputs.unstable {
              inherit system;
              overlays =
                (map (x: x.overlays.default) [
                  inputs.rust-overlay
                  # see https://github.com/nix-community/fenix#usage (as a flake)
                  inputs.fenix
                ])
              ;
            };
            rustVersion = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
            #aarch64-binutils = pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc;
            #x86_64-binutils = pkgs.pkgsCross.gnu64.stdenv.cc;
          in
          inputs.devenv.lib.mkShell rec {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, ... }: {
                languages.rust = {
                  enable = true;
                  toolchain.rustc = (rustVersion.override {
                    extensions = [ "rust-src" "rust-analyzer" ];
                    targets = [ /*"x86_64-unknown-linux-gnu" "aarch64-unknown-linux-gnu"*/ "wasm32-unknown-unknown" ];
                  });
                };

                /*packages = [
                  pkgs.libunwind
                  aarch64-binutils
                ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk; [
                  frameworks.Security
                  frameworks.CoreFoundation
                  x86_64-binutils
                ]);*/
              })
            ];
          };
        pythonShell =
          let
            pkgs = inputs.unstable.legacyPackages.${system}; #import inputs.unstable { inherit system; };
            # see https://discourse.nixos.org/t/help-using-poetry-in-a-flake-devshell/36874/3
            mypython = pkgs.python311.withPackages (p: with p; [
              sqlglot
              # https://medium.com/social-impact-analytics/extract-text-from-unsearchable-pdfs-for-data-analysis-using-python-a6a2ca0866dd
              pymupdf
              pdf2image
              opencv4
              pytesseract
              ocrmypdf
              pandas
              numpy
            ]);
          in
          pkgs.mkShell {
            packages = [ mypython ];
          };
        agda =
          let
            pkgs = inputs.ghc-nixpkgs-unstable.legacyPackages.${system}; #import inputs.ghc-nixpkgs-unstable { inherit system; };
            myagda = (pkgs.agdaPackages.override {
              Agda = pkgs.haskellPackages.Agda.overrideAttrs { };
            }).agda.withPackages (p: with p; [ standard-library ]);
          in
          pkgs.mkShell {
            packages = [ myagda ];
          };
        # https://github.com/NixOS/nixpkgs/blob/9e860e4/pkgs/development/lisp-modules/shell.nix
        clShell = let pkgs = inputs.unstable.legacyPackages.${system}; in        #import inputs.unstable { inherit system; }; in
          pkgs.mkShell {
            nativeBuildInputs = [
              (pkgs.sbcl.withPackages
                (ps: with ps; [
                  alexandria
                  str
                  dexador
                  cl-ppcre
                  sqlite
                  arrow-macros
                  jzon
                ]))
            ];
          };
        # https://github.com/tweag/ormolu/blob/74887f00137d6cd91811440325c3ac330a371b2c/ormolu-live/default.nix
        ghcWasmShell =
          let
            pkgs = inputs.unstable.legacyPackages.${system}; #import inputs.unstable { inherit system; };
          in
          pkgs.mkShell {
            packages = [ inputs.ghc-wasm-meta.packages.${system}.all_9_8 ];
          };
        # try https://github.com/cachix/devenv/issues/585
        haskellShell =
          let
            hiPrio = pkg: pkgs.lib.updateManyAttrsByPath (builtins.map (output: { path = [ output ]; update = pkgs.hiPrio; }) pkg.outputs) pkg;
            pkgs = inputs.ghc-nixpkgs-unstable.legacyPackages.${system}; #import inputs.ghc-nixpkgs-unstable { inherit system; };
            stack = hiPrio (inputs.unstable.legacyPackages.${system}.stack);
          in
          inputs.devenv.lib.mkShell rec {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, ... }:
                {
                  packages = [
                    (inputs.ghciwatch.packages.${system}.default)
                    stack # still the stack from ghc-nixpkgs-unstable seemingly
                    pkgs.hledger
                  ];

                  languages.haskell = {
                    enable = true;
                    package = pkgs.haskell.packages.ghc946.ghcWithHoogle (pset: with pset; [
                      # libraries
                      #zlib
                      #arrows
                      #async
                      # cgi # marked broken
                      #criterion
                      # tools
                      #cabal-install
                      shake
                      # see this also: https://nixos.wiki/wiki/Haskell#Using_Stack_.28no_nix_caching.29
                      # stack # stack of ghc-nixpkgs-unstable is too old
                    ]);
                  };
                })
            ];
          };
        # https://github.com/NixOS/nixpkgs/blob/9e860e4/pkgs/development/lisp-modules/shell.nix
        zigShell = inputs.zig2nix.devShells.${system}.default;
        rustShell = inputs.rust-dev-template.devShells.${system}.default;
        cljShell = inputs.clojure-dev-template.devShells.${system}.default;
        ocamlShell = inputs.ocaml-dev-template.devShells.${system}.default;
        cudaShell =
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              # FIXME https://discourse.nixos.org/t/too-dumb-to-use-allowunfreepredicate/39956/17
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
            };
          in
          pkgs.mkShell {
            buildInputs =
              [
                pkgs.python310
                #pkgs.python38Packages.pytorch
                pkgs.python310Packages.pytorch-bin
              ];

            shellHook = ''
              export LD_LIBRARY_PATH=/usr/lib/wsl/lib
            '';
          };
        yaocaml =
          let
            pkgs = inputs.unstable.legacyPackages.${system}; #import inputs.unstable { inherit system; };
          in
          pkgs.mkShell {
            packages = with pkgs; [ ocaml ocamlformat opam ] ++
              (with pkgs.ocamlPackages; [
                ocaml
                findlib
                dune_3
                odoc
                ocaml-lsp
                merlin
                utop
                ocp-indent
                janeStreet.async
                janeStreet.base
                janeStreet.core_unix
                janeStreet.ppx_let
              ]);
          };
      }));

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
          {
            aarch64-linux = {
              rpi-firmware = import ./files/nix/rpi-firmware.nix { inherit nixpkgs; };
              rpi-image = import ./files/nix/rpi-image.nix { inherit nixpkgs rootPath; };
            };
            armv7l-linux = {
	      # TODO try https://github.com/n8henrie/nixos-btrfs-pi/blob/master/flake.nix
	      # also https://discourse.nixos.org/t/run-nixos-rpi4-image-arm-sd-image-by-qemu-emulation/33946/10
	      # plus for dtb part https://discourse.nixos.org/t/run-nixos-rpi4-image-arm-sd-image-by-qemu-emulation/33946
	      # nix build .#rpi-run-in-vm
	      run-in-vm = import ./files/nix/run-in-vm.nix { inherit nixpkgs rootPath; };
	    };

	    x86_64-linux.installer-image = import ./files/nix/installer-image.nix { inherit nixpkgs; };
	  }
          (nixpkgs.lib.mapAttrsToList cachixDeployOutputNixos self.nixosConfigurations
            ++ [ (cachixDeployOutputNixondroid "sams9" self.nixOnDroidConfigurations.sams9) (cachixDeployOutputHomeManager "maiziedemacchiato" self.homeConfigurations."dani@maiziedemacchiato") ])
	  ;
    };

  nixConfig = {
    # FIXME requires --accept-flake-config but might be better for nix develop
    #extra-substituters = [
    #    "https://arm.cachix.org/"
    #];
    #extra-trusted-public-keys = [
    #    "arm.cachix.org-1:K3XjAeWPgWkFtSS9ge5LJSLw3xgnNqyOaG7MDecmTQ8="
    #];
  };
}
