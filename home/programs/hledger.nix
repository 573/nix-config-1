/**
  Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

  For `[haskellPackages]` parameter determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{
  config,
  lib,
  pkgs,
  inputs,
  haskellPackages,
  ...
}:

let
  inherit (lib)
    mkAfter
    mkDefault
    mkEnableOption
    mkIf
    optionals
    ;

  inherit (pkgs.stdenv) isLinux isx86_64;

  inherit (haskellPackages)
    hledger_1_40
    hledger-web_1_40
    hledger-ui_1_40
    hledger-interest
    ;

  inherit (pkgs)
    hledger-utils
    ;

  /**
    Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

    If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
  */
  # inherit (pkgs.stdenv.hostPlatform) system;

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
        envExtra = mkDefault (mkAfter ''
          LEDGER_FILE = "~/finance/2024.journal"
        '');
      };
    };

    home = {
      packages =
        [
          (config.lib.custom.wrapProgram {
            name = "hledger";
            source = hledger_1_40;
            path = "/bin/hledger";
            editor = pkgs.micro; # TODO replace by nvim when faster
          })
          #pkgs.hledger-check-fancyassertions
          hledger-interest
          hledger-utils
        ]
        ++ optionals (isLinux && isx86_64) [
          # pkgs.hledger-iadd # DONT on demand can retrieve via nix profile install nixpkgs/d1c3fea7ecbed758168787fe4e4a3157e52bc808#haskellPackages.hledger-iadd, see https://gist.github.com/573/6b02765d71c27edb10c481e4746e7264
          hledger-ui_1_40
          hledger-web_1_40
          # pkgs.hledger-flow # DONT same as hledger-flow above
        ];
      sessionPath = [ "${inputs.hledger-bin.outPath}/bin" ];
    };

  };

}
