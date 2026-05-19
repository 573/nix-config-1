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
  # ?? wrap-program rather with explicit arch to avoid
  # error: Package ‘intel-gmmlib-22.8.2’ in /nix/store/a5aidy9jhg4zgkglc3w49klammcp62wy-source/pkgs/by-name/in/intel-gmmlib/package.nix:31 is not available on the requested hostPlatform:
  #       hostPlatform.system = "aarch64-linux
  # maybe not: See https://discourse.nixos.org/t/confusing-home-manager-behavior-around-targets-genericlinux-gpu-enable/76883
  wrapProgram = callPackage ./wrap-program.nix {
    #pkgs = pkgs.legacyPackages."x86_64-linux";
  };
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
