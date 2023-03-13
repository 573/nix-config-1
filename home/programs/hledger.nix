{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    mkAfter
    mkDefault
    mkEnableOption
    mkIf
    optionals
    ;

  inherit (pkgs.stdenv) isLinux isx86_64;

  cfg = config.custom.programs.hledger;
in

{

  ###### interface

  options = {

    custom.programs.hledger = {
      enable = mkEnableOption "hledger config";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs = {
      shell = {
        initExtra = ''
          source ${inputs."hledger-completion.bash".outPath}/hledger/shell-completion/hledger-completion.bash
        '';
        envExtra = mkDefault (
          mkAfter ''
            LEDGER_FILE = "~/finance/2023.journal"
          ''
        );
      };
    };

    home = {
      packages = [
        (config.lib.custom.wrapProgram {
          name = "hledger";
          source = pkgs.hledger;
          path = "/bin/hledger";
          editor = pkgs.micro; # TODO replace by nvim when faster
        })
        #pkgs.hledger-check-fancyassertions
        pkgs.hledger-interest
        pkgs.hledger-utils
      ] ++ optionals (isLinux && isx86_64) [
        # pkgs.hledger-iadd # DONT on demand can retrieve via nix profile install nixpkgs/d1c3fea7ecbed758168787fe4e4a3157e52bc808#haskellPackages.hledger-iadd, see https://gist.github.com/573/6b02765d71c27edb10c481e4746e7264
        pkgs.hledger-ui
        pkgs.hledger-web
        # pkgs.hledger-flow # DONT same as hledger-flow above
      ];
      sessionPath = [ "${inputs.hledger-bin.outPath}/bin" ];
    };

  };

}
