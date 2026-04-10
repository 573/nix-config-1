{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.ssh;

  keysDirectory = "${config.home.homeDirectory}/.ssh/keys";
in

{

  ###### interface

  options = {

    custom.programs.ssh = {

      enable = mkEnableOption "ssh config";

      cleanKeysOnShellStartup = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to clean all keys in keychain on top level shell startup.
        '';
      };

      controlMaster = mkOption {
        type = types.enum [
          "yes"
          "no"
          "ask"
          "auto"
          "autoask"
        ];
        default = "auto";
        description = ''
          Configure sharing of multiple sessions over a single network connection.
        '';
      };

      modules = mkOption {
        type = types.listOf (
          types.enum [
            "private"
            "vcs"
          ]
        );
        default = [ ];
        description = "SSH modules to enable.";
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      #misc.homeage.secrets = map (value: "ssh-${value}") cfg.modules;

      programs.shell = {
        initExtra = ''
          keygen() {
            if [[ -z "$1" ]]; then
              echo "Enter path  as argument!"
            else
              ssh-keygen -t ed25519 -f "$1"
            fi
          }

          kadd() {
            local key="${keysDirectory}/id_rsa.$1"

            if [[ ! -r "$key" ]]; then
              echo "ssh key not found: $key"
            else
              keychain "$key"
            fi

            if [[ $# > 1 ]]; then
              kadd "''${@:2}"
            fi
          }
        '';

        loginExtra = mkIf cfg.cleanKeysOnShellStartup ''
          # remove existing keys
          if [[ $SHLVL == 1 ]]; then
            keychain --clear --quiet
          fi
        '';
      };
    };

    home.packages = [
      pkgs.openssh
    ];

    programs = {
      # https://sourcegraph.com/search?q=context:global+file:%5E*.nix%24+content:programs.keychain.&patternType=standard&sm=1&groupBy=repo
      # https://www.google.com/search?q=+id_ed25519+keychain
      keychain = {
        enable = true;
        agents = [ "ssh" ];
        keys = [ ];
      };

      # all info is here https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Multiplexing
      ssh = {
        inherit (cfg) controlMaster;

        enable = true;

        compression = true;
        serverAliveInterval = 30;
        hashKnownHosts = true;
        controlPath = "~/.ssh/socket-%C";
        controlPersist = "10m";

        includes = [ "~/.ssh/config.d/*" ];
        extraConfig = ''
          CheckHostIP yes
          ConnectTimeout 60
          EnableSSHKeysign yes
          ExitOnForwardFailure yes
          ForwardX11Trusted yes
          IdentitiesOnly yes
          NoHostAuthenticationForLocalhost yes
          Protocol 2
          PubKeyAuthentication yes
          SendEnv LANG LC_*
          ServerAliveCountMax 30
        '';
      };
    };

  };

}
