# TODO Rework
{
  config,
  lib,
  pkgs,
  rootPath,
  inputs,
  emacs,
  emacsWithPackagesFromUsePackage,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;
  inherit (pkgs.stdenv) isLinux isAarch64;

  inherit (emacs.pkgs) withPackages; # crucial to use the right version here as epkgs get byte-compiled for this exact emacs

  org-novelist = (
    emacs.pkgs.trivialBuild rec {
      pname = "org-novelist";
      version = "0";
      src = "${inputs.org-novelist.outPath}";
      installPhase = ''
        target=$out/share/emacs/site-lisp/$pname/${pname}.el
        mkdir -p "$(dirname "$target")"
        cp "$src/${pname}.el" "$(dirname "$target")"
      '';
      meta = {
        description = "Org Novelist is a system for writing novel-length fiction using Emacs Org mode.";
      };
    }
  );

  ox-odt = emacs.pkgs.melpaBuild {
    pname = "ox-odt";
    # nix-style unstable version 0-unstable-20240427 can be used after
    # https://github.com/NixOS/nixpkgs/pull/316726 reaches you
    version = "20240427.0";
    src = pkgs.fetchFromGitHub {
      owner = "kjambunathan";
      repo = "org-mode-ox-odt";
      rev = "89d3b728c98d3382a8e6a0abb8befb03d27d537b";
      hash = "sha256-/AXechWnUYiGYw/zkVRhUFwhcfknTzrC4oSWoa80wRw=";
    };
    # not needed after https://github.com/NixOS/nixpkgs/pull/316107 reaches you
    commit = "foo";

    # use :files to include only related files
    # https://github.com/melpa/melpa?tab=readme-ov-file#recipe-format
    recipe = pkgs.writeText "recipe" ''
      (ox-odt :fetcher git :url "")
    '';
  };

  ox-html-markdown-style-footnotes = (
    emacs.pkgs.trivialBuild rec {
      pname = "ox-html-markdown-style-footnotes";
      version = "0.2.0";
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/jeffkreeftmeijer/ox-html-markdown-style-footnotes.el/0.2.0/ox-html-markdown-style-footnotes.el";
        sha256 = "sha256-S+lzFpGY44OgXAeM9Qzdhvceh8DvvOFiw5tgXoXDrsQ=";
      };

      meta = with lib; {
        description = "Markdown-style footnotes for ox-html.el";
        homepage = "https://jeffkreeftmeijer.com/ox-html-markdown-style-footnotes/";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
    }
  );

  # TODO https://emacsnotes.wordpress.com/2022/06/29/use-org-extra-emphasis-when-you-need-more-emphasis-markers-in-emacs-org-mode/
  org-extra-emphasis = (
    emacs.pkgs.trivialBuild rec {
      pname = "org-extra-emphasis";
      version = "1";
      src = "${inputs.org-extra-emphasis.outPath}";
      # elisp dependencies
      #propagatedUserEnvPkgs = [
      #  ox-odt
      #];
      #buildInputs = propagatedUserEnvPkgs;
      #   installPhase = ''
      #     target=$out/share/emacs/site-lisp/$pname/${pname}.el
      #     mkdir -p "$(dirname "$target")"
      #     cp "$src/${pname}.el" "$(dirname "$target")"
      #   '';
      meta = {
        description = "Extra Emphasis markers for Emacs Org mode. https://irreal.org/blog/?p=10649";
      };
    }
  );

  # https://raw.githubusercontent.com/hrs/sensible-defaults.el/main/sensible-defaults.el
  # NOTE unused for now
  #my-default-el = pkgs.emacsPackages.trivialBuild {
  # pname = "default.el";
  #    version = "0";
  #src = pkgs.writeText "default.el" ''
  #   '';
  #preferLocalBuild = true;
  # allowSubstitutes = false;
  #  buildPhase = "";
  #};

  cfg = config.custom.programs.emacs-no-el;
in

{

  # TODO research https://github.com/rougier/nano-emacs and nixvim in this flake for how to make many flavours of an editor @once

  ###### interface

  options = {

    custom.programs.emacs-no-el = {

      enable = mkEnableOption "emacs where you load (via -l elfile) your own config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final emacs-no-el.
        '';
      };
      initialPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of package=emacs.
        '';
      };

      homePackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package in home.packages.
        '';
      };
      listOfPkgs = mkOption {
        # unnecessary but I want to learn about building emacs-packages-deps
        # so I could i. e. nix derivation show /nix/store/c8vwsxnbqfp09bg6gwhxvvz3f0hpym6y-emacs-moe-theme-20231006.639.drv | grep '"path"'
        default = null;
        internal = true;
        description = ''
                    list of Extra packages available to Emacs.
          	  nix eval --json .#nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos.custom.programs.emacs-no-el.listOfPkgs  --json
          	  nix build ...
          	   0.0 MiB DL] building emacs-packages-deps
          	  nix derivation show ...
        '';
      };
    };

  };

  ###### implementation

  config =
    let
      fun =
        epkgs:
        builtins.attrValues {
          inherit (epkgs)
            moe-theme
            #better-defaults
            bind-key # FIXME not redundant ? Is in https://github.com/jwiegley/use-package
            use-package
            #writeroom-mode
            which-key
            # https://cestlaz.github.io/posts/using-emacs-16-undo-tree/
            undo-tree
            #smooth-scrolling
            #sensible-defaults
            #sane-defaults
            #jinx
            titlecase
            suggest
            persist-state
            ibuffer-vc
            emacs
            #corfu-terminal
            diminish
            no-littering
            gcmh
            olivetti
            zoom
            orderless
            # https://blog.mads-hartmann.com/emacs/2014/03/03/complete-word-based-on-dictionary.html
            ;

          inherit (epkgs.melpaPackages)
            ac-ispell
            el-fly-indent-mode
            ;
          inherit (epkgs.elpaPackages)
            jinx
            cape
            corfu
            ;
        }
        ++ [
          org-novelist
          #my-default-el
          org-extra-emphasis # FIXME https://emacsnotes.wordpress.com/2022/06/29/use-org-extra-emphasis-when-you-need-more-emphasis-markers-in-emacs-org-mode/, also install pdflatex etc.
          ox-odt
          ox-html-markdown-style-footnotes
        ];
    in
    mkIf cfg.enable {
      # don't know how to avoid redundancy here
      custom.programs.emacs-no-el.listOfPkgs = withPackages fun;

      custom.programs.emacs-no-el.initialPackage = emacs;

      # Or as in https://github.com/szermatt/mistty/issues/14
      custom.programs.emacs-no-el.finalPackage = (
        emacsWithPackagesFromUsePackage {
          alwaysEnsure = true;
          package = config.custom.programs.emacs-no-el.initialPackage;
          extraEmacsPackages = fun;
          # Your Emacs config file. Org mode babel files are also
          # supported.
          # NB: Config files cannot contain unicode characters, since
          #     they're being parsed in nix, which lacks unicode
          #     support.
          # config = ./emacs.org;
          config = ""; # not used as defaultInitFile below is non-bool

          # Whether to include your config as a default init file.
          # If being bool, the value of config is used.
          # Its value can also be a derivation like this if you want to do some
          # substitution:
          defaultInitFile = pkgs.substituteAll {
            name = "default.el";
            # meaning el-file may contain @out@ etc. references to drv
            src = "${rootPath}/home/misc/emacs.el";
            inherit (pkgs) scowl;
            hunspellDicts_de_DE = pkgs.hunspellDicts.de_DE;
          };
        }
      );

      custom.programs.emacs-no-el.homePackage = (
        pkgs.runCommand "emacs-no-el" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          mkdir -p $out/bin	
          makeWrapper ${config.custom.programs.emacs-no-el.finalPackage.outPath}/bin/emacs $out/bin/emacs-no-el --argv0 emacs    
        ''
      );

      custom.programs.shell.shellAliases =
        { }
        // optionalAttrs (isLinux && isAarch64) { emacs-no-el = "emacs-no-el -nw"; };

      programs.info.enable = true;

      home.packages = builtins.attrValues {
        inherit (pkgs)
          hunspell
          aspell
          enchant
          ;

        inherit (pkgs.hunspellDicts)
          en_US
          de_DE
          ;
        /*
          inherit
             	(pkgs.texliveBasic)
             	out
           	;
        */
        inherit (config.custom.programs.emacs-no-el)
          homePackage
          ;
      };
    };
}
