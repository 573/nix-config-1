{ config, lib, pkgs, rootPath, ... }: {
  custom = {
    base = {
      general.lightWeight = true;

      non-nixos = {
        enable = true;
        installNix = false;
      };
    };

    development.nix.nix-on-droid.enable = true;

    programs = { shell.shellAliases = { vimdiff = "nvim -d"; }; };
  };

  home = {
    packages = with pkgs; [
      #broot
      vale
      #zk
      (writeShellScriptBin "tailscale" ''
          ${pkgs.sysvtools}/bin/pidof tailscaled &>/dev/null || {
         echo "starting tailscaled"
         nohup ${pkgs.busybox}/bin/setsid ${pkgs.tailscale}/bin/tailscaled -tun userspace-networking </dev/null &>/dev/null & jobs -p %1
        }

        [[ -n $1 ]] && {
         ${pkgs.tailscale}/bin/tailscale "$@"
         }
      '')
      (texlive.combine { inherit (texlive) scheme-minimal latexindent; })
      alejandra
      shellharden
      shfmt
      rnix-lsp
      deadnix
      statix
      nixfmt
      sumneko-lua-language-server
      texlab
      nodePackages.bash-language-server
      nodePackages.vim-language-server
      nodePackages.typescript
      nodePackages.typescript-language-server
      deno
      stylua
      sqlite
      nodePackages.vscode-json-languageserver-bin
      xsel
      nodejs_latest 
      yarn
      shellcheck
      chafa
      gist
      cachix
      nil
      w3m
      fff
      ripgrep
      neovim
      manix
      lolcat
      fd
      epr
      nodePackages.yaml-language-server
      haskell-language-server
    ];

    sessionVariables =
      let
        profiles = [ "/nix/var/nix/profiles/default" "$HOME/.nix-profile" ];
        dataDirs =
          lib.concatStringsSep ":" (map (profile: "${profile}/share") profiles);
      in
      {
        XDG_DATA_DIRS = "${dataDirs}\${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS";
        MANPAGER = "less -FirSwX";
      };
  };

  programs.bash = with pkgs.lib; {
    enable = true;
    historySize = 10000000;
    historyFileSize = 10000000;
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    historyIgnore = [ "ls" "cd" "exit" ];

    logoutExtra = ''
      ${pkgs.procps}/bin/pkill -KILL -u $USER tailscaled
    '';
    shellAliases = {
      vimdiff = "nvim -d";
      mv = "mv -i";
      cp = "cp -i";
      ln = "ln -i";
    };
  };

  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    userName = "Daniel Kahlenberg";
    userEmail = "573@users.noreply.github.com";

    extraConfig = {
      credential.helper = "cache";

      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };

      mergetool = {
        prompt = true;
        writeToTemp = true;
      };
    };
  };

  xdg.enable = true;

  # see https://github.com/nix-community/neovim-nightly-overlay/wiki/Tree-sitter
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
}
