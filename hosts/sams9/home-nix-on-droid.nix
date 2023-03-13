{ config, lib, pkgs, rootPath, ... }: {
  custom = {
    base = {
      general.lightWeight = true;

      non-nixos = {
        enable = true;
        installNix = false;
        #builders = [
        #  "ssh://private.maiziedemacchiato aarch64-linux - 4"
        #];
      };
    };

    development.nix.nix-on-droid.enable = true;

    programs = {
      shell.logoutExtra = ''
        ${pkgs.procps}/bin/pkill -KILL -u $USER tailscaled
      '';

      # FIXME: tmux does not start
      tmux.enable = lib.mkForce false;

    };
  };

  home = {
    packages = with pkgs; [
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
      (texlive.combine { inherit (texlive) scheme-minimal latexindent; })
      #alejandra
      #shellharden
      #shfmt
      #rnix-lsp
      #deadnix
      #statix
      #nixfmt
      #lua-language-server
      texlab
      #nodePackages.bash-language-server
      #nodePackages.vim-language-server
      #deno
      #stylua
      #sqlite
      #nodePackages.vscode-json-languageserver-bin
      #xsel
      #nodejs_latest
      #yarn
      #shellcheck
      #chafa
      gist
      cachix
      #nil
      #w3m
      #fff
      ripgrep
      #my-neovim
      #manix
      #lolcat
      fd
      epr
      #nodePackages.yaml-language-server
      #ghcWithHoogle
      ltex-ls
      #my-emacs
      #tree-grepper # broken curr. - https://github.com/573/nix-config-1/actions/runs/3950774557/jobs/6763762288#step:5:10931
      #rust-bin.stable.latest.default
      #rust-bin.stable.latest.rust-analyzer
      yt-dlp
      #ranger
      #jdt-language-server
      devenv
      ouch
      bashdb
      #hydra-check
      hledger
      hledger-web
      pandoc
      nixd
      #bpython
      sd
    ];

    activation = let inherit config; in {
      copyFont =
        let
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
          	      '';
    };
  };

  # REF programs.git deleted after https://github.com/573/nix-config-1/commit/45ead62b6fec76ff71bd664830dd62145fe08d19

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
