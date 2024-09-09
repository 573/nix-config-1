# TODO Rework
{ config, lib, pkgs, rootPath, inputs, emacs, emacsWithPackagesFromUsePackage, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;
  inherit (pkgs.stdenv) isLinux isAarch64;

  emacs-nano = (pkgs.emacsPackages.trivialBuild {
    pname = "emacs-nano";
    version = "0";
    src = "${inputs.nano-emacs}";
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      	    ls -la .
                  target=$out/share/emacs/site-lisp/$pname/
                  mkdir -p "$target"
                  cp *.el "$target"
    '';
    meta = {
      lib.description = "GNU Emacs / N Λ N O is a set of configuration files for GNU Emacs such as to provide a nice and consistent look and feel.";
    };
  });

  my-default-el = pkgs.emacsPackages.trivialBuild {
    pname = "default.el";
    version = "0";
    src = pkgs.writeText "default.el" ''
      (require 'nano)
      (nano-faces)
      (nano-theme)
      (nano-theme-set-light)
      (nano-theme-set-dark)
      (require 'nano-help)
      (require 'nano-splash)
      (nano-modeline)
    '';
    preferLocalBuild = true;
    allowSubstitutes = false;
    buildPhase = "";
  };

  cfg = config.custom.programs.emacs-nano;
in

{

  # TODO research https://github.com/rougier/nano-emacs and nixvim in this flake for how to make many flavours of an editor @once

  ###### interface

  options = {

    custom.programs.emacs-nano = {

      enable = mkEnableOption "emacs config specialised for emacs-nano";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final emacs-nano.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {
    # Or as in https://github.com/szermatt/mistty/issues/14
    custom.programs.emacs-nano.finalPackage = (emacsWithPackagesFromUsePackage {
      alwaysEnsure = true;
      package = emacs;
      extraEmacsPackages = epkgs: builtins.attrValues {
        inherit
	  (epkgs)
        bind-key # FIXME not redundant ? Is in https://github.com/jwiegley/use-package
        use-package
        ;
      } ++ [
        emacs-nano
	my-default-el
      ];
      config = "";
    });

    custom.programs.shell.shellAliases = { } // optionalAttrs (isLinux && isAarch64) { emacs-nano = "emacs-nano -nw"; };

    programs.info.enable = true;

    home.packages = let
      inherit (pkgs)
        runCommand
	makeWrapper
	;
      in [
      (runCommand "emacs-nano" { nativeBuildInputs = [ makeWrapper ]; } ''
        mkdir -p $out/bin	
        makeWrapper ${config.custom.programs.emacs-nano.finalPackage.outPath}/bin/emacs $out/bin/emacs-nano --argv0 emacs    
      '')
    ];
  };
}
