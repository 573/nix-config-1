_:

{ lib, pkgs, homeModules ? [ ], inputs, rootPath, ... }:

{
  homeManager = {
    baseConfig = {
      backupFileExtension = "hm-bak";
      extraSpecialArgs = { inherit inputs rootPath; };
      sharedModules = homeModules;
      useGlobalPkgs = true; # disables options nixpkgs.*
      useUserPackages = true;
    };

    userConfig = host: user: "${rootPath}/hosts/${host}/home-${user}.nix";
  };

  nix = {
    settings = {
      # TODO https://discourse.nixos.org/t/merged-list-contains-duplicates/38004
      substituters = [
        "https://573-bc.cachix.org/"
        "https://cache.nixos.org/"
        "https://nix-on-droid.cachix.org/"
        "https://arm.cachix.org/"
        "https://cachix.cachix.org/"
        "https://coq.cachix.org/"
        "https://devenv.cachix.org"
        "https://gerschtli.cachix.org/"
        "https://haskell-language-server.cachix.org/"
        "https://nix-community.cachix.org/"
        "https://nixpkgs-ruby.cachix.org/"
        "https://nixvim.cachix.org/"
        "https://yazi.cachix.org"
      ];
      trusted-public-keys = lib.mkForce [
        "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
        "arm.cachix.org-1:K3XjAeWPgWkFtSS9ge5LJSLw3xgnNqyOaG7MDecmTQ8="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "coq.cachix.org-1:5QW/wwEnD+l2jvN6QRbRRsa4hBHG3QiQQ26cxu1F5tI="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
        "haskell-language-server.cachix.org-1:juFfHrwkOxqIOZShtC4YC1uT1bBcq2RSvC7OMKx0Nz8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
        "nixvim.cachix.org-1:8xrm/43sWNaE3sqFYil49+3wO5LqCbS4FHGhMCuPNNA="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
      experimental-features = [ "nix-command" "flakes" "configurable-impure-env" "auto-allocate-uids" ];
      log-lines = 35;
      # discourse:nix-flake-update-timeout/17215/5
      #flake-registry = null;
      flake-registry = null; # "${inputs.flake-registry}/flake-registry.json"; # maybe DONT as this causes potential inconsistencies: just compare https://github.com/NixOS/flake-registry/blob/ffa18e3/flake-registry.json#L308 (nixpkgs-unstable) vs. inputs.nixpkgs (nixos-24.05)
    };

    package = pkgs.nixVersions.latest;
    # https://discourse.nixos.org/t/flake-registry-set-to-a-store-path-keeps-copying/44613
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-registry
    # https://nixos-and-flakes.thiscute.world/best-practices/nix-path-and-flake-registry 
    # https://dataswamp.org/~solene/2022-07-20-nixos-flakes-command-sync-with-system.html
    channel.enable = false;

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nix-config.flake = inputs.self;
      #"nixpkgs-unfree".to = {
      #  type = "path";
#	path = inputs.nixpkgs-unfree;
 #     };
    };
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };
}
