source @bashLib@

nix_config="${HOME}/.nix-config"

_log() {
    echo
    echo -e "${BOLD}${YELLOW}${1}${RESET}"
}

_clone() {
    local name="${1}"
    local url="${2}"
    local directory="${3}"
    local branch="${4}"

    if [[ -d "${directory}" ]]; then
        _log "Not cloning ${name} because ${directory} already exists! To install newer revsision remove ${directory} first!"
        return
    fi

    _log "Clone ${name}..."
    git clone --single-branch --branch "${branch}" "${url}" "${directory}"
}

if _is_root; then
    _log "Please don't run this script with root!"
    exit 1
fi

# pause script
read -sr -n 1 -p "$(echo -e "${PURPLE}Press any key to continue...${RESET}")"
echo


# clone repos
_clone "nix-config" https://github.com/573/nix-config-1.git "${nix_config}" "wsl2"

# preparation for non nixos systems
if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
    _log "Set priority of installed nix package..."
    nix-env --set-flag priority 1000 nix
fi

# installation
if _is_nixos; then
    hostname=$(_read_enum "Enter hostname" DANIELKNB1)

    _log "Run sudo nixos-rebuild switch..."
    sudo nixos-rebuild \
	switch \
	--option extra-substituters "https://573-bc.cachix.org" \
	--option extra-trusted-public-keys "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs=" \
	--keep-going \
	--flake "${nix_config}#${hostname}" || :

    _log "Don't forget to set passwd for ${USER} and root!"
    _log "In case you need to userdel the nixos user, '\$ wsl -d NixOS -u root' and see https://gist.github.com/573/131629a55c0ef91305532c6f977934e6."
elif [[ "${USER}" == "nix-on-droid" ]]; then
    _log "Run nix-on-droid switch..."
    nix-on-droid switch \
        --option print-build-logs true \
        --option extra-substituters "https://cache.nixos.org" \
        --option extra-trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
        --option extra-substituters "https://gerschtli.cachix.org" \
        --option extra-trusted-public-keys "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0=" \
        --option extra-substituters "https://573-bc.cachix.org" \
	--option extra-trusted-public-keys "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs=" \
        --option extra-substituters "https://nix-on-droid.cachix.org" \
        --option extra-trusted-public-keys "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=" \
	--flake "${nix_config}#sams9"
else
    _log "Build home-manager activationPackage..."
    nix build \
        --option extra-substituters "https://573-bc.cachix.org" \
	--option extra-trusted-public-keys "573-bc.cachix.org-1:2XtNmCSdhLggQe4UTa4i3FSDIbYWx/m1gsBOxS6heJs=" \
	"${nix_config}#homeConfigurations.${USER}@$(hostname).activationPackage"

    _log "Run activate script..."
    HOME_MANAGER_BACKUP_EXT=hm-bak ./result/activate

    rm -v result
fi


# clean up
if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
    _log "Uninstall manually installed nix package..."
    nix-env --uninstall nix
fi

echo
