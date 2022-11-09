{ inputs,
 rootPath,
system, nixOnDroid ? false, }:
let
  config = {
    allowAliases = false;
    allowUnfree = true;
  };
in import inputs.nixpkgs {
  inherit config system;

  overlays = [
    (final: prev:
      let
        inherit (prev.stdenv.hostPlatform) system;

        unstable = import inputs.unstable { inherit config system; };
        master = import inputs.master { inherit config system; };
        staging = import inputs.staging { inherit config system; };

        moreOverlays = [
          inputs.rust-overlay.overlays.default
          # dont use see https://github.com/nix-community/neovim-nightly-overlay/issues/153#issuecomment-1264366764
          inputs.neovim-nightly-overlay.overlay # What I try to achieve here is to have neovim as overridden in the overlay below be the neovim neovim-nightly-overlay provides !??
        ];
      in {
        somemore = prev.lib.composeManyExtensions moreOverlays final prev;

        inherit (unstable)
          alejandra nil rnix-lsp manix lolcat fd deadnix statix nixfmt
          sumneko-lua-language-server texlab
          ##deno # long rebuild needed in unstable so taking release-version

          stylua nnn
          ##sqlite # long rebuild needed in unstable so taking release-version

          nodejs_latest # long rebuild needed in unstable so taking release-version
          yarn # long rebuild needed in unstable so taking release-version

          #broot

          chafa ripgrep
          ##w3m # long rebuild needed in unstable so taking release-version, see i. e. nix why-depends --derivation nixos-unstable#w3m nixos-unstable#fontforge

          ##fff # long rebuild needed in unstable so taking release-version, see i. e. nix why-depends --derivation nixos-unstable#w3m nixos-unstable#fontforge

epr

vale
haskell-language-server
        ;

        nodePackages = prev.nodePackages // {
          inherit (unstable.nodePackages)
            bash-language-server vim-language-server typescript
            typescript-language-server vscode-json-languageserver-bin yaml-language-server;
        };

        vimPlugins = prev.vimPlugins // {
          inherit (unstable.vimPlugins)
            cmp-cmdline null-ls-nvim plenary-nvim nvim-lspconfig trouble-nvim
            nvim-cmp cmp-buffer cmp-path cmp_luasnip cmp-nvim-lsp cmp-omni
            cmp-emoji cmp-nvim-lua luasnip friendly-snippets lspkind-nvim
            #            LanguageTool-nvim

            vim-grammarous comment-nvim nvim-treesitter nvim-treesitter-context
            indent-blankline-nvim wildfire-vim nvim-tree-lua nnn-vim
            asyncrun-vim vim-table-mode telescope-nvim;
        };

        builtGrammars = prev.tree-sitter.builtGrammars // {
          inherit (unstable.tree-sitter.builtGrammars)
            tree-sitter-lua tree-sitter-python tree-sitter-nix tree-sitter-ruby
            tree-sitter-vim tree-sitter-json tree-sitter-bash
            tree-sitter-comment tree-sitter-latex;
        };

        telescope-makefile = prev.vimUtils.buildVimPlugin {
          name = "telescope-makefile";
          src = inputs.telescope-makefile;
        };
        markid = prev.vimUtils.buildVimPlugin {
          name = "markid";
          src = inputs.markid;
        };
        virtual-types-nvim = prev.vimUtils.buildVimPlugin {
          name = "virtual-types.nvim";
          src = inputs.virtual-types-nvim;
        };
        code-runner-nvim = prev.vimUtils.buildVimPlugin {
          name = "code_runner.nvim";
          src = inputs.code-runner-nvim;
        };
        nvim-osc52 = prev.vimUtils.buildVimPlugin {
          name = "nvim-osc52";
          src = inputs.nvim-osc52;
        };
        haskell-tools-nvim = prev.vimUtils.buildVimPlugin {
          name = "haskell-tools.nvim";
          src = inputs.haskell-tools-nvim;
        };

        nvim-treesitter-full-uns =
          unstable.vimPlugins.nvim-treesitter.withPlugins
          (_: unstable.tree-sitter.allGrammars);

        nvim-treesitter-full = (final.vimPlugins.nvim-treesitter.withPlugins
          (_: final.tree-sitter.allGrammars)).overrideAttrs
          (_: { src = inputs.nvim-treesitter; });

        nvim-treesitter-selection =
          (final.vimPlugins.nvim-treesitter.withPlugins (_:
            with final.tree-sitter.builtGrammars; [
              tree-sitter-lua
              tree-sitter-python
              tree-sitter-nix
              tree-sitter-ruby
              tree-sitter-vim
              tree-sitter-json
              tree-sitter-bash
              tree-sitter-comment
              tree-sitter-latex
            ])).overrideAttrs (_: { src = inputs.nvim-treesitter; });

        inherit rootPath;

        # inherit (inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}) neovim; # see staging PR note

        neovim = unstable.neovim.override {
          # final.neovim-nightly.override { # error: attribute 'neovim-nightly' missing # final, weil das overlay bereits applied wurde # inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.neovim.override { # error: anonymous function at /nix/store/yz0w1s863vqsas7jpzg5rpc29ig17566-source/pkgs/applications/editors/neovim/default.nix:1:1 called with unexpected argument 'viAlias' # inputs.neovim-flake.packages.${prev.stdenv.hostPlatform.system}.neovim.override { # I wonder why final.neovim-nightly doesn't work here or eveb final.neovim when the overlay is applied already above
          viAlias = true;
          vimAlias = true;
          # vimdiffAlias = true; # for this needs to override wrapNeovimUnstable in overlay (https://github.com/NixOS/nixpkgs/pull/121339#issuecomment-830868690)
          configure = {
            packages.plugins = {
              start = (with final.vimPlugins; [
                # https://gitlab.com/rycee/home-manager/blob/de3758e3/modules/programs/neovim.nix#L113
                null-ls-nvim
                plenary-nvim
                nvim-lspconfig
                trouble-nvim
                nvim-cmp
                cmp-cmdline
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
                # LanguageTool-nvim
                vim-grammarous
                comment-nvim
                nvim-treesitter-context
                indent-blankline-nvim
                wildfire-vim
                nvim-tree-lua
                nnn-vim
                asyncrun-vim
                vim-table-mode
                telescope-nvim
                final.nvim-treesitter-full-uns
                #pkgs.nvim-treesitter-selection
              ]) ++ (with final; [
                markid
                nvim-osc52
                telescope-makefile
                code-runner-nvim
                virtual-types-nvim
                #nvim-cmp
		haskell-tools-nvim
              ]);
            };

            #extraConfig = ''
            customRC = ''
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
                     luafile ${
                       rootPath + "/home/misc/nvim-treesitter-context.lua"
                     }
                     luafile ${rootPath + "/home/misc/nvim-osc52.lua"}
              luafile ${rootPath + "/home/misc/telescope-nvim.lua"}


                     " let g:languagetool_server_command='$ { pkgs.languagetool }/bin/languagetool-http-server'
            '';
          };
        };

        # the only alias that I need, this allows me to set allowAliases=false
        inherit system;
        inherit (prev.nixVersions) nix_2_4; # for nix-on-droid
      })

    #inputs.nixGL.overlays.default
  ] ++ inputs.nixpkgs.lib.optional nixOnDroid
    inputs.nix-on-droid.overlays.default;
}
