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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-2305.url = "github:NixOS/nixpkgs/nixos-23.05";
    # nixpkgs-unstable is cached (also nixos-unstable). Those are basically "the latest snapshot of master to have everything built and cached".
    # FIXME Remove pin, when https://github.com/NixOS/nixpkgs/pull/276887 is reverted, it broke hm, see https://github.com/nix-community/home-manager/issues/4875
    #    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # seems plausible: https://github.com/NixOS/flake-registry/blob/895a65f8d5acf848136ee8fe8e8f736f0d27df96/flake-registry.json#L301-L311
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # PR 276887 is reverted, so /b2e4fd1049a3e92c898c99adc8832361fa7e1397"; #/635a306fc8ede2e34cb3dd0d6d0a5d49362150ed"; # nvim broken in 8d447c5626cfefb9b129d5b30103344377fe09bc, see https://github.com/573/nix-config-1/actions/runs/4960709342/jobs/8876554875#step:6:3671
    #unstable.url = "github:NixOS/nixpkgs/c4d0026e7346ad2006c2ba730d5a712c18195aab";
    # latest is not cached, also github:NixOS/nixpkgs points to master/latest so no branch spec needed
    latest.url = "github:NixOS/nixpkgs"; # "github:NixOS/nixpkgs/master";
    # or rather (bc I basically only need simple-scan and sane-backends) : https://lazamar.co.uk/nix-versions/?package=sane-backends&version=1.0.32&fullName=sane-backends-1.0.32&keyName=sane-backends&revision=1732ee9120e43c1df33a33004315741d0173d0b2&channel=nixos-22.11#instructions ?
    nixos-2211.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-2211-small.url = "github:NixOS/nixpkgs/nixos-22.11-small";
    nixos-2311.url = "github:NixOS/nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # FIXME broken, https://www.reddit.com/r/NixOS/comments/175w44g/broken_flake_sorta/
    # https://github.com/nix-community/NixOS-WSL/discussions/735
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/release-25.05";
      #url ="github:nix-community/nixos-wsl?ref=refs/tags/23.5.5.0";
      # pinning due to https://github.com/nix-community/NixOS-WSL/issues/470
      #url = "github:nix-community/nixos-wsl/0b90c1d982d443358b3f7b3a303405449a2bfe54";
      #url = "github:nix-community/nixos-wsl?ref=refs/pull/478/head"; # fix: set wsl.useWindowsDriver when the nvidia-ctk is enabled
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      #inputs.flake-utils.follows = "flake-utils";
    };

    home-manager-latest = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "latest";
    };
    home-manager-2211 = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixos-2211";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "unstable";
      };
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";

    #quadlet-nix = {
    #  url = "github:SEIAROTg/quadlet-nix";
    #};

    nps.url = "github:Tarow/nix-podman-stacks";

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      # Make sure to override the nixpkgs version to follow your flake,
      # otherwise derivation paths can mismatch (when using storageMode = "derivation"),
      # resulting in the rekeyed secrets not being found!
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Firefox style
    #penguin-fox = {
    #  url = "github:p3nguin-kun/pengufox";
    #  flake = false;
    #};

    # TODO Is this up-to-date for release-23.11 still ? ghc cached based on nixpkgs-unstable (i. e. https://lazamar.co.uk/nix-versions/?package=ghc&version=9.4.6&fullName=ghc-9.4.6&keyName=ghc&revision=9957cd48326fe8dbd52fdc50dd2502307f188b0d&channel=nixpkgs-unstable#instructions)
    # see how-to: https://discourse.nixos.org/t/cache-for-other-ghc-versions/18511
    # https://lazamar.co.uk/nix-versions/?package=hledger&version=1.41&fullName=hledger-1.41&keyName=haskellPackages.hledger_1_41&revision=21808d22b1cda1898b71cf1a1beb524a97add2c4&channel=nixpkgs-unstable#instructions
    ghc-nixpkgs-unstable.url = "github:NixOS/nixpkgs/c792c60b8a97daa7efe41a6e4954497ae410e0c1"; # 05bbf675397d5366259409139039af8077d695ce"; # e1ee359d16a1886f0771cc433a00827da98d861c";

    libreoffice-postscript.url = "github:NixOS/nixpkgs/eb090f7b923b1226e8beb954ce7c8da99030f4a8";

    # https://github.com/NixOS/nixpkgs/pull/274799
    # https://lazamar.co.uk/nix-versions/?channel=nixos-22.11&package=simple-scan
    # https://discourse.nixos.org/t/binary-cache-for-staging/23813/4
    # https://discourse.nixos.org/t/when-does-staging-hit-release-channels/11892
    # https://discourse.nixos.org/t/release-process-staging-branches/2799/4
    #glib-issue.url = "github:NixOS/nixpkgs/staging-next";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

sops-nix.url = "github:Mic92/sops-nix";
sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixos-unstable"; # nixos-unstable
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

    bash-git-prompt = {
      url = "github:magicmonty/bash-git-prompt";
      flake = false;
    };

    tree-setter-nvim = {
      flake = false;
      url = "github:filNaj/tree-setter";
    };

    /*
      neovim-flake = {
        url = "github:nix-community/neovim-nightly-overlay"; # &rev=d321deb4a9b05e9d81b79ac166274f4a6e7981bf"; # the commit used in neovim-nightly-overlay itself, i. e. https://github.com/nix-community/neovim-nightly-overlay/commit/e5a94bb91c94dc079e7c714494a0be7814b51c6d
        # FIXME Gerschtli rather follows nixpkgs for all inputs, should I too ?
        #inputs.nixpkgs.follows = "unstable";
        #inputs.flake-utils.follows = "flake-utils";
      };
    */

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
      url = "github:simonmichael/hledger?ref=refs/tags/hledger-1.41&dir=hledger/shell-completion";
    };

    hledger-bin = {
      flake = false;
      url = "github:simonmichael/hledger?ref=refs/tags/hledger-1.41&dir=bin";
    };

    fsread-nvim = {
      flake = false;
      url = "github:nullchilly/fsread.nvim";
    };

    symbol-usage-nvim = {
      flake = false;
      url = "github:Wansmer/symbol-usage.nvim";
    };

    eyes-wide-bright = { 
      url = "github:FractalCodeRicardo/eyes-wide-bright";
      flake = false;
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

    yazi-compress = {
      url = "github:KKV9/compress.yazi";
      flake = false;
    };

    yazi-plugin-bat = {
      url = "github:mgumz/yazi-plugin-bat";
      flake = false;
    };

    yamb-yazi = {
      url = "github:h-hg/yamb.yazi";
      flake = false;
    };

    ouch-yazi = {
      url = "github:ndtoan96/ouch.yazi";
      flake = false;
    };

    ouch-xplr = {
      url = "github:dtomvan/ouch.xplr";
      flake = false;
    };

    # https://github.com/sxyazi/yazi/issues/1726
    yazi = {
      # tag shipped for stable yazi
      # tag nightly for unstable yazi
      url = "github:sxyazi/yazi?ref=refs/tags/shipped";
      #inputs.nixpkgs.follows = "unstable";
    };

    command-yazi = {
      url = "github:KKV9/command.yazi";
      flake = false;
    };

    ml_env = {
      url = "github:AlexChalk/ml_env";
      inputs.nixpkgs.follows = "unstable";
    };

    nixGL = {
      url = "github:nix-community/nixGL";
      # follows nixpkgs (master)
    #  inputs.nixpkgs.follows = "nixpkgs";
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

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      #url = "github:nix-community/emacs-overlay/20492c753b4f3b30fda02056f507e29ef38d3fa6";
    };

    emacs-overlay-cached = {
      # https://hydra.nix-community.org/eval/157894?filter=aarch64-linux.stable.emacs&compare=157534&full=
      # n-o-d 24.11 not yet released, stateVersion also still on 24.05
      # this commit (pr) breaks my aarch64 emacs somehow: a20a230b4051096340ee5415d1a8d66648566810
      # with the one before it works f148a612dbb4c29162fd61558ca10bc1b6fdc669
      # see https://github.com/nix-community/emacs-overlay/commits/master?since=2024-08-07&until=2024-08-07
      url = "github:nix-community/emacs-overlay/f148a612dbb4c29162fd61558ca10bc1b6fdc669";
      #url = "github:nix-community/emacs-overlay/bbe883e60c65dd9254d010e98a1a8a654a26f9d8";
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

    frank-yazi = {
      url = "github:lpnh/frank.yazi";
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
      #inputs.nixpkgs.follows = "unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "unstable";
    };
    poetry2nix.url = "github:nix-community/poetry2nix";
    #      poetry2nix.inputs.flake-utils.follows = "flake-utils";
    poetry2nix.inputs.nixpkgs.follows = "unstable";

    jupyenv.url = "github:tweag/jupyenv?ref=refs/pull/524/head"; # "github:573/jupyenv-aarch64-experimental";

    nixpkgs-ruby = {
      url = "github:bobvanderlinden/nixpkgs-ruby";
      #   inputs.nixpkgs.follows = "nixpkgs";
    };

    ocaml-overlay = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.nixpkgs.follows = "latest";
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

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mistty = {
      url = "github:szermatt/mistty";
      flake = false;
    };

    wsl-vpnkit = {
      # misusing the github api a bit here, see https://docs.github.com/de/rest/pulls/pulls?apiVersion=2022-11-28#get-a-pull-request--code-samples, a ?ref= would not work, but hash is correctly resolved to pull/250/commits/hash
      url = "github:sakai135/wsl-vpnkit/6845578336b5bcc3484f23dce51c4f6ac37baba6"; # 28992229fedfa64979faa9ec84b1b4bcf5c8f449"; #/?dir=pulls/250";
      flake = false;
    };

    google-chrome = {
      url = "github:r-k-b/browser-previews";
    };

    ghc-wasm-meta.url = "gitlab:ghc/ghc-wasm-meta/master?host=gitlab.haskell.org";

    zig2nix.url = "github:Cloudef/zig2nix";

    nix-ld-rs.url = "github:Mic92/nix-ld";

    bookmarks-yazi = {
      url = "github:dedukun/bookmarks.yazi";
      flake = false;
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
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

    catppuccin-yazi = {
      url = "github:catppuccin/yazi";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-formatter-pack,
      ...
    }@inputs:
    let
      rootPath = self;
      # TODO read https://discourse.nixos.org/t/cross-system-flakes-whats-your-favorite-forallsystems/68924/3 and https://nixcademy.com/posts/1000-instances-of-flake-utils/
      # DONE https://discourse.nixos.org/t/copy-formatter-config-from-another-flake-error/53224/4
      forEachSystem = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "armv7l-linux"
      ];

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = forEachSystem (
        system:
        inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          # Used to find the project root
          projectRootFile = "flake.nix";
          programs = {
            deadnix = {
              enable = true;
              no-lambda-arg = true;
              no-lambda-pattern-names = true;
            };
            nixpkgs-fmt = {
              enable = true;
              package = inputs.unstable.legacyPackages.${system}.nixfmt-rfc-style;
            };
            #shellcheck.enable = true;
            shfmt = {
              enable = true;
              # https://flake.parts/options/treefmt-nix.html#opt-perSystem.treefmt.programs.shfmt.indent_size
              # 0 causes shfmt to use tabs
              #indent_size = 0;
            };
          };
          # En
        }
      );

      /**
        "includes" ./flake/default.nix (function) and provides it the attributes `inputs rootPath forEachSystem` from "environment" as parameters
      */
      flakeLib =
        import ./flake # /default.nix
          {
            inherit
              inputs
              rootPath # specialArgs
              forEachSystem
              ;
          };

      formatterPackArgsFor = forEachSystem (system: {
        inherit nixpkgs;
	inherit (nixpkgs.legacyPackages.${system}.hostPlatform) system;
        checkFiles = [ self ];

        config.tools = {
          deadnix = {
            enable = true;
            noLambdaPatternNames = true;
          };
          # TODO see https://github.com/nix-community/nixd/blob/9355fa2/flake.nix#L60
          nixpkgs-fmt.enable = true;
          statix = {
            enable = true;
            disabledLints = [ "repeated_keys" ];
          };
        };

      });

      inherit (nixpkgs.lib) listToAttrs attrValues;
      inherit (flakeLib)
        mkApp
        mkHome
        mkNixOnDroid
        mkNixos
        mkRaspiNixos
        mkDeploy
        mkDevenvJvmLang
        mkDevenvDeno
        mkDevenvFlutter
        mkDevenvOcaml
        mkDevenvRust
        mkDevenvRuby
        mkDevenvHaskell
        mkDevenvRustWasm32
        mkDevShellJdk
        mkDevShellPostgreSQL
        mkDevenvRubyNix
        mkDevenvRubyVar3
        mkDevShellOcaml
        mkDevenvRust2
        mkDevShellPython
        mkDevShellAgda
        mkDevShellCommonLisp
        mkDevenvPlaywright
        mkDevenvPlaywright2
        mkDevShellGhcwasm
        mkDevenvHaskell2
	mkDevShellNixPath
        ;

      # NOTE https://discourse.nixos.org/t/installing-only-a-single-package-from-unstable/5598/30
      #  and https://discourse.nixos.org/t/add-an-option-to-home-manager-as-a-nixos-module-using-flake/38731/4
      #  and https://discourse.nixos.org/t/how-do-specialargs-work/50615/4
      #  and https://discourse.nixos.org/t/access-inputs-via-specialargs-in-mkshell/51905/5
      /**
        "Used" like this: `specialArgs.${system}`
      */
      specialArgs = forEachSystem (system: {
        inherit system;
        nixpkgs = inputs.nixpkgs.legacyPackages.${system};
        latest = inputs.latest.legacyPackages.${system};
        unstable = inputs.unstable.legacyPackages.${system};
        nixos-2405 = inputs.nixos-2405.legacyPackages.${system};
        libreoffice-postscript = inputs.libreoffice-postscript.legacyPackages.${system};
        haskellPackages = inputs.ghc-nixpkgs-unstable.legacyPackages.${system}.haskellPackages;
        ghc-nixpkgs-unstable = inputs.ghc-nixpkgs-unstable.legacyPackages.${system};
        fenix = inputs.fenix.packages.${system};
        nixpkgs-ruby-overlay = inputs.nixpkgs-ruby.overlays.default;
        ghciwatch = inputs.ghciwatch.packages.${system}.default;
        ghc-wasm-meta = inputs.ghc-wasm-meta.packages.${system}.all_9_8;
        inherit (inputs.yazi.packages.${system}) yazi;
        inherit (inputs.devenv.lib) mkShell;
        inherit (inputs.nixpkgs-ruby.lib) packageFromRubyVersionFile;
        inherit (inputs.jupyenv.lib.${system}) mkJupyterlabNew;
      });
    in
    {
      /*
        deploy.nodes.sams9 = {
          hostname = "localhost";
          profiles.system = {
            user = "nix-on-droid";
              	  sshUser = "nix-on-droid";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.custom inputs.latest.legacyPackages.aarch64-linux.hello "./bin/hello";
          };
        };
      */

      # nix shell nixpkgs#deploy-rs --command deploy -s .#sams9 -- --impure
      deploy = {
        autoRollback = false;
        magicRollback = true;
        nodes = listToAttrs [
          (mkDeploy "aarch64-linux" "sams9__aarch64-linux")
          (mkDeploy "aarch64-linux" "sams9__x86_64-linux")
          (mkDeploy "aarch64-linux" "sams__aarch64-linux")
          (mkDeploy "aarch64-linux" "sams__x86_64-linux")
        ];
      };

      /**
         Sample queries:
        nix-repl> :p nixOnDroidConfigurations.sams9.config.home-manager.config.home.username
        nix-repl> :p homeConfigurations."dani@maiziedemacchiato".config.home.username
        nix-repl> :p nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos.home.username
        nix eval --json .#raspberries.twopi.config.system.build.sdImage --show-trace
        nix eval --json .#raspberries.twopi.config.system.build.toplevel --show-trace
      */
      homeConfigurations = listToAttrs [
        /**
               	calls `mkHome` as defined in ./flake/default.nix (`[system]` and `[name]` parameters) and ./flake/builders/mkHome.nix, latter the place where `extraSpecialArgs` would also go
        */
        (mkHome "aarch64-linux" "u0_a210@localhost")
        (mkHome "x86_64-linux" "dani@maiziedemacchiato")
      ];

      nixOnDroidConfigurations = listToAttrs [
        (mkNixOnDroid "aarch64-linux" "sams9")
        (mkNixOnDroid "aarch64-linux" "sams")
      ];

      nixosConfigurations = listToAttrs [
        (mkNixos "x86_64-linux" "DANIELKNB1")
        (mkNixos "x86_64-linux" "guitar")
        (mkNixos "x86_64-linux" "nixos")
        (mkRaspiNixos "aarch64-linux" "twopi")
        (mkRaspiNixos "x86_64-linux" "twopivm")
      ];

      # Expose the necessary information in your flake so agenix-rekey
      # knows where it has too look for secrets and paths.
      #
      # Make sure that the pkgs passed here comes from the same nixpkgs version as
      # the pkgs used on your hosts in `nixosConfigurations`, otherwise the rekeyed
      # derivations will not be found!
      # TODO get used to handling first, see example at https://github.com/oddlama/agenix-rekey/pull/28#issue-2331901837
      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = self;
        nodes = self.nixosConfigurations;
        # Example for colmena:
        # inherit ((colmena.lib.makeHive self.colmena).introspect (x: x)) nodes;
      };

      apps = forEachSystem (
        system:
        (listToAttrs [
          (
            # TODO Also try https://github.com/IllustratedMan-code/tick_egg_paper/blob/bf14af5/flake.nix#L44
            let
              inherit (inputs.jupyenv.lib.${system}) mkJupyterlabNew;
              jupyterlab = mkJupyterlabNew (
                { ... }:
                {
                  nixpkgs = inputs.nixpkgs;
                  imports = [
                    (
                      { ... }:
                      {
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
                      }
                    )
                  ];
                }
              );
            in
            {
              name = "jupyenv-app";
              value = {
                program = "${jupyterlab}/bin/jupyter-lab";
                type = "app";
              };
            }
          )

          (mkApp system "emacs" {
            file = builtins.toFile "file" ''
              source @bashLib@
              emacs
            '';
            path =
              pkgs:
              with pkgs;
              (map (x: "${x.custom.programs.emacs-no-el.finalPackage.outPath}") (
                (
                  let
                    inherit (pkgs.stdenv) isLinux isx86_64;
                  in
                  lib.optionals (isLinux && isx86_64) [
                    self.nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos
                    self.homeConfigurations."dani@maiziedemacchiato".config
                  ]
                )
                ++ (
                  let
                    inherit (pkgs.stdenv) isLinux isAarch64;
                  in
                  lib.optionals (isLinux && isAarch64) [
                    self.nixOnDroidConfigurations.sams9.config.home-manager.config
                  ]
                )
              ));
          })

          (mkApp system "nixos-shell" {
            file = ./files/apps/nixos-shell.sh;
            path =
              pkgs:
              attrValues {
                #pkgs: with pkgs; [
                inherit (pkgs)
                  nixos-shell
                  gawk
                  jq
                  git
                  ;
              };
          })

          (mkApp system "setup" {
            file = ./files/apps/setup.sh;
            path =
              pkgs:
              attrValues {
                #pkgs: with pkgs; [
                inherit (pkgs)
                  coreutils
                  curl
                  git
                  gnugrep
                  hostname
                  jq
                  openssh
                  nix
                  ;
              };

            envs._doNotClearPath = true;
          })

        ])
        // {
          nilApp = null;
        }
        #// {
        #  deploy-rs = inputs.deploy-rs.apps.${system}.default;
        #}
      );

      checks = forEachSystem (system: {

        formatting = treefmtEval.${system}.config.build.check self;

        nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgsFor.${system};

        /*
                    neovim-check-config = pkgs.runCommand "neovim-check-config"
                      {
          	      # TODO either config.custom.programs.neovim.minimalPackage or
          	      #  nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos.custom.programs.neovim.minimalPackage
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
      devShells = forEachSystem (
        system:
        let
          inherit (specialArgs.${system})
            mkShell
            nixpkgs
            unstable
            packageFromRubyVersionFile
            nixpkgs-ruby-overlay
            haskellPackages
            fenix
            ghc-wasm-meta
            ghciwatch
            ;
        in
        listToAttrs [
          #{ name = "template";  value = nixpkgs.mkShell {}; }
          # AFAIU the pkgs used herein (mkDevenv*) are with the overlays as in flake/nixpkgs.nix etc. applied, also means any derivation defined therein can be used here then, but is a different derivation than i. e. some binary-cached elsewhere, which can lead to subtle differences i. e. (un)expected rebuilds. To use a binary-cached flake define here directly in flake.nix and add overlays when needed only.
          (mkDevShellJdk system "jdk21" { jdk = pkgs: pkgs.jdk21; })
          (mkDevShellPostgreSQL system "postgresql" { inherit haskellPackages unstable; })
          # TODO wait for https://github.com/tweag/jupyenv/pull/524
          # until then as in https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/editors/jupyter-kernels/coq/default.nix (https://github.com/NixOS/nixpkgs/issues/255923, https://github.com/NixOS/nixpkgs/pull/268078 and https://gist.github.com/teto/4d12998d734f982e27f48d8bb001c8ae)
          # https://discourse.nixos.org/t/install-custom-kernels-into-jupyter-lab/37502
          # https://github.com/AlexChalk/ml_env/blob/3fb4d915e2ffac3d340b6b406defcf7753a587ad/flake.nix
          # use i. e.:
          # nix run --impure --expr 'with import <nixpkgs> {}; jupyter.override { definitions.clojure = clojupyter.definition; }'
          # (mkDevenvJupyenv system "jupyenv" { inherit mkShell mkJupyterlabNew; })
          (mkDevenvJvmLang system "jvmlanguages-devenv" { inherit mkShell; })
          (mkDevenvDeno system "deno" { inherit mkShell; })
          (mkDevenvFlutter system "flutter" { inherit mkShell; })
          # TODO https://github.com/c-cube/iter
          (mkDevenvOcaml system "ocaml" { inherit mkShell; })
          (mkDevenvRuby system "ruby" { inherit packageFromRubyVersionFile; })
          (mkDevenvRubyNix system "rubyNix" { })
          (mkDevenvRubyVar3 system "rubyShell" {
            inherit nixpkgs-ruby-overlay;
            inherit (inputs) nixpkgs;
          })
          (mkDevenvRust system "rust" { inherit mkShell inputs; })
          (mkDevenvRustWasm32 system "rustwasm32" { inherit mkShell fenix; })
          (mkDevenvHaskell system "haskell" { inherit haskellPackages mkShell; })
          (mkDevShellOcaml system "yaocaml" { inherit unstable; })
          (mkDevenvRust2 system "rustyShell" { inherit inputs mkShell; })
          (mkDevShellPython system "python" { inherit unstable; })
          # DONT probably delusional, rather try https://sourcegraph.com/github.com/nixvital/ml-pkgs/-/blob/overlays/torch-family.nix
          # also: https://wiki.nixos.org/wiki/CUDA
          #(mkDevShellCudaWsl system "cudawsl" { })
          #(mkDevenvJulia system "julia" { })
          (mkDevShellAgda system "agda" { inherit haskellPackages; })
          (mkDevShellCommonLisp system "commonlisp" { })
          (mkDevenvPlaywright system "playwright" { inherit nixpkgs mkShell; })
          (mkDevenvPlaywright2 system "playwright2" { inherit unstable mkShell; })
          (mkDevShellGhcwasm system "ghcwasm" { inherit ghc-wasm-meta; })
          (mkDevenvHaskell2 system "haskell2" {
            inherit
              nixpkgs
              ghciwatch
              haskellPackages
              unstable
              mkShell
              ;
          })
	  # see https://discourse.nixos.org/t/angle-brackets-in-a-nix-flake-world/67855/12
	  (mkDevShellNixPath system "nixpath" {})
        ]
        /*
          // {
            #template = (nixpkgs.mkShell.override { stdenv = nixpkgs.stdenvAdapters.useMoldLinker nixpkgs.stdenv; });
            # https://github.com/NixOS/nixpkgs/blob/9e860e4/pkgs/development/lisp-modules/shell.nix
            zigShell = inputs.zig2nix.devShells.${system}.default;
            rustShell = inputs.rust-dev-template.devShells.${system}.default;
            cljShell = inputs.clojure-dev-template.devShells.${system}.default;
            ocamlShell = inputs.ocaml-dev-template.devShells.${system}.default;
            nixdShell = inputs.nixd.devShells.${system}.default;
                 	jupyShell = inputs.ml_env.devShells.${system}.default;
          }
        */
      );

      #formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsFor.${system});

      # for `nix fmt`
      formatter = forEachSystem (system: treefmtEval.${system}.config.build.wrapper);

      nixosModules.nixos-shell-vm = import ./files/nix/nixos-shell-vm.nix rootPath;

      #deploy = import ./flake/deploy.nix { nixpkgs = inputs.unstable; inherit (inputs) self; };

      packages =
        let
          cachixSpecBuilder = pkgs: spec: pkgs.writeText "cachix-deploy.json" (builtins.toJSON spec);

          cachixDeployOutput = builder: name: module: {
            ${module.pkgs.hostPlatform.system}."cachix-deploy-spec-${name}" = cachixSpecBuilder module.pkgs {
              agents.${name} = builder module;
            };
          };

          cachixDeployOutputHomeManager = cachixDeployOutput (module: module.activationPackage);
          cachixDeployOutputNixondroid = cachixDeployOutput (module: module.activationPackage);
          cachixDeployOutputNixos = cachixDeployOutput (module: module.config.system.build.toplevel);
        in
        nixpkgs.lib.foldl nixpkgs.lib.recursiveUpdate
          {
            aarch64-linux = {
              rpi-firmware = import ./files/nix/rpi-firmware.nix { inherit nixpkgs; };
              rpi-image = import ./files/nix/rpi-image.nix {
                inherit nixpkgs rootPath;
                inherit (inputs) nixos-hardware;
              };
            };
            armv7l-linux = {
              # TODO try https://github.com/n8henrie/nixos-btrfs-pi/blob/master/flake.nix
              # also https://discourse.nixos.org/t/run-nixos-rpi4-image-arm-sd-image-by-qemu-emulation/33946/10
              # plus for dtb part https://discourse.nixos.org/t/run-nixos-rpi4-image-arm-sd-image-by-qemu-emulation/33946
              # nix build .#rpi-run-in-vm
              run-in-vm = import ./files/nix/run-in-vm.nix { inherit nixpkgs rootPath; };
            };

            x86_64-linux = {
              installer-image = import ./files/nix/installer-image.nix { inherit nixpkgs; };
              # https://discourse.nixos.org/t/get-qemu-guest-integration-when-running-nixos-rebuild-build-vm/22621
              # https://mattwidmann.net/notes/running-nixos-in-a-vm/
              # https://blog.yaymukund.com/posts/nixos-raspberry-pi-nixbuild-headless/
              # nix build --max-jobs 1 .#packages.x86_64-linux.demo-with-automatic-vm-integration
              # TODO https://wiki.nixos.org/wiki/NixOS_on_ARM/QEMU
              #  nix-build flake:nixpkgs -A pkgsCross.aarch64-multiplatform.ubootQemuAarch64
              #  qemu-system-aarch64 -nographic -machine virt -cpu cortex-a57 -bios result/u-boot.bin ./nixos-image-sd-card-***-aarch64-linux.img -m 4G
              demo-with-automatic-vm-integration =
                nixpkgs.legacyPackages.x86_64-linux.pkgs.writeShellApplication
                  {
                    name = "run-nixos-vm";
                    runtimeInputs = [ nixpkgs.legacyPackages.x86_64-linux.pkgs.virt-viewer ];
                    text = ''
                      	    echo hi
                                  ${self.nixosConfigurations.twopivm.config.system.build.vm}/bin/run-twopi-vm & PID_QEMU="$!"
                                  sleep 1 # I think some tools have an option to wait like -w
                                  remote-viewer spice://127.0.0.1:5930
                                  kill $PID_QEMU
                    '';
                  };
              demo-nox = nixpkgs.legacyPackages.x86_64-linux.pkgs.writeShellApplication {
                name = "run-nixos-vm";
                text = ''
                  	    QEMU_KERNEL_PARAMS=console=ttyS0 ${self.nixosConfigurations.twopivm.config.system.build.vm}/bin/run-twopi-vm -nographic
                  	    '';
              };

              # TODO try what is suggested on discourse here https://discourse.nixos.org/t/looking-for-help-around-tightening-the-feedback-loop/67109/3
              raspi2qemu = nixpkgs.legacyPackages.x86_64-linux.pkgs.writeShellApplication {
                name = "run-nixos-vm";
                text = # ''
                  #img=./raspi-in-qemu.img
                  #cp ${inputs.self.nixosConfigurations.twopi.config.system.build.sdImage}/sd-image/${inputs.self.nixosConfigurations.twopi.options.sdImage.imageName.value} "$img"
                  #chmod 0640 "$img"
                  #echo $out
                  #cp "$img" $out

                  # First make this work
                  # FIXME this makes now - I think I just need to take twopi instead of twopivm now:
                  # $ file /nix/store/7j6w11r078sr3xlw891cr9r79lgx7fpi-qemu-host-cpu-only-9.1.2/bin/qemu-kvm
                  # /nix/store/7j6w11r078sr3xlw891cr9r79lgx7fpi-qemu-host-cpu-only-9.1.2/bin/qemu-kvm: symbolic link to qemu-system-x86_64
                  # in run-twopi-vm
                  ''
                    	      echo ${self.nixosConfigurations.twopi.config.system.build.sdImage}
                    	      ${self.nixosConfigurations.twopi.config.system.build.vm}/bin/run-twopi-vm
                    	    '';
              };
            };
          }
          (
            nixpkgs.lib.mapAttrsToList cachixDeployOutputNixos self.nixosConfigurations
  #          ++ [
	# FIXME unbreak nps : error: a 'x86_64-linux' with features {} is required to build '/nix/store/glhw8ks590s18wa34a5niaa25f0qyggl-await-podman-unshare.drv'
              #(cachixDeployOutputNixondroid "sams" self.nixOnDroidConfigurations.sams)
    #          (cachixDeployOutputHomeManager "maiziedemacchiato" self.homeConfigurations."dani@maiziedemacchiato")
   #         ]
          );
    };

  nixConfig = {
    # FIXME requires --accept-flake-config but might be better for nix develop
    #extra-substituters = [
    #    "https://arm.cachix.org/"
    #];
    #extra-trusted-public-keys = [
    #    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
#];
    # only for bootstrap
    #extra-experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  };
}
