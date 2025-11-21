{ pkgs, inputs }:

let
  callPackage = pkgs.lib.callPackageWith {
    inherit pkgs;
    inherit (pkgs) lib;
    inherit inputs;
  };

  # all these are called with parameters pkgs, lib and inputs for now
  # see:callPackage above
  commonConfig = callPackage ./common-config.nix { };
  fileList = callPackage ./file-list.nix { };
  script = callPackage ./script { };
  wrapProgram = callPackage ./wrap-program.nix { };
in

{
  # example uses: 
  #  config.lib.custom.wrapProgram { ... };
  #  commonConfig = config.lib.custom.commonConfig configArgs; # then commonConfig.<attributes>
  inherit commonConfig;
  inherit (fileList) listNixFilesRecursive;
  inherit (script)
    mkScript
    mkScriptPlain
    mkScriptPlainNixShell
    mkZshCompletion
    ;
  inherit (wrapProgram) wrapProgram;
}
