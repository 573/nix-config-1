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

* [NixOS][nixos]-managed
  * `DANIELKNB1` (private laptop, WSL2)
  * `twopi` (Raspberry Pi)
* [home-manager][home-manager]-managed
  * `maiziedemacchiato` with Arch Linux (private laptop)
* [nix-on-droid][nix-on-droid]-managed
  * `sams9`

See [flake.nix](flake.nix) for more information like `system`.

## First installation

If any of these systems need to be reinstalled, you can run:

```sh
$ nix run \
  github:573/nix-config-1/wsl2#setup
```

**Note:**
* NixOS-managed systems should be set up like written in the [NixOS manual][nixos-manual].
  `nix build ".#installer-image"` can be used for latest kernel, helpful default config and some pre-installed
  utilities.



### Manual instructions for some systems

#### Arch Linux

```sh
# install nix setup
sh <(curl -L https://nixos.org/nix/install) --no-channel-add --no-modify-profile
. ~/.nix-profile/etc/profile.d/nix.sh
nix run \
  --extra-experimental-features "nix-command flakes" \
  github:573/nix-config-1/wsl2#setup
```

#### Raspberry Pi

1. Build image
   ```sh
   nix build ".#rpi-image"
   ```
1. Copy (`dd`) `result/sd-image/*.img` to sd-card
1. Inject sd-card in raspberry and boot
1. When booted in the new NixOS system, login as tobias and run setup script

##### Update firmware

Firmware of Raspberry Pi needs to be updated manually on a regular basis with the following steps:

1. Build firmware
   ```sh
   nix build ".#rpi-firmware"
   ```
1. Mount `/dev/disk/by-label/FIRMWARE`
1. Create backup of all files
1. Copy `result/*` to firmware partition (ensure that old ones are deleted)
1. Unmount and reboot

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
