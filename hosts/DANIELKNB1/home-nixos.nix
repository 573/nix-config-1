{ config, lib, pkgs, rootPath, inputs, ... }: {

  custom = {
    base = {
      desktop = {
        enable = true;
      };

      general.wsl = true;
    };

    programs = {
      hledger.enable = true;
      tex.enable = true;
    };

    development = {
      jbang = {
        enable = false;
        trustedSources = [ "https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/" ];
      };

      nix.nixos.enable = true;
    };

    misc = {
      sdks = {
        enable = false;
        links = {
          inherit (pkgs) jdk21 python310;
        };
      };
    };
  };

  #  programs.doom-emacs = {
  #    enable = true;
  #    doomPrivateDir = "${rootPath}/home/misc/doom.d";
  #  };


  # https://discourse.nixos.org/t/whats-the-difference-between-extraargs-and-specialargs-for-lib-eval-config-nix/5281/2
  #  disabledModules = [ "programs/password-store.nix" ];
  # hyprland has no module in home-manager@release-23.05

  # DONT anymore, this hack isn't needed anymore since https://github.com/nix-community/home-manager/blob/release-23.11/modules/services/window-managers/hyprland.nix
  #imports = [
  #  (args@{ config, lib, pkgs, ... }:
  #    # Pattern: home-manager@master follows nixpkgs@nixpkgs-unstable
  #    import "${inputs.latest-home-manager.outPath}/modules/services/window-managers/hyprland.nix"
  #      (args // { pkgs = inputs.unstable.legacyPackages.${pkgs.system}; })
  #  )
  #];

  home.file.".mob".text = ''
      MOB_TIMER_USER="Daniel"
      MOB_DONE_SQUASH="squash-wip"
    '';

  home.packages = with pkgs; [
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
    python310Packages.pudb
    jacinda
#    mermaid-cli
    dstask
    nixgl.nixGLIntel
    nix-prefetch
    hadolint
    csvlens
    hurl
    oxker
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
