{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.neovim;

  extraConfig = ''
           if filereadable($HOME . "/.vimrc")
              source ~/.vimrc
           endif
           colorscheme lunaperche
           luafile ${rootPath}/home/misc/nvim-treesitter.lua
           luafile ${rootPath}/home/misc/trouble-nvim.lua
           " luafile ${rootPath}/home/misc/null-ls-nvim.lua
           luafile ${rootPath}/home/misc/nvim-lspconfig.lua
           luafile ${rootPath}/home/misc/nvim-cmp.lua
           luafile ${rootPath}/home/misc/luasnip-snippets.lua
           luafile ${rootPath}/home/misc/comment-nvim.lua
           luafile ${rootPath}/home/misc/indent-blankline.lua
           luafile ${rootPath}/home/misc/markid.lua
           luafile ${rootPath}/home/misc/nvim-treesitter-context.lua
           luafile ${rootPath}/home/misc/nvim-osc52.lua
           luafile ${rootPath}/home/misc/telescope-nvim.lua
           luafile ${rootPath}/home/misc/duck-nvim.lua
           luafile ${rootPath}/home/misc/nvim-dap.lua
           luafile ${rootPath}/home/misc/nvim-dap-ui.lua
    lua require("nvim-tree").setup()
    lua require("which-key").setup()
    lua require("lualine").setup()
           luafile ${rootPath}/home/misc/nvim-wsl-clipboard.lua

           " let g:languagetool_server_command='$ { pkgs.languagetool }/bin/languagetool-http-server'
  '';

  plugins = (with pkgs.vimPlugins; [
    # https://gitlab.com/rycee/home-manager/blob/de3758e3/modules/programs/neovim.nix#L113
    # null-ls-nvim
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
    #vim-grammarous
    comment-nvim
    nvim-treesitter-context
    indent-blankline-nvim
    wildfire-vim
    nvim-tree-lua
    nnn-vim
    asyncrun-vim
    vim-table-mode
    telescope-nvim
    zen-mode-nvim
    which-key-nvim
    vimtex
    haskell-tools-nvim
    nvim-osc52
    lualine-nvim
    nix-develop-nvim
    nvim-dap
    nvim-dap-python
    neoterm
    nvim-gdb
    nvim-dap-ui
    nvim-treesitter-endwise
    orgmode
    neorg
    pkgs.nvim-treesitter-full-latest
    #pkgs.nvim-treesitter-selection
  ])
  ++ (with pkgs; [
    markid
    telescope-makefile
    code-runner-nvim
    virtual-types-nvim
    #fsread-nvim
    deferred-clipboard-nvim
    statusline-action-hints-nvim
    #murmur-lua-nvim
    filetype-nvim
    duck-nvim
    #nvim-lspconfig
  ]);
in

{

  ###### interface

  options = {

    custom.programs.neovim = {

      enable = mkEnableOption "neovim config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final neovim.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.neovim = { inherit (config.programs.neovim) finalPackage; };

    home.sessionVariables.EDITOR = "nvim";

    programs.neovim = {
      inherit extraConfig plugins;

      enable = true;
      viAlias = true;
      vimAlias = true;
    };

  };

}
