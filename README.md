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

##### Update `flake.lock`

Go to [update-flake-lock](https://github.com/573/nix-config-1/actions/workflows/update.yml). There `Use workflow from | Branch: master`. When action is finished go to [Pull requests](https://github.com/573/nix-config-1/pulls), choose the latest `Update flake.lock` and use the `Rebase and merge` (*The 1 commit from this branch will be rebased and added to the base branch.*) approach.

##### Troubleshoot

###### emacs (all archs)

When emacs is modified i. e. packages are changed, there may occur discrepancies i. e.
packages missing being noticed at runtime which often is related to so first check the
flake input `emacs-overlay`, might refer to a dated version. Also when updating emacs
the aarch64-linux variant needs to be remote-built or binfmt-built and pushed to a
cache as its build causes an OOM killer on certain devices.
 More info here: https://gist.github.com/573/d39c29400044c8e6f22a8b1d17c0a56c


###### nix-on-droid

Observe the recommendations on [n-o-d](https://github.com/nix-community/nix-on-droid/issues/374)s
page for device settings (or directly [here](https://dontkillmyapp.com/google)).

###### NixOS-WSL

> [!IMPORTANT]  
> Somehow I managed to downgrade WSL while trying to make usbip-win and/or wslg working.
> Extremely unadvisable, took me one and a half day of unneccessary tweaking on wrong ends
> to figure the real cause of *error: getting attributes of path '/run/binfmt': No such file or directory*
> when trying a nixos-rebuild days or weeks after that mistake.
> as well as other very weird behaviours (it is still a VM let's not forget about that).
> *tl;dr* after upgrading again to v2.2.4 (latest by that time) all issues where set.
> Baseline info [here](https://github.com/nix-community/NixOS-WSL/blob/56907505856b4b000a9c166a566eea6c46aef2a0/docs/src/troubleshooting/README.md?plain=1#L10).


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
