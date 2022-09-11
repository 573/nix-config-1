# Nix Configurations

This is my humble flakes-only collection of all and everything needed to set up and maintain all my nixified devices.

## Features

* Automation scripts to [setup a fresh installation](files/apps/setup.sh) and
  [update the system](home/misc/util-bins/system-update.sh) easily
* [nix-on-droid][nix-on-droid]-managed android phone with [home-manager][home-manager]
* Generated shell scripts are always linted with [shellcheck][shellcheck]
* Checks source code with [statix][statix] and [nixpkgs-fmt][nixpkgs-fmt]
* Every output is built with Github Actions and pushed to [cachix][cachix]
* Weekly automatic flake input updates committed to master when CI passes

## Supported configurations

* [nix-on-droid][nix-on-droid]-managed
  * `sams9`

See [flake.nix](flake.nix) for more information like `system`.

## First installation

If any of these systems need to be reinstalled, you can run:

```sh
$ nix run github:573/nix-config-1#setup
```

**Note:**
* NixOS-managed systems should be set up like written in the [NixOS manual][nixos-manual].
* For the Raspberry Pi use the provided script in [misc/sd-image.nix](misc/sd-image.nix) to create the sd-card image.

### Manual instructions for some systems

#### nix-on-droid

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
nix-shell -p nix --run "nix run github:573/nix-config-1#setup"
```

## TODOs

As I am currently transitioning to a flake setup, there is still some stuff to do :)

* [ ] NixOS setup script: `/home/tobias/.age` is missing
* [ ] Add functionality to apply patches to individual inputs (EDIT: non-trivial because `builtins.getFlake` does not
  accept paths to `/nix/store`..)
* [ ] Provide ISO-images for NixOS configurations
* [ ] Set up nixos-shell and similar for an ubuntu image to easily test setup script
* [ ] [systemd-boot-builder.py][systemd-boot-builder.py] does not clean up boot loader entries of specialisations, try
  to improve this script

[age]: https://age-encryption.org/
[agenix]: https://github.com/ryantm/agenix
[cachix]: https://www.cachix.org/
[cachix-gerschtli]: https://app.cachix.org/cache/gerschtli
[home-manager]: https://github.com/nix-community/home-manager
[homeage]: https://github.com/jordanisaacs/homeage
[nix-on-droid]: https://github.com/t184256/nix-on-droid
[nixos-infect]: https://github.com/elitak/nixos-infect
[nixos-manual]: https://nixos.org/manual/nixos/stable/index.html#sec-installation
[nixos]: https://nixos.org/
[nixpkgs-fmt]: https://github.com/nix-community/nixpkgs-fmt
[shellcheck]: https://github.com/koalaman/shellcheck
[statix]: https://github.com/nerdypepper/statix
[systemd-boot-builder.py]: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/loader/systemd-boot/systemd-boot-builder.py

<!-- vim: set sw=2: -->
