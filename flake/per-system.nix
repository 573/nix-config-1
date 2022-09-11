{ inputs, rootPath, system, }:
let
  config = {
    allowAliases = false;
    allowUnfree = true;
  };

  unstable = import inputs.unstable { inherit config system; };

  moreOverlays = [ inputs.rust-overlay.overlays.default ];

  overlays = [
    (final: prev: {
      inherit (unstable)
        rnix-lsp deadnix statix nixfmt sumneko-lua-language-server texlab
	#deno
        stylua sqlite
	#broot chafa
	w3m 
	#fff
	;

      #inherit (unstable.nodePackages)
      #  bash-language-server vim-language-server typescript
      #  typescript-language-server vscode-json-languageserver-bin;

      somemore = prev.lib.composeManyExtensions moreOverlays final prev;
    })
  ];

  pkgs = import inputs.nixpkgs { inherit config overlays system; };
in
{
  inherit pkgs;

  pkgsNixOnDroid = import inputs.nixpkgs {
    inherit system;
    # allowAliases is needed for nix-on-droid overlays (system <- stdenv.hostPlatform.system)
    config = config // { allowAliases = true; };
    overlays = overlays ++ [
      inputs.nix-on-droid.overlay
      (self: super:
        let
          telescope-makefile = super.vimUtils.buildVimPlugin {
            name = "telescope-makefile";
            src = inputs.telescope-makefile;
          };
          markid = super.vimUtils.buildVimPlugin {
            name = "markid";
            src = inputs.markid;
          };
          virtual-types-nvim = super.vimUtils.buildVimPlugin {
            name = "virtual-types.nvim";
            src = inputs.virtual-types-nvim;
          };
          code-runner-nvim = super.vimUtils.buildVimPlugin {
            name = "code_runner.nvim";
            src = inputs.code-runner-nvim;
          };
          nvim-osc52 = super.vimUtils.buildVimPlugin {
            name = "nvim-osc52";
            src = inputs.nvim-osc52;
          };
        in
        {
          inherit rootPath;
          inherit (inputs.unstable.legacyPackages.${super.system})
            nil tree-sitter;
          neovim-nightly-unwrapped =
            inputs.neovim-flake.packages.${super.system}.neovim;
          inherit (inputs.unstable.legacyPackages.${super.system}.tree-sitter)
            allGrammars;
#          inherit (inputs.unstable.legacyPackages.${super.system}.vimPlugins)
#            null-ls-nvim plenary-nvim nvim-lspconfig trouble-nvim nvim-cmp
#            cmp-buffer cmp-path cmp_luasnip cmp-nvim-lsp cmp-omni cmp-emoji
#            cmp-nvim-lua luasnip friendly-snippets lspkind-nvim
#            LanguageTool-nvim vim-grammarous nvim-treesitter comment-nvim
#            nvim-treesitter-context indent-blankline-nvim wildfire-vim
#            nvim-tree-lua;
          inherit code-runner-nvim virtual-types-nvim markid telescope-makefile
            nvim-osc52;
        })
    ];
  };

  customLib = import (rootPath + "/lib") {
    inherit (inputs.nixpkgs) lib;
    inherit pkgs;
  };
}
