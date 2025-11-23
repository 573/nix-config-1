{
  config,
  lib,
  pkgs,
  inputs,
  homeDir,
  ...
}:

let
  inherit (lib)
    attrValues
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.sops-nix;
in

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  ###### interface

  options = {

    custom.programs.sops-nix.enable = mkEnableOption "sops-nix config";

  };

  ###### implementation

  config = mkIf cfg.enable {

    home = {
      homeDirectory = homeDir;

      packages = attrValues {
        inherit (pkgs)
          sops
          ;
      };
    };

    # see https://github.com/Mic92/sops-nix/blob/f77d4cfa075c3de66fc9976b80e0c4fc69e2c139/README.md?plain=1#L786
    # also in case it helps, overview: https://github.com/Mic92/sops-nix/tree/41fd1f7570c89f645ee0ada0be4e2d3c4b169549?tab=readme-ov-file#use-with-home-manager
    # or maybe: https://github.com/search?q=lang%3Anix%20inputs.sops-nix&type=code
    # NOT WORKING:
    #systemd.user.services.podman-paperless.unitConfig.After = [ "sops-nix.service" ];
    sops = {
      # only chance to build that without copying secrets.yaml to store
      # would be having exactly defaultSopsFile = /home/dani/.sops/secrets/secrets.yaml; NOT WORKING: defaultSopsFile = "${config.home.homeDirectory}/.sops/secrets/secrets.yaml";
      # Also (nix-enabled archlinux) not working was putting the folder with secrets.yaml somewhere in /root or /var/local, i..e., making it readable by my user
      # and $ nix build 'git+file:///home/dani/.nix-config#homeConfigurations."dani@maiziedemacchiato".activationPackage' -L -vvv --show-trace --json --impure
      # inspect via
      # $ nix eval 'git+file:///home/dani/.nix-config#homeConfigurations."dani@maiziedemacchiato".config.sops.secrets' --impure
      # I think it is either-xor: having immutability / reproducibility and
      # easy interface to refresh, i.e., potentially compromised, maybe not
      # so important secrets xor having protection towards secrets leakage
      # aka impurity
      #
      # But it gets worse:
      # Building as shown reveals that (systemctl --user status sops-nix.service or journalctl --user -xeu sops-nix.service):
      # >Oct 13 13:23:53 maiziedemacchiato 0b4jnfczigbq0shqim519v53l8vxfnwq-sops-nix-user[1324760]: /nix/store/vqn6z63pwzkg6whhkzji5jdd16kflid6-sops-install-secrets-0.0.1/bin/sops-install-secrets: secret paperless/secret_key in /nix/store/n4mwry582ja96y31sl9j02c7n64p84qw-secrets.yaml is not valid: the value of key 'paperless' is not a string
      # Thus the secrets.yaml still lands in the store
      # Idk if that happened due to misconfiguration on my side but the thing is that I never intended to have the store file with my actual though encrypted secrets to be written to the store not even when there is still a configuration typo anywhere (I guess in my case I did not set secrets."secret/value".key = ""; down here to, yes, the empty string, whyever now that works)
      # Also I cannot tell if now as the errors are gone there is still the store file *-secrets.yaml written or not.
      # takehome: the real as in production secrets should never ever be used in the config before that certain deployed config is evaluated, built and runtime-checked error-free even if there is indeed a working concept of not writing secrets.yaml to the store
      # Honestly this is such a PITA:
      # now getting
      # >error: The option `home.file."/home/dani/.config/systemd/user/podman-paperless.service".source' has conflicting definition values:
      # for the unitConfig.After thing above
      # readme says: avoid [adding secret.yaml to store] by adding a string to the full path
      validateSopsFiles = false;
      defaultSopsFile = "${config.home.homeDirectory}/.sops/secrets/secrets.yaml"; # "${homeDir}/.sops/secrets/secrets.yaml";
      age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
 
      # see https://github.com/Mic92/sops-nix/issues/498
      #templates."nixbuild-sshconfig".content = ''${config.sops.placeholder."signing_key/secret_key"}'';

      templates."syncthing/device_1/id".content = ''${config.sops.placeholder."syncthing/device_1/id"}'';

      # see https://discourse.nixos.org/t/sops-nix-secrets-yaml-is-not-valid-and-key-cannot-be-found/68071/5
      # also (not tested as it seems to imply --impure as well) https://github.com/Mic92/sops-nix/issues/287#issuecomment-1764207071
      secrets = {
        "paperless/admin_password" = {
          key = "paperless/admin_password";
        };
        "paperless/secret_key" = {
          key = "paperless/secret_key";
        };
        "paperless/db_password" = {
          key = "paperless/db_password";
        };
        # TODO to provoke the error where key leaking is demonstrated, i.e.,
        # secrets.yaml in store as opposed to the recipe spec
        # /nix/store/hash-secrets.yaml
        # just uncomment following line and comment lines after that then
        #"syncthing/id".key = "syncthing/id";
        "syncthing/device_1/id" = {
          key = "syncthing/device_1/id";
        };
        "syncthing/device_2/id" = {
          key = "syncthing/device_2/id";
        };
        "syncthing/device_2/label" = {
          key = "syncthing/device_2/label";
        };
        "syncthing/device_3/id" = {
          key = "syncthing/device_3/id";
        };
        "syncthing/folder_1/id" = {
          key = "syncthing/folder_1/id";
        };
        "syncthing/folder_1/path" = {
          key = "syncthing/folder_1/path";
        };
        "syncthing/folder_1/label" = {
          key = "syncthing/folder_1/label";
        };
        "ssh/secret_env" = {
          key = "ssh/secret_env";
	};
      };
      #  sopsFile = ...;
      #};
      # TODO if applies see https://github.com/Mic92/sops-nix/blob/f77d4cfa075c3de66fc9976b80e0c4fc69e2c139/README.md?plain=1#L851
      # for ~/.sops/secrets/secrets.yaml template see https://github.com/Tarow/nix-config/blob/abf0d8560594475661a0b80fd47d477cbc8a459f/secrets/secrets.yaml
      # FIXME https://github.com/search?q=repo%3Agetsops%2Fsops%20sops%20metadata%20not%20found&type=issues&p=2 I guess solution was along the lines of https://github.com/getsops/sops/issues/856#issuecomment-821153667
    };
  };
}
