{ config, lib, pkgs, rootPath, inputs, unstable, makeNixvim, ... }:

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

  pluggo = pname: unstable.vimUtils.buildVimPlugin { inherit pname; src = inputs."${pname}"; version = "0.1"; };

  configuration = {
    colorschemes.catppuccin.enable = true;
    enableMan = false;
  };
in
{

  ###### interface

  options = {
    custom.programs.neovim = {

      enable = mkEnableOption "neovim config";

      lightWeight =
        mkEnableOption "light weight neovim (vi) config for low performance hosts" // { default = true; };

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
      # FIXME add nvim-lsp as in https://github.com/nix-community/nixd/blob/main/nixd/docs/editors/nvim-lsp.nix
      custom.programs.neovim.minimalPackage = makeNixvim {
        enableMan = false;
        colorschemes.gruvbox.enable = true;
        extraPlugins = builtins.attrValues {
	  inherit (pkgs.vimPlugins)
          nnn-vim
          neoterm
					#grapple-nvim
          nvim-web-devicons
					#vim-abolish
	  ;
	} ++ [
          (pluggo "faster-nvim")
          (pluggo "action-hints.nvim")
	];
	#(pkgs.vimPlugins.nvim-treesitter.withPlugins (parsers: with parsers;[ nix markdown markdown_inline ]))
        extraConfigLua = ''
	  -- <C-x> <C-k> triggers dictionary completion, https://www.reddit.com/r/neovim/comments/16o22w0/how_to_use_nvimcmp_to_autocomplete_for_plain/
-- only for cmp-dictionary not for cmp-look	  
vim.api.nvim_set_option_value('dictionary', "${pkgs.scowl}/share/dict/words.txt", { buf = buf })
          	vim.g.clipboard = {
                name = 'OSC 52',                                           copy = {                                                     ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
                  ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
                },
                paste = {                                                    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),                                                                 ['*'] = require('vim.ui.clipboard.osc52').paste('*'),                                                               },                                                       }

          --require("grapple").setup({
          --    opts = {
          --        scope = "git", -- also try out "git_branch"
          --    },
          --    event = { "BufReadPost", "BufNewFile" },
          --    cmd = "Grapple",
          --    keys = {
          --        { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
          --        { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
          --        { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
          --        { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
          --    },
          --})
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
      treesitter = {
        enable = true;
        nixGrammars = true;
        indent = true;
        ensureInstalled = [
          "nix"
          "bash"
          "yaml"
          "json"
          "lua"
          "latex"
							"ruby"
          "comment"
	  "markdown"
	  "markdown_inline"
        ];
      };
	  fzf-lua = {
	    enable = true;
profile = "telescope";
      keymaps = {
        "<Leader>ff" = {
          action = "files";
          settings = {
            cwd = "~/.nix-config";
            winopts = {
              height = 0.1;
              width = 0.5;
            };
          };
          options.silent = true;
        };
        "<Leader>fg" = "live_grep";
        "<C-x><C-f>" = {
          mode = "i";
          action = "complete_file";
          settings = {
            cmd = "rg --files";
            winopts.preview.hidden = "nohidden";
          };
          options = {
            silent = true;
            desc = "Fuzzy complete file";
          };
        };
      };
      settings = {
        grep = {
          prompt = "Grep  ";
        };
        winopts = {
          height = 0.4;
          width = 0.93;
          row = 0.99;
          col = 0.3;
        };
        files = {
          find_opts.__raw = "[[-type f -not -path '*.git/objects*' -not -path '*.env*']]";
          prompt = "Files❯ ";
          multiprocess = true;
          file_icons = true;
          color_icons = true;
        };
      };
	    };
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
              nixd = {
	        enable = true;
		settings = {
		  formatting.command = [ "nixpkgs-fmt" ];
		  nixpkgs.expr = ''
		  import <nixpkgs> { }
		  '';
                
		  options = {
                    nixos.expr = ''
		    (builtins.getFlake "/data/data/com.termux.nix/files/home/.nix-config").nixosConfigurations.DANIELKNB1.options
		    '';
                    home_manager.expr = ''
		    (builtins.getFlake "/data/data/com.termux.nix/files/home/.nix-config").homeConfigurations."dani@maiziedemacchiato".options
		    '';
		    nixondroid.expr = ''
(builtins.getFlake "/data/data/com.termux.nix/files/home/.nix-config").nixOnDroidConfigurations.sams9.options
'';

                  };
		};
	      };
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
          cmp-buffer = { enable = true; };
          cmp-emoji = { enable = true; };
          cmp-nvim-lsp = { enable = true; };
          cmp-path = { enable = true; };
          cmp_luasnip = { enable = true; };
	  cmp-look = { enable = true; };
	  # FIXME still getting pattern not found
					#cmp-dictionary = { enable = true; };
          cmp = {
            enable = true;
            settings = {
              sources = [
                { name = "nvim_lsp"; }
                { name = "luasnip"; }
                { name = "buffer"; }
                { name = "nvim_lua"; }
                { name = "path"; }
		{
		  name = "look";
		  keyword_length = 2;
		  option.__raw = ''
		  {
                    convert_case = true,
                    loud = true,
		    dict = '${pkgs.scowl}/share/dict/words.txt'
		  }
                  '';
		}
              ];
		/*
		{
		  name = "dictionary";
		  # FIXME exactly as here https://github.com/uga-rosa/cmp-dictionary/blob/edbd263/doc/cmp-dictionary.txt#L29 and could even use aspell https://github.com/uga-rosa/cmp-dictionary/blob/edbd263/doc/cmp-dictionary.txt#L190
		  paths.__raw = "{ \"${pkgs.scowl}/share/dict/words.txt\" }";
		  exact_length.__raw = "2";
		}
		{
		  name = "look";
		  keyword_length = 2;
		  option.__raw = ''
		  {
                    convert_case = true,
                    loud = true,
		    dict = '${pkgs.scowl}/share/dict/words.txt'
		  }
                  '';
		}
		*/

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
      custom.programs.neovim.finalPackage = makeNixvim configuration;

      home.packages = let inherit (config.custom.programs.neovim) finalPackage; in [
        finalPackage
      ];
    })
  ]);
}
