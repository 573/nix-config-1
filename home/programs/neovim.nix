{ config, lib, pkgs, rootPath, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (pkgs.stdenvNoCC.hostPlatform) system;

  cfg = config.custom.programs.neovim;

  # i. e. nix-repl> :p (homeConfigurations."dani@maiziedemacchiato".pkgs.vimUtils.buildVimPluginFrom2Nix { pname = "markid"; src = inputs.markid; version = inputs.markid.rev; }).drvAttrs
  #	  pluggo = name: pkgs.vimUtils.buildVimPlugin {
  #	    pname = name;
  #	    src = inputs."${name}";
  #	    version = "2023-20-10";
  #	  };

  pluggo = pname: inputs.unstable.legacyPackages.${system}.vimUtils.buildVimPlugin { inherit pname; src = inputs."${pname}"; version = "0.1"; };
  /*extraConfig = ''
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
                                	   lua require("gitsigns").setup()
                                	   lua require("stcursorword").setup()
  '';*/
  /*plugins = with pkgs.vimPlugins; [
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
    pkgs.nvim-treesitter-as-in-manual
    #pkgs.nvim-treesitter-selection
    vim-illuminate
    markid
    virtual-types-nvim
    gitsigns-nvim
    # semantic-highlight-vim
    (pluggo "stcursorword")
    (pluggo "murmur.lua")
    (pluggo "action-hints.nvim")
    (pluggo "deferred-clipboard.nvim")
    (pluggo "code_runner.nvim")
    (pluggo "garbage-day.nvim")

    ]
  ;*/
  configuration = {
    colorschemes.catppuccin.enable = true;
    extraPlugins = with pkgs; [
      vimPlugins.nnn-vim
      vimPlugins.trouble-nvim
      vimPlugins.vimtex
      vimPlugins.vim-jack-in
      vimPlugins.neoterm
      (pluggo "nvim-dd")
      (pluggo "faster-nvim")
      #		(pluggo "deadcolumn-nvim")
    ];
    extraConfigLua = ''
      	        require('dd').setup()
                      require("trouble").setup({
                      	-- settings without a patched font or icons
                      	icons = false,
                      	fold_open = "v", -- icon used for open folds
                      	fold_closed = ">", -- icon used for closed folds
                      	indent_lines = false, -- add an indent guide below the fold icons
                      	signs = {
                      		-- icons / text used for a diagnostic
                      		error = "error",
                      		warning = "warn",
                      		hint = "hint",
                      		information = "info"
                      	},
                      	use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
                      })
    '';
    plugins = {
      nvim-osc52.enable = true;
      #treesitter-context.enable = true;
      rainbow-delimiters.enable = true;
      which-key.enable = true;
      conjure.enable = true;
      lsp = {
        enable = true;
        servers = {
          # FIXME still uses i. e. v1.2.3 (https://github.com/nix-community/nixvim/blob/83a7ce9846b1b01a34b3e6b25077c1a5044ad7b3/plugins/lsp/language-servers/default.nix#L455) as of nixos-unstable, see https://github.com/NixOS/nixpkgs/pull/305285#
          nixd.enable = true;
          ltex.enable = true;
          texlab.enable = true;
          lua-ls.enable = true;
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
        };
      };

      treesitter = {
        enable = true;
        nixGrammars = true;
        indent = true;
        # DONT see https://discourse.nixos.org/t/conflicts-between-treesitter-withallgrammars-and-builtin-neovim-parsers-lua-c/33536/3
        /*grammarPackages = with pkgs.tree-sitter-grammars; [
          tree-sitter-nix
          tree-sitter-bash
          tree-sitter-yaml
          tree-sitter-json
          tree-sitter-lua
          tree-sitter-latex
          tree-sitter-comment
        ];*/
        ensureInstalled = [
          "nix"
          "bash"
          "yaml"
          "json"
          "lua"
          "latex"
          "comment"
        ];
      };
      gitsigns = {
        enable = true;
        currentLineBlame = true;
      };
      # # Source: https://github.com/hmajid2301/dotfiles/blob/ab7098387426f73c461950c7c0a4f8fb4c843a2c/home-manager/editors/nvim/plugins/coding/cmp.nix
      luasnip.enable = true;
      cmp-buffer = { enable = true; };

      cmp-emoji = { enable = true; };

      cmp-nvim-lsp = { enable = true; };

      cmp-path = { enable = true; };

      cmp_luasnip = { enable = true; };


      # FIXME Use `plugins.cmp.settings.sources` option
      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "nvim_lua"; }
            { name = "path"; }
          ];
          /*sources = {
                                    		  __raw = ''
      cmp.config.sources({
        { name = 'nvim_lsp' },
        -- { name = 'vsnip' },
        { name = 'luasnip' },
        { name = 'nvim_lua' },
        -- { name = 'ultisnips' },
        -- { name = 'snippy' },
      }, {
        { name = 'buffer' },
        { name = 'path' },
      })
                                    		  '';
                                  		  }; */

          formatting = {
            fields = [ "abbr" "kind" "menu" ];
            format =
              # lua
              ''
                function(_, item)
                  local icons = {
                    Namespace = "󰌗",
                    Text = "󰉿",
                    Method = "󰆧",
                    Function = "󰆧",
                    Constructor = "",
                    Field = "󰜢",
                    Variable = "󰀫",
                    Class = "󰠱",
                    Interface = "",
                    Module = "",
                    Property = "󰜢",
                    Unit = "󰑭",
                    Value = "󰎠",
                    Enum = "",
                    Keyword = "󰌋",
                    Snippet = "",
                    Color = "󰏘",
                    File = "󰈚",
                    Reference = "󰈇",
                    Folder = "󰉋",
                    EnumMember = "",
                    Constant = "󰏿",
                    Struct = "󰙅",
                    Event = "",
                    Operator = "󰆕",
                    TypeParameter = "󰊄",
                    Table = "",
                    Object = "󰅩",
                    Tag = "",
                    Array = "[]",
                    Boolean = "",
                    Number = "",
                    Null = "󰟢",
                    String = "󰉿",
                    Calendar = "",
                    Watch = "󰥔",
                    Package = "",
                    Copilot = "",
                    Codeium = "",
                    TabNine = "",
                  }
                  local icon = icons[item.kind] or ""
                  item.kind = string.format("%s %s", icon, item.kind or "")
                  return item
                end
              '';
          };

          # DONE Use `plugins.cmp.settings.snippet.expand` option.
          #snippet = {expand = "luasnip";};
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

          window = {
            completion = {
              winhighlight = "FloatBorder:CmpBorder,Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel";
              scrollbar = false;
              side_padding = 0;
              border = [ "╭" "─" "╮" "│" "╯" "─" "╰" "│" ];
            };

            documentation = {
              border = [ "╭" "─" "╮" "│" "╯" "─" "╰" "│" ];
              winhighlight = "FloatBorder:CmpBorder,Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel";
            };
          };

          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })";
            # as in: https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
            "<Tab>" = ''
                            	    cmp.mapping(function(fallback)
              			  if cmp.visible() then
              			    cmp.select_next_item()
              			  elseif require("luasnip").expand_or_jumpable() then
              			    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
              			  else
              			    fallback()
              			  end
              			end, {'i', 's'})
                            		  '';
            "<S-Tab>" = ''
                            	    cmp.mapping(function(fallback)
              			  if cmp.visible() then
              			    cmp.select_prev_item()
              			  elseif require("luasnip").jumpable(-1) then
              			    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
              			  else
              			    fallback()
              			  end
              			end, {'i', 's'})
                            		  '';
          };
        };
      };
    };
    enableMan = false;
  };
in
{

  ###### interface

  options = {
    custom.programs.neovim = {

      enable = mkEnableOption "neovim config";

      lightWeight =
        mkEnableOption "light weight config for low performance hosts" // { default = true; };

      #lightweight = mkEnableOption "light weight config for low performance hosts";
      minimalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of minimal neovim.
        '';
      };

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

  config = mkIf cfg.enable (mkMerge [
    {
      custom.programs.neovim.minimalPackage = inputs.nixvim.legacyPackages."${system}".makeNixvim {
        enableMan = false;
        colorschemes.gruvbox.enable = true;
        extraPlugins = builtins.attrValues {
	  inherit (pkgs.vimPlugins)
          nnn-vim
          neoterm
          grapple-nvim
          nvim-web-devicons
	  ;
	} ++ [
          (pluggo "faster-nvim")
          #		(pluggo "deadcolumn-nvim")
	];
        extraConfigLua = ''
          	vim.g.clipboard = {
                name = 'OSC 52',                                           copy = {                                                     ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
                  ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
                },
                paste = {                                                    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),                                                                 ['*'] = require('vim.ui.clipboard.osc52').paste('*'),                                                               },                                                       }

          require("grapple").setup({
              opts = {
                  scope = "git", -- also try out "git_branch"
              },
              event = { "BufReadPost", "BufNewFile" },
              cmd = "Grapple",
              keys = {
                  { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
                  { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
                  { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
                  { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
              },
          })
          	'';
        extraPackages = builtins.attrValues {
	  inherit (pkgs)
          nixpkgs-fmt
	  ;
	};
  keymaps = [
    {
      mode = "n";
      key = "gd";
      action = "<cmd>Lspsaga finder def<CR>";
      options = {
        desc = "Goto Definition";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>Lspsaga finder ref<CR>";
      options = {
        desc = "Goto References";
        silent = true;
      };
    }

    # {
    #   mode = "n";
    #   key = "gD";
    #   action = "<cmd>Lspsaga show_line_diagnostics<CR>";
    #   options = {
    #     desc = "Goto Declaration";
    #     silent = true;
    #   };
    # }

    {
      mode = "n";
      key = "gI";
      action = "<cmd>Lspsaga finder imp<CR>";
      options = {
        desc = "Goto Implementation";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "gT";
      action = "<cmd>Lspsaga peek_type_definition<CR>";
      options = {
        desc = "Type Definition";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "K";
      action = "<cmd>Lspsaga hover_doc ++keep<CR>";
      options = {
        desc = "Hover doc";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "<leader>cw";
      action = "<cmd>Lspsaga outline<CR>";
      options = {
        desc = "Outline";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>Lspsaga rename<CR>";
      options = {
        desc = "Rename";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>Lspsaga code_action<CR>";
      options = {
        desc = "Code Action";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "<leader>cd";
      action = "<cmd>Lspsaga show_line_diagnostics<CR>";
      options = {
        desc = "Line Diagnostics";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "[d";
      action = "<cmd>Lspsaga diagnostic_jump_next<CR>";
      options = {
        desc = "Next Diagnostic";
        silent = true;
      };
    }

    {
      mode = "n";
      key = "]d";
      action = "<cmd>Lspsaga diagnostic_jump_prev<CR>";
      options = {
        desc = "Previous Diagnostic";
        silent = true;
      };
    }
    ];
        plugins = {
	  lspsaga = {
    enable = true;
    beacon = {
      enable = true;
    };
    ui = {
      border = "rounded"; # One of none, single, double, rounded, solid, shadow
      codeAction = "💡"; # Can be any symbol you want 💡
    };
    hover = {
      openCmd = "!floorp"; # Choose your browser
      openLink = "gx";
    };
    diagnostic = {
      borderFollow = true;
      diagnosticOnlyCurrent = false;
      showCodeAction = true;
    };
    symbolInWinbar = {
      enable = true; # Breadcrumbs
    };
    codeAction = {
      extendGitSigns = false;
      showServerName = true;
      onlyInCursor = true;
      numShortcut = true;
      keys = {
        exec = "<CR>";
        quit = [
          "<Esc>"
          "q"
        ];
      };
    };
    lightbulb = {
      enable = false;
      sign = false;
      virtualText = true;
    };
    implement = {
      enable = false;
    };
    rename = {
      autoSave = false;
      keys = {
        exec = "<CR>";
        quit = [
          "<C-k>"
          "<Esc>"
        ];
        select = "x";
      };
    };
    outline = {
      autoClose = true;
      autoPreview = true;
      closeAfterJump = true;
      layout = "normal"; # normal or float
      winPosition = "right"; # left or right
      keys = {
        jump = "e";
        quit = "q";
        toggleOrJump = "o";
      };
    };
    scrollPreview = {
      scrollDown = "<C-f>";
      scrollUp = "<C-b>";
    };
  };
  
          #   nvim-osc52.enable = true;
          which-key.enable = true;
          luasnip.enable = true;
          lsp = {
            enable = true;
            servers = {
              nixd.enable = true;
              ltex.enable = true;
              texlab.enable = true;
              lua-ls.enable = true;
            };
            keymaps.lspBuf = {
              "gd" = "definition";
              "gD" = "references";
              "gt" = "type_definition";
              "gi" = "implementation";
              "K" = "hover";
            };
          };
          #      conform-nvim = { enable = true;
          #        formattersByFt = {
          #	  nix = [ "nixpkgs-fmt" ];
          #	};
          #      };
          cmp-buffer = { enable = true; };
          cmp-emoji = { enable = true; };
          cmp-nvim-lsp = { enable = true; };
          cmp-path = { enable = true; };
          cmp_luasnip = { enable = true; };
          cmp = {
            enable = true;
            settings = {
              sources = [
                { name = "nvim_lsp"; }
                { name = "luasnip"; }
                { name = "buffer"; }
                { name = "nvim_lua"; }
                { name = "path"; }
              ];
              formatting = {
                fields = [ "abbr" "kind" "menu" ];
                format =
                  # lua
                  ''
                    function(_, item)
                      local icons = {
                        Namespace = "󰌗",
                        Text = "󰉿",
                        Method = "󰆧",
                        Function = "󰆧",
                        Constructor = "",
                        Field = "󰜢",
                        Variable = "󰀫",
                        Class = "󰠱",
                        Interface = "",
                        Module = "",
                        Property = "󰜢",
                        Unit = "󰑭",
                        Value = "󰎠",
                        Enum = "",
                        Keyword = "󰌋",
                        Snippet = "",
                        Color = "󰏘",
                        File = "󰈚",
                        Reference = "󰈇",
                        Folder = "󰉋",
                        EnumMember = "",
                        Constant = "󰏿",
                        Struct = "󰙅",
                        Event = "",
                        Operator = "󰆕",
                        TypeParameter = "󰊄",
                        Table = "",
                        Object = "󰅩",
                        Tag = "",
                        Array = "[]",
                        Boolean = "",
                        Number = "",
                        Null = "󰟢",
                        String = "󰉿",
                        Calendar = "",
                        Watch = "󰥔",
                        Package = "",
                        Copilot = "",
                        Codeium = "",
                        TabNine = "",
                      }
                      local icon = icons[item.kind] or ""
                      item.kind = string.format("%s %s", icon, item.kind or "")
                      return item
                    end
                  '';
              };
              snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
              window = {
                completion = {
                  winhighlight = "FloatBorder:CmpBorder,Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel";
                  scrollbar = false;
                  side_padding = 0;
                  border = [ "╭" "─" "╮" "│" "╯" "─" "╰" "│" ];
                };
                documentation = {
                  border = [ "╭" "─" "╮" "│" "╯" "─" "╰" "│" ];
                  winhighlight = "FloatBorder:CmpBorder,Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel";
                };
              };
              mapping = {
                "<C-n>" = "cmp.mapping.select_next_item()";
                "<C-p>" = "cmp.mapping.select_prev_item()";
                "<C-j>" = "cmp.mapping.select_next_item()";
                "<C-k>" = "cmp.mapping.select_prev_item()";
                "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                "<C-f>" = "cmp.mapping.scroll_docs(4)";
                "<C-Space>" = "cmp.mapping.complete()";
                "<C-e>" = "cmp.mapping.close()";
                "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })";
                # as in: https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
                "<Tab>" = ''
                                	    cmp.mapping(function(fallback)
                  			  if cmp.visible() then
                  			    cmp.select_next_item()
                  			  elseif require("luasnip").expand_or_jumpable() then
                  			    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
                  			  else
                  			    fallback()
                  			  end
                  			end, {'i', 's'})
                                		  '';
                "<S-Tab>" = ''
                                	    cmp.mapping(function(fallback)
                  			  if cmp.visible() then
                  			    cmp.select_prev_item()
                  			  elseif require("luasnip").jumpable(-1) then
                  			    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
                  			  else
                  			    fallback()
                  			  end
                  			end, {'i', 's'})
                                		  '';
              };
            };
          };
        };
      };

      home.packages = let inherit (config.custom.programs.neovim) minimalPackage; in [
        (pkgs.runCommand "minimal-nvim" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          mkdir -p $out/bin
          makeWrapper ${minimalPackage.outPath}/bin/nvim $out/bin/vi --argv0 nvim
        '')
      ];

      home.sessionVariables.EDITOR = "vi";
    }

    (mkIf (!cfg.lightWeight) {
      # inputs.nixvim.legacyPackages."${system}".makeNixvim configuration;
      custom.programs.neovim.finalPackage = inputs.nixvim.legacyPackages."${system}".makeNixvim configuration;

      home.packages = let inherit (config.custom.programs.neovim) finalPackage; in [
        finalPackage
      ];

      # see https://discourse.nixos.org/t/conflicts-between-treesitter-withallgrammars-and-builtin-neovim-parsers-lua-c/33536/3
      # FIXME https://github.com/nix-community/nixvim/blob/4f6e90212c7ec56d7c03611fb86befa313e7f61f/plugins/languages/treesitter/treesitter.nix#L12
      /*      xdg.configFile."nvim/parser".source = "${pkgs.symlinkJoin {
                            	      name = "treesitter-parsers";
                            	      paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
                            			    nix
                            			    bash
                            			    yaml
                            			    json
                            			    lua
                            			    latex
                            			    comment
                            	      ])).dependencies;
                      	    }}/parser"; */
    })
  ]);
}
