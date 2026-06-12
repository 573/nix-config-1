/**
  Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

  For `[latest]` and `[unstable]` parameters determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{
  lib,
  pkgs, # latest,
  inputs,
  unstable,
  ...
}:
let
  inherit (lib)
    attrValues
    ;
in
{

  custom = {
    base = {
      desktop = {
        enable = true;
      };

      general.wsl = true;
    };

    programs = {
      #      hledger.enable = true;
      #      tex.enable = true;
      #      zellij.enable = true;
      #      alacritty.enable = true;
      nixbuild.enable = true;
      neovim = {
        enable = true;
        nixd.expr.home-manager = ''(builtins.getFlake "${inputs.self}").nixosConfigurations.DANIELKNB1.options.home-manager.users.type.getSubOptions [ ]'';
      };
    };

    development = {
      nix.nixos.enable = true;
    };

    misc = {
      sdks = {
        enable = false;
        links = {
          inherit (pkgs) jdk21;
        };
      };
    };
  };

  # see https://github.com/wezterm/wezterm/issues/2826#issuecomment-1426557160
  programs.wezterm.enableBashIntegration = true;

  home.packages = attrValues {
    #with pkgs; [
    inherit (pkgs)
      #alejandra
      shellharden
      shfmt
      #rnix-lsp
      #deadnix
      #statix
      #nixfmt
      #    lua-language-server
      #   nodePackages.bash-language-server
      #    nodePackages.vim-language-server
      #deno
      #    stylua
      sqlite
      #  nodePackages.vscode-json-languageserver-bin
      xsel
      #nodejs_latest
      #shellcheck
      chafa
      #cachix
      #nil
      w3m
      #fff
      #my-neovim
      #manix
      #lolcat
      epr
      #my-emacs
      #pandoc
      #rustenv
      # this version fails, use version before https://github.com/573/nix-config-1/actions/runs/6589493931/job/17904090802
      #yt-dlp
      #    micro
      #    jdt-language-server
      #ranger
      #pup
      difftastic
      #    bashdb
      #    desed
      #    gradle-vscode-extension.vscode-gradle
      jacinda
      #    mermaid-cli
      dstask
      nix-prefetch
      hadolint
      hurl
      #      android-studio
      ;

    inherit (pkgs.python3Packages)
      pudb
      ;

    # DONT lib/wrapProgram.nix
    #inherit (pkgs.nixgl)
    #  nixGLIntel
    #  ;

    /*
      inherit
      (latest)
      csvlens
      ;
    */
  };
  /*
    home.file = {
    ".emacs.d/early-init.el".text = ''
      (setq package-enable-at-startup nil)
      (provide 'early-init)
    '';
    };
  */
  xdg.enable = true;

  # see https://github.com/nix-community/neovim-nightly-overlay/wiki/Tree-sitter
  /*
    xdg.configFile."nvim/parser/lua.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-lua}/parser";
    xdg.configFile."nvim/parser/python.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-python}/parser";
    xdg.configFile."nvim/parser/nix.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-nix}/parser";
    xdg.configFile."nvim/parser/ruby.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-ruby}/parser";
    xdg.configFile."nvim/parser/vim.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-vim}/parser";
    xdg.configFile."nvim/parser/json.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-json}/parser";
    xdg.configFile."nvim/parser/bash.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-bash}/parser";
    xdg.configFile."nvim/parser/comment.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-comment}/parser";
    xdg.configFile."nvim/parser/latex.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-latex}/parser";
  */
}
