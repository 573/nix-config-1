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
        # deprecated, i.e., fixed by https://github.com/danielrobbins/keychain/commit/17f2961174f23047a789075a350a08cde9625364
        # historically (https://www.funtoo.org/Funtoo:Keychain#Specifying_Agents) meant:
        # The additional --agents ssh option tells keychain just to manage ssh-agent, and ignore gpg-agent even if it is available.
        #agents = [ "ssh" ];
        keys = [ ];
      };

      # all info is here https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Multiplexing
      ssh = {
        enable = true;

        matchBlocks."*" = {
          controlPersist = "10m";
          controlPath = "~/.ssh/socket-%C";
	  # default in nixpkgs until 25.11 was controlMaster no, I take it from options atop
          inherit (cfg) controlMaster;
          hashKnownHosts = true;
          serverAliveInterval = 30;
          compression = true;

          # see https://github.com/nix-community/home-manager/blob/d1686dc7d36cbd1234cb226ad6ef97e882716acb/modules/programs/ssh.nix#L651
          # default values copied here
          forwardAgent = false;
          addKeysToAgent = "no";
          userKnownHostsFile = "~/.ssh/known_hosts";
	  forwardX11Trusted = true;
	  identitiesOnly = true;
	  sendEnv = ["LANG" "LC_*"];
        };

        includes = [ "~/.ssh/config.d/*" ];

        extraConfig = ''
 	  # Specifies the timeout (in seconds) used when connecting to the SSH server, instead of using the default system TCP timeout.
          ConnectTimeout 60
	  # ssh-keysign is disabled by default and can only be enabled in the global client configuration file /etc/ssh/ssh_config by setting EnableSSHKeysign to “yes”.
          EnableSSHKeysign yes
	  # Specifies whether ssh should terminate the connection if it cannot set up all requested dynamic, tunnel, local, and remote port forwardings.
          ExitOnForwardFailure yes
	  # This option can be used if the home directory is shared across machines. In this case localhost will refer to a different machine on each of the machines and the user will get many warnings about changed host keys.
          NoHostAuthenticationForLocalhost yes
          Protocol 2
          PubKeyAuthentication yes
        '';

	# Extra SSH configuration options that take precedence over any host specific configuration.
	#extraOptionOverrides = {};
      };
    };

  };

}
