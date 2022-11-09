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

    if [[ -d "${directory}" ]]; then
        _log "Not cloning ${name} because ${directory} already exists!"
        return
    fi

    _log "Clone ${name}..."
    git clone "${url}" "${directory}"
}


# pause script
read -sr -n 1 -p "$(echo -e "${PURPLE}Press any key to continue...${RESET}")"
echo


# clone repos
if ! _is_nixos || _is_root; then
    _clone "nix-config" https://github.com/573/nix-config-1.git "${nix_config}"
fi

# preparation for non nixos systems
if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
    _log "Set priority of installed nix package..."
    nix-env --set-flag priority 1000 nix
fi

# set up cachix (skip nixos for now)
if ! _is_nixos && ! _is_root; then
    _log "Set up cachix..."
    cachix use nix-community
    cachix use 573-bc
    cachix use gerschtli
    cachix use nix-on-droid
fi

# installation
if [[ "${USER}" == "nix-on-droid" ]]; then
    _log "Run nix-on-droid switch..."
    nix-on-droid switch --flake "${nix_config}#sams9"
elif ! _is_nixos && ! _is_root; then
    _log "Build home-manager activationPackage..."
    nix build "${nix_config}#homeConfigurations.${USER}@$(hostname).activationPackage"

    _log "Run activate script..."
    HOME_MANAGER_BACKUP_EXT=hm-bak ./result/activate

    rm -v result
fi


# clean up
if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
    _log "Uninstall manual installed nix package..."
    nix-env --uninstall nix
fi

echo
