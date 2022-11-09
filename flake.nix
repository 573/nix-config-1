{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05-aarch64";
    #unstable-aarch64.url = "github:NixOS/nixpkgs/unstable-aarch64";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #unstable.url = "github:NixOS/nixpkgs/c4d0026e7346ad2006c2ba730d5a712c18195aab";
    master.url = "github:NixOS/nixpkgs/4deb94160637058c0f629d5057db988033b76c06"; # "github:NixOS/nixpkgs/master";
    staging.url = "github:NixOS/nixpkgs/staging"; # "github:NixOS/nixpkgs/2acce7dfdcf382757e6fe219e04668e7a63bf48a";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
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
    };

    flake-utils.url = "github:numtide/flake-utils";

    virtual-types-nvim = {
      flake = false;
      url =
        "https://github.com/jubnzv/virtual-types.nvim/archive/9ef9f31c58cc9deb914ee728b8bda8f217f9d1c7.tar.gz";
    };

    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "unstable";
      inputs.flake-compat.follows = "flake-compat";
      inputs.neovim-flake.follows = "neovim-flake";
    };

    code-runner-nvim = {
      flake = false;
      url =
        "https://github.com/CRAG666/code_runner.nvim/archive/7cdeb206520c5afb2bd7655da981a9bcdc3f43f8.tar.gz";
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

    nvim-osc52 = {
      flake = false;
      url = "github:ojroques/nvim-osc52";
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


    nix-index-database.url = "github:Mic92/nix-index-database";

    haskell-tools-nvim = {
      flake = false;
      url = "github:MrcJkb/haskell-tools.nvim";
    };
  };

  outputs = { self, nixpkgs, nix-formatter-pack, ... } @ inputs:
    let
      rootPath = toString ./.;
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-linux" ];
      flakeLib = import ./flake {
        inherit inputs rootPath forEachSystem;
      };

      formatterPackArgsFor = forEachSystem (system: {
        inherit nixpkgs system;
        checkFiles = [ ./. ];

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
      inherit (flakeLib) mkApp mkNixOnDroid;
    in
    {
      nixOnDroidConfigurations = listToAttrs [
        (mkNixOnDroid "aarch64-linux" "sams9")
      ];

      apps = forEachSystem (system: listToAttrs [
        (mkApp system "ci-build" {
          file = ./files/apps/ci-build.sh;
          path = pkgs: with pkgs; [ nix nix-build-uncached ];
          envs = { inherit rootPath; };
        })

        (mkApp system "setup" {
          file = ./files/apps/setup.sh;
          path = pkgs: with pkgs; [ cachix coreutils curl git gnugrep hostname jq nix openssh ];
          envs._doNotClearPath = true;
        })
      ]);

      checks = forEachSystem (system: {
        nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgsFor.${system};
      });

      # use like:
      # $ direnv-init jdk11
      # $ lorri-init jdk11
      devShells = listToAttrs [ ];

      formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsFor.${system});
    };
}

