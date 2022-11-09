# Nix Configurations

This is my humble flakes-only collection of all and everything needed to set up and maintain all my nixified devices.

## Features

* Automation scripts to [setup a fresh installation](files/apps/setup.sh) and
  [update the system](home/misc/util-bins/system-update.sh) easily
* [nix-on-droid][nix-on-droid]-managed android phone with [home-manager][home-manager]
* Generated shell scripts are always linted with [shellcheck][shellcheck]
* Checks source code with [deadnix][deadnix], [statix][statix] and [nixpkgs-fmt][nixpkgs-fmt] (using
  [nix-formatter-pack][nix-formatter-pack])
* Github Actions pipeline for aarch64-linux systems
* Every output is built with Github Actions and pushed to [cachix][cachix]
* Weekly automatic flake input updates committed to master when CI passes

## Supported configurations

* [nix-on-droid][nix-on-droid]-managed
  * `sams9`

See [flake.nix](flake.nix) for more information like `system`.

## First installation

If any of these systems need to be reinstalled, you can run:

```sh
$ nix run github:573/nix-config-1/just_nixondroid#setup
```

**Note:**
* NixOS-managed systems should be set up like written in the [NixOS manual][nixos-manual].

### Manual instructions for some systems

#### nix-on-droid

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
nix-shell -p nix --run "nix run github:573/nix-config-1#setup"
```

## TODOs

* [ ] NixOS setup script: `/home/tobias/.age` is missing
* [ ] Provide ISO-images for NixOS configurations
* [ ] Set up nixos-shell and similar for an ubuntu image to easily test setup script

[age]: https://age-encryption.org/
[agenix]: https://github.com/ryantm/agenix
[cachix-deploy]: https://docs.cachix.org/deploy/
[cachix-gerschtli]: https://app.cachix.org/cache/gerschtli
[cachix]: https://www.cachix.org/
[deadnix]: https://github.com/astro/deadnix
[home-manager]: https://github.com/nix-community/home-manager
[homeage]: https://github.com/jordanisaacs/homeage
[nix-formatter-pack]: https://github.com/Gerschtli/nix-formatter-pack
[nix-on-droid]: https://github.com/t184256/nix-on-droid
[nixos-infect]: https://github.com/elitak/nixos-infect
[nixos-manual]: https://nixos.org/manual/nixos/stable/index.html#sec-installation
[nixos]: https://nixos.org/
[nixpkgs-fmt]: https://github.com/nix-community/nixpkgs-fmt
[shellcheck]: https://github.com/koalaman/shellcheck
[statix]: https://github.com/nerdypepper/statix

<!-- vim: set sw=2: -->
