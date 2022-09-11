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
      diffutils
      findutils
      gawk
      glibc.bin
      gnugrep
      gnused
      hostname
      man
      ncurses

      #gitMinimal
      #broot
      #vale
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
      #(texlive.combine { inherit (texlive) scheme-minimal latexindent; })
      alejandra
      #neovim-unwrapped
      shellharden
      shfmt
      rnix-lsp
      deadnix
      statix
      nixfmt
      sumneko-lua-language-server
      texlab
      #nodePackages.bash-language-server
      #nodePackages.vim-language-server
      #nodePackages.typescript
      #nodePackages.typescript-language-server
      #deno
      stylua
      sqlite
      #nodePackages.vscode-json-languageserver-bin
      #xsel
      #nodejs_latest
      #yarn
      shellcheck
      #chafa
      gist
      cachix
      nil
      w3m
      #fff
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

    activation =
      let inherit config;
      in
      {
        copyFont =
          let
            #        d = builtins.head pkgs.texlive.carlito.pkgs;
            #        font_src = "${d.outPath}";
            #        font_dst = "${config.home.homeDirectory}/.fonts";
            font_src = "${pkgs.carlito}/share/fonts/truetype/.";
            font_dst = "${config.home.homeDirectory}/texmf/fonts/truetype/Carlito";
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                   test -e "${font_dst}" && comm -1 -3 <(sha1sum ${font_src}/*.ttf|cut -d' ' -f1) <(sha1sum ${font_dst}/*.ttf|cut -d' ' -f1) &>/dev/null
            if [ $? -ne 0 ]
            then
              mkdir -p "${font_dst}"
              cp -R "${font_src}" "${font_dst}"
            fi
            # TODO if the *ttf existed but had
            # different sha1sums a permission error
            # might be thrown, manually remove them:
                   #chmod -R 0777 "${font_dst}"
                   #rm "${font_dst}" -r
          '';
      };

    file.".vale.ini".source = pkgs.runCommandNoCC "_vale.ini"
      {
        iniFile = ''
          StylesPath = ${builtins.getEnv "HOME"}/styles

          MinAlertLevel = suggestion
          #Vocab = Base

          Packages = Google, proselint, write-good, alex, Readability

          [*]
          BasedOnStyles = Vale, Google, proselint, write-good, alex, Readability
        '';
      } ''
              # line 5 in nix file = line 1 in bash script -> offset 4
              PS4='+ Line $(expr $LINENO + 4): '
              set -o xtrace # print commands
              cat << EOF > $out
                  $iniFile
      EOF
       mkdir -p ${builtins.getEnv "HOME"}/styles
       ${pkgs.vale}/bin/vale --config=$out ls-config
       ${pkgs.vale}/bin/vale --config=$out sync
    '';
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
  xdg.configFile."nvim/parser/c.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-c}/parser";
  xdg.configFile."nvim/parser/lua.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-lua}/parser";
  xdg.configFile."nvim/parser/rust.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-rust}/parser";
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
  xdg.configFile."nvim/parser/haskell.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-haskell}/parser";
  xdg.configFile."nvim/parser/comment.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-comment}/parser";
  xdg.configFile."nvim/parser/markdown.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-markdown}/parser";
  xdg.configFile."nvim/parser/latex.so".source =
    "${pkgs.tree-sitter.builtGrammars.tree-sitter-latex}/parser";

  # https://github.com/biosan/dotfiles/blob/ca534cc/config/nix/common.nix
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly-unwrapped;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = false;
    withRuby = false;
    #withNodeJs = true;
    #extraPython3Packages = [ pkgs.python-language-server ];
    #extraLuaPackages = [ pkgs.luautf8 ];
    # https://gitlab.com/rycee/home-manager/blob/de3758e3/modules/programs/neovim.nix#L113
    plugins = (with pkgs.vimPlugins; [
      null-ls-nvim
      plenary-nvim
      nvim-lspconfig
      trouble-nvim
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp_luasnip
      cmp-nvim-lsp
      cmp-omni
      cmp-emoji
      cmp-nvim-lua
      luasnip
      friendly-snippets
      lspkind-nvim
      LanguageTool-nvim
      vim-grammarous
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
      comment-nvim
      nvim-treesitter-context
      indent-blankline-nvim
      wildfire-vim
      nvim-tree-lua
    ]) ++ (with pkgs; [
      markid
      nvim-osc52
      telescope-makefile
      code-runner-nvim
      virtual-types-nvim
    ]);
    extraConfig = ''
       if filereadable($HOME . "/.vimrc")
         source ~/.vimrc
      endif
      luafile ${rootPath + "/home/misc/nvim-treesitter.lua"}
      luafile ${rootPath + "/home/misc/trouble-nvim.lua"}
      luafile ${rootPath + "/home/misc/null-ls-nvim.lua"}
      luafile ${rootPath + "/home/misc/nvim-lspconfig.lua"}
      luafile ${rootPath + "/home/misc/nvim-cmp.lua"}
      luafile ${rootPath + "/home/misc/luasnip-snippets.lua"}

      luafile ${rootPath + "/home/misc/comment-nvim.lua"}
      luafile ${rootPath + "/home/misc/indent-blankline.lua"}
      luafile ${rootPath + "/home/misc/markid.lua"}
      luafile ${rootPath + "/home/misc/null-ls-nvim.lua"}
      luafile ${rootPath + "/home/misc/nvim-treesitter-context.lua"}
      luafile ${rootPath + "/home/misc/nvim-osc52.lua"}

      let g:languagetool_server_command='${pkgs.languagetool}/bin/languagetool-http-server'
    '';
  };
}
