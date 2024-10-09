{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.custom.agenix-rekey;
in
{
  imports = [
    # TODO get used to handling first, see example at https://github.com/oddlama/agenix-rekey/pull/28#issue-2331901837
    # with these imports assert fails as long TODO not finished
    #    inputs.agenix.nixosModules.default
    #    inputs.agenix-rekey.nixosModules.default
  ];

  ###### interface

  options = {
    custom.agenix-rekey.enable = mkEnableOption "agenix-rekey";
  };

  ###### implementation

  config = mkIf cfg.enable {
    age = { };
  };
}
