_:

{ lib, pkgs, homeModules ? [ ], inputs, rootPath, ... }:

{
  homeManager = {
    baseConfig = {
      backupFileExtension = "hm-bak";
      extraSpecialArgs = { inherit inputs rootPath; };
      sharedModules = homeModules;
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    userConfig = host: user: "${rootPath}/hosts/${host}/home-${user}.nix";
  };

  nix = {
    settings = {
      substituters = [
        "https://arm.cachix.org"
        "https://cache.nixos.org"
        "https://gerschtli.cachix.org"
        "https://nix-on-droid.cachix.org"
        "https://cachix.cachix.org"
        "https://nix-community.cachix.org"
        "https://niv.cachix.org"
        "https://573-bc.cachix.org"
        "https://tweag-jupyter.cachix.org"
        "https://tree-grepper.cachix.org"
        "https://coq.cachix.org"
        "https://ai.cachix.org"
        "https://nixpkgs-ruby.cachix.org"
        #"https://anmonteiro.nix-cache.workers.dev"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-public-keys = lib.mkForce [
        "arm.cachix.org-1:K3XjAeWPgWkFtSS9ge5LJSLw3xgnNqyOaG7MDecmTQ8="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
        "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niv.cachix.org-1:X32PCg2e/zAm3/uD1ScqW2z/K0LtDyNV7RdaxIuLgQM="
        "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs="
        "tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g="
        "tree-grepper.cachix.org-1:Tm/owXM+dl3GnT8gZg+GTI3AW+yX1XFVYXspZa7ejHg="
        "coq.cachix.org-1:5QW/wwEnD+l2jvN6QRbRRsa4hBHG3QiQQ26cxu1F5tI="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
        #"ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      experimental-features = [ "nix-command" "flakes" ];
      log-lines = 30;
      flake-registry = null;
    };

    package = pkgs.nixVersions.unstable;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nix-config.flake = inputs.self;
    };
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };
}
