{ inputs, rootPath, system, }:
let
  config = {
    allowAliases = false;
    allowUnfree = true;
  };

  unstable = import inputs.unstable { inherit config system; };

  moreOverlays = [
    inputs.rust-overlay.overlays.default
    # dont use see https://github.com/nix-community/neovim-nightly-overlay/issues/153#issuecomment-1264366764
    # inputs.neovim-nightly-overlay.overlay
  ];

  overlays = [
    (final: prev: {
      inherit (unstable)
        alejandra nil
        rnix-lsp

        deadnix statix nixfmt sumneko-lua-language-server texlab
        deno

        stylua nnn
        sqlite

        #broot chafa

        #w3m

        #fff

        ;

      nodePackages = prev.nodePackages // {
        inherit (unstable.nodePackages)
          bash-language-server vim-language-server typescript
          typescript-language-server vscode-json-languageserver-bin;
      };

      vimPlugins = prev.vimPlugins // {
        inherit (unstable.vimPlugins)
          cmp-cmdline null-ls-nvim plenary-nvim nvim-lspconfig trouble-nvim
          nvim-cmp cmp-buffer cmp-path cmp_luasnip cmp-nvim-lsp cmp-omni
          cmp-emoji cmp-nvim-lua luasnip friendly-snippets lspkind-nvim
          #            LanguageTool-nvim

          vim-grammarous comment-nvim nvim-treesitter nvim-treesitter-context
          indent-blankline-nvim wildfire-vim nvim-tree-lua nnn-vim;
      };

      builtGrammars = prev.tree-sitter.builtGrammars // {
        inherit (unstable.tree-sitter.builtGrammars)
          tree-sitter-lua tree-sitter-python tree-sitter-nix tree-sitter-ruby
          tree-sitter-vim tree-sitter-json tree-sitter-bash tree-sitter-comment
          tree-sitter-latex;
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

      nvim-treesitter-full-uns = unstable.vimPlugins.nvim-treesitter.withPlugins
        (_: unstable.tree-sitter.allGrammars);

      nvim-treesitter-full = (final.vimPlugins.nvim-treesitter.withPlugins
        (_: final.tree-sitter.allGrammars)).overrideAttrs
        (_: { src = inputs.nvim-treesitter; });

      nvim-treesitter-selection = (final.vimPlugins.nvim-treesitter.withPlugins
        (_:
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

     inherit (inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}) neovim;

      somemore = prev.lib.composeManyExtensions moreOverlays final prev;

      # the only alias that I need, this allows me to set allowAliases=false
      inherit (prev.stdenv.hostPlatform) system;
      inherit (prev.nixVersions) nix_2_4; # for nix-on-droid (nix_2_4 enforced, see https://github.com/t184256/nix-on-droid/blob/83ab4679924bcd3d768b66e1f5541e5c807deecc/nix-on-droid/default.nix#L18)
    })
    inputs.nix-on-droid.overlay
  ];

  pkgs = import inputs.nixpkgs { inherit config overlays system; };
  pkgsNixOnDroid = import inputs.nixpkgs { inherit config overlays system; };
in
{
  inherit pkgs pkgsNixOnDroid;

  customLib = import (rootPath + "/lib") {
    inherit (inputs.nixpkgs) lib;
    inherit pkgs;
  };
}
