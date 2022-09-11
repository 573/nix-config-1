{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05-aarch64";
    #unstable-aarch64.url = "github:NixOS/nixpkgs/unstable-aarch64";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #unstable.url = "github:NixOS/nixpkgs/c4d0026e7346ad2006c2ba730d5a712c18195aab";
    #master.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nix-on-droid = {
      # stick to release-22.05 for now
      url = "github:t184256/nix-on-droid/release-22.05";
      inputs.flake-utils.follows = "flake-utils";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    virtual-types-nvim = {
      flake = false;
      url =
        "https://github.com/jubnzv/virtual-types.nvim/archive/9ef9f31c58cc9deb914ee728b8bda8f217f9d1c7.tar.gz";
    };

    code-runner-nvim = {
      flake = false;
      url =
        "https://github.com/CRAG666/code_runner.nvim/archive/7cdeb206520c5afb2bd7655da981a9bcdc3f43f8.tar.gz";
    };

    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      #inputs.nixpkgs.follows = "neovim-nightly/nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      #inputs.nixpkgs.follows = "unstable";
      inputs.flake-compat.follows = "flake-compat";
      #inputs.neovim-flake.inputs.follows = "unstable";
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
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      rootPath = ./.;
      flakeLib = import ./flake { inherit inputs rootPath; };

      inherit (nixpkgs.lib) listToAttrs;
      inherit (flakeLib) mkNixOnDroid eachSystem;
    in {
      nixOnDroidConfigurations =
        listToAttrs [ (mkNixOnDroid "aarch64-linux" "sams9") ];
    } // eachSystem ({ mkApp, mkCheck, system, }: {
      apps = listToAttrs [
        (mkApp "format" {
          file = ./files/apps/format.sh;
          path = pkgs: with pkgs; [ nixpkgs-fmt statix ];
        })
        (mkApp "setup" {
          file = ./files/apps/setup.sh;
          path = pkgs:
            with pkgs; [
              cachix
              coreutils
              curl
              git
              gnugrep
              hostname
              jq
              nix
              openssh
            ];
          envs._doNotClearPath = true;
        })
      ];

      checks = listToAttrs [
        (mkCheck "nixpkgs-fmt" {
          script = pkgs: ''
            shopt -s globstar
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}/**/*.nix
          '';
        })

        (mkCheck "statix" {
          script = pkgs: ''
            ${pkgs.statix}/bin/statix check ${./.}
          '';
        })

      ];

      # use like:
      # $ direnv-init jdk11
      # $ lorri-init jdk11
      devShells = listToAttrs [ ];

      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    });
}
