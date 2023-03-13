{ config, lib, pkgs, rootPath, ... }: {

  custom.base.general.wsl = true;

  home.packages = with pkgs; [
    #alejandra
    shellharden
    shfmt
    #rnix-lsp
    #deadnix
    #statix
    #nixfmt
    lua-language-server
    texlab
    nodePackages.bash-language-server
    nodePackages.vim-language-server
    #deno
    stylua
    sqlite
    nodePackages.vscode-json-languageserver-bin
    xsel
    #nodejs_latest
    #yarn
    shellcheck
    chafa
    gist
    #cachix
    #nil
    w3m
    #fff
    ripgrep
    #my-neovim
    #manix
    #lolcat
    fd
    epr
    nodePackages.yaml-language-server
    ltex-ls
    #my-emacs
    ripgrep-all
    pandoc
    rustenv
    yt-dlp
    micro
    jdt-language-server
    #ranger
    devenv
    #pup
    ouch
    git-absorb
    difftastic
    bashdb
    desed
    gradle-vscode-extension.vscode-gradle
    nixd
    sd
  ];
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
