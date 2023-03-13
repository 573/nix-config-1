{ config, lib, pkgs, ... }:

{
  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      non-nixos.enable = true;
    };

    development = {
      nix.home-manager.enable = true;
    };

    programs = {
      shell.initExtra = ''
        #. ${config.home.homeDirectory}/.aliases.sh
      '';
    };
  };

  services.syncthing.enable = true;

  home = {
    homeDirectory = "/home/dani";
    username = "dani";

    packages = with pkgs; [
      my-neovim
      #ranger
      photoprism
      #alejandra
      shellharden
      shfmt
      #rnix-lsp
      #deadnix
      #statix
      #nixfmt
      lua-language-server
      texlab
      stylua
      shellcheck
      gist
      #cachix
      #nil
      ripgrep
      ltex-ls
      yt-dlp
      micro
      #ranger
      masterpdfeditor
      ouch
      abcde
      cups-filters
      talon
      scrcpy
      autorandr
      mons
      xorg.libxcvt
      xorg.xrandr
      maim
      xdotool
      xclip
      keepassxc
      swappy
      arandr
      xterm
      signal-desktop
      nixd
      tailscale
      my-emacs
      openssh
    ];

    sessionPath = [
      #"${config.home.homeDirectory}/projects/sedo/devops-scripts/bin"
    ];

    sessionVariables = {
      # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
      LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
  };

  xdg.enable = true;

  # see https://github.com/nix-community/neovim-nightly-overlay/wiki/Tree-sitter
  /*xdg.configFile."nvim/parser/lua.so".source =
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
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-latex}/parser";*/
}
