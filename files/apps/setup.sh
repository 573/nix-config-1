source @bashLib@

# see https://discourse.nixos.org/t/confused-about-nix-copying-nixpkgs/53737/3, some more general info https://discourse.nixos.org/t/meaning-of-self-in-flake-changes-when-used-as-an-input/35465/4
nix_config="${HOME}/.nix-config"

_log() {
  echo
  echo -e "${BOLD}${YELLOW}${1}${RESET}"
}

_clone() {
  local name="${1}"
  local url="${2}"
  local directory="${3}"

  if [[ -d ${directory} ]]; then
    _log "Not cloning ${name} because ${directory} already exists! To install newer revsision remove ${directory} first!"
    return
  fi

  _log "Clone ${name}..."
  git clone "${url}" "${directory}"
}

if _is_root; then
  _log "Please don't run this script with root!"
  exit 1
fi

# pause script
read -sr -n 1 -p "$(echo -e "${PURPLE}Press any key to continue...${RESET}")"
echo

# clone repos
_clone "nix-config" https://github.com/573/nix-config-1.git "${nix_config}"

# preparation for non nixos systems
if nix-env -q --json | jq ".[].pname" | grep '"nix"' >/dev/null; then
  _log "Set priority of installed nix package..."
  nix-env --set-flag priority 1000 nix
fi

# installation
# TODO putting --accept-flake-config in nixos-rebuild here let's the command silently fail, track this in an issue
if _is_nixos; then
  hostname=$(_read_enum "Enter hostname" DANIELKNB1 guitar)

  _log "Run sudo nixos-rebuild ..."
  sudo nixos-rebuild \
    boot \
    --show-trace --verbose \
    --flake "git+file:///${nix_config}#${hostname}" || :

  _log "Don't forget to set passwd for ${USER} and root!"
  _log "We did run nixos-rebuild boot, not switch, so you might want to run <result>/activate now to have the changes in effect or reboot!"
  _log " <result> is basically the path after init= in the concering grub menu entry thus to see the actual value use a variation of:"
  _log "\`sudo sed -n 66p /boot/grub/grub.cfg\` $(sudo sed -n 66p /boot/grub/grub.cfg)"
  _log "In case you need to userdel the nixos user, '\$ wsl -d NixOS -u root' and see https://gist.github.com/573/131629a55c0ef91305532c6f977934e6."
elif [[ ${USER} == "nix-on-droid" ]]; then
  [[ "$(id -u)" == "10332" ]] && declare -g confname=sams
  [[ "$(id -u)" == "10289" ]] && declare -g confname=sams9
  _log "Run nix-on-droid ..."
  #    nix-on-droid build \
  #        --option print-build-logs true \
  #        --option extra-substituters "https://573-bc.cachix.org/" \
  #	--option extra-trusted-public-keys "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs=" \
  #        --option extra-substituters "https://nix-on-droid.cachix.org/" \
  #        --option extra-trusted-public-keys "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=" \
  #	--flake "git+file:///${nix_config}#sams9"
  nix build \
    --option extra-substituters "https://573-bc.cachix.org/" \
    --option extra-trusted-public-keys "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs=" \
    --option extra-substituters "https://nix-on-droid.cachix.org/" \
    --option extra-trusted-public-keys "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=" \
    --option extra-substituters "https://nix-community.cachix.org/" \
    --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" \
    --option extra-substituters "https://nixvim.cachix.org/" \
    --option extra-trusted-public-keys "nixvim.cachix.org-1:8xrm/43sWNaE3sqFYil49+3wO5LqCbS4FHGhMCuPNNA=" \
    --option extra-substituters "https://yazi.cachix.org" \
    --option extra-trusted-public-keys "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k=" \
    "git+file:///${nix_config}#nixOnDroidConfigurations.${confname}.activationPackage" \
    -L --impure --keep-going -vvv --out-link /data/data/com.termux.nix/files/home/result
else
  _log "Build home-manager activationPackage..."
  nix build \
    --option extra-substituters "https://573-bc.cachix.org/" \
    --option extra-trusted-public-keys "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs=" \
    "git+file:///${nix_config}#homeConfigurations.${USER}@$(hostname).activationPackage"

  _log "Run activate script..."
  HOME_MANAGER_BACKUP_EXT=hm-bak ./result/activate

  rm -v result
fi

# clean up
if nix-env -q --json | jq ".[].pname" | grep '"nix"' >/dev/null; then
  _log "Uninstall manually installed nix package..."
  nix-env --uninstall nix
fi

echo
