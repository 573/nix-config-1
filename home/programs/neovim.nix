{ config
, lib
, pkgs
, inputs
, unstable
, makeNixvimWithModule
, homeDir
, ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.custom.programs.neovim;

  # i. e. nix-repl> :p (homeConfigurations."dani@maiziedemacchiato".pkgs.vimUtils.buildVimPluginFrom2Nix { pname = "markid"; src = inputs.markid; version = inputs.markid.rev; }).drvAttrs
  #	  pluggo = name: pkgs.vimUtils.buildVimPlugin {
  #	    pname = name;
  #	    src = inputs."${name}";
  #	    version = "2023-20-10";
  #	  };

  pluggo =
    pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname;
      src = inputs."${pname}";
      version = "0.1";
    };

  # keymaps
  
  keymaps = [
    {
      mode = "n";
      key = "<leader>-";
      action = "<cmd>Yazi<cr>";
      options.desc = "yazi at current file";
    }

    {
      mode = "n";
      key = "<leader>cw";
      action = "<cmd>Yazi cwd<cr>";
      options.desc = "yazi in nvim's working dir";
    }

    {
      # Quick exit insert mode using `jj`
      mode = "i";
      key = "jj";
      action = "<Esc>";
      options.silent = true;
    }

    # Show which-key
    {
      mode = [ "n" "v" ];
      key = "<C-Space>";
      action = "<cmd>WhichKey<CR>";
      options.desc = "Which Key";
    }

    # Buffers
    {
      mode = "n";
      key = "<leader>bn";
      action = "<cmd>bn<CR>";
      options.desc = "Go to next buffer";
    }
    {
      mode = "n";
      key = "<leader>bp";
      action = "<cmd>bp<CR>";
      options.desc = "Go to previous buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>Bdelete<CR>";
      options.desc = "Delete the current buffer";
    }

    # Errors/diagnostics
    {
      mode = "n";
      key = "ge";
      action.__raw = "vim.diagnostic.goto_next";
      options.desc = "Goto next diagnostic";
    }
    {
      mode = "n";
      key = "gE";
      action.__raw = "vim.diagnostic.goto_prev";
      options.desc = "Goto previous diagnostic";
    }

    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = "telescope_project_files()";
      options.desc = "Find files";
    }

    {
      mode = "n";
      key = "z=";
      action.__raw = ''
        function()
          require('telescope.builtin').spell_suggest(
            require('telescope.themes').get_cursor({ })
          )
        end
      '';
      options.desc = "Spelling suggestions";
    }
  ];

  # plugins
  trouble.enable = true;

  gitsigns = {
    enable = true;
    settings.current_line_blame = false;
  };

  # https://github.com/MattSturgeon/nix-config/blob/main/nvim/config/completion.nix
  cmp = {
    enable = true;
        # Setting this means we don't need to explicitly enable
    # each completion source, so long as the plugin is listed
    # in https://github.com/nix-community/nixvim/blob/cd32dcd50fa98cd03e2916b6fd47e31deffbca24/plugins/completion/cmp/cmp-helpers.nix#L23
    autoEnableSources = true;
    settings = {
      sources = [
        { name = "nvim_lsp";
	  groupIndex = 2; }
        { name = "buffer";
	  groupIndex = 2; }
        { name = "path";
	  option.trailing_slash = true;
	  groupIndex = 2; }
        { name = "luasnip";
	  groupIndex = 3; }
        {
          name = "look";
	  groupIndex = 1;
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
        fields = [
          "abbr"
          "kind"
          "menu"
        ];
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
      # FIXME Generates error, compare https://github.com/MattSturgeon/nix-config/blob/main/nvim/config/completion.nix and https://github.com/nix-community/nixd/blob/main/nixd/docs/editors/nvim-lsp.nix
      #snippet.expand = ''
  #function(args)
  #  require('luasnip').lsp_expand(args.body)
  #end
#'';
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

      filetype = {
      gitcommit = {
        sources = [
          { name = "conventionalcommits"; }
          { name = "git"; }
          { name = "emoji"; }
          { name = "path"; }
        ];
      };
    };

    cmdline =
      let
        common = {
          mapping.__raw = /* lua */ ''
            cmp.mapping.preset.cmdline({
              ["<C-Space>"] = cmp.mapping.complete(), -- Open list without typing
            })
          '';
          sources = [{ name = "buffer"; }];
        };
      in
      {
        "/" = common;
        "?" = common;
        ":" = {
          inherit (common) mapping;
          sources = [
            {
              name = "path";
              option.trailing_slash = true;
            }
            { name = "cmdline"; }
          ];
        };
      };
  };

  cmp-buffer = {
    enable = true;
  };

  #cmp-emoji = {
  #  enable = true;
  #};

  cmp-nvim-lsp = {
    enable = true;
  };

  cmp-path = {
    enable = true;
  };

  cmp_luasnip = {
    enable = true;
  };

  cmp-look = {
    enable = true;
  };

  # FIXME still getting pattern not found
  #cmp-dictionary = { enable = true; };

  yazi = {
      enable = false;

      settings = {
        log_level = "off";
        open_for_directories = false;
        use_ya_for_events_reading = false;
        use_yazi_client_id_flag = false;
        enable_mouse_support = false;

        open_file_function.__raw = ''
          function(chosen_file)
            vim.cmd(string.format("edit %s", vim.fn.fnameescape(chosen_file)))
          end
        '';

        clipboard_register = "*";

        keymaps = {
          show_help = "<f1>";
          open_file_in_vertical_split = "<c-v>";
          open_file_in_horizontal_split = "<c-x>";
          open_file_in_tab = "<c-t>";
          grep_in_directory = "<c-s>";
          replace_in_directory = "<c-g>";
          cycle_open_buffers = "<tab>";
          copy_relative_path_to_selected_files = "<c-y>";
          send_to_quickfix_list = "<c-q>";
        };

        set_keymappings_function = null;

        hooks = {
          yazi_opened.__raw = ''
            function(preselected_path, yazi_buffer_id, config)
            end
          '';

          yazi_closed_successfully.__raw = ''
            function(chosen_file, config, state)
            end
          '';

          yazi_opened_multiple_files.__raw = ''
            function(chosen_files)
              vim.cmd("args" .. table.concat(chosen_files, " "))
            end
          '';
        };

        highlight_groups = {
          hovered_buffer = null;
        };

        floating_window_scaling_factor = 0.9;
        yazi_floating_window_winblend = 0;
        yazi_floating_window_border = "rounded";
      };
    };

  mini = {
    enable = true;
    modules.icons = { };
    mockDevIcons = true;
  };

  comment.enable = true;

  which-key = {
    enable = true;
    settings = {
      spec = [
        {
          __unkeyed-1 = "<leader>w";
          proxy = "<C-w>";
          group = "windows";
        }
        {
          __unkeyed-1 = "<c-w>c";
          desc = "Close current window";
        }
        {
          __unkeyed-1 = "<c-w>H";
          desc = "Move current window to the far left";
        }
        {
          __unkeyed-1 = "<c-w>J";
          desc = "Move current window to the very bottom";
        }
        {
          __unkeyed-1 = "<c-w>K";
          desc = "Move current window to the very top";
        }
        {
          __unkeyed-1 = "<c-w>L";
          desc = "Move current window to the far right";
        }

        {
          __unkeyed-1 = "<leader>b";
          group = "buffers";
        }

        {
          __unkeyed-1 = "<leader>r";
          group = "refactoring";
        }

        {
          __unkeyed-1 = "<leader>f";
          group = "files";
        }
      ];
      # Using telescope for spelling
      plugins.spelling.enabled = false;
    };
  };

  lsp = {
    enable = true;
    servers = {
      #ltex.enable = true;
      #texlab.enable = true;
      #lua_ls.enable = true;
      yamlls = {
        enable = true;
        autostart = true;
      };

      nixd = {
        # Nix LS
        enable = true; # FIXME re-enable when crashes on termux are fixed
        settings =
        let
            flake = ''(builtins.getFlake "${inputs.self}")'';
        in
        {
          nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
	  # See https://nix-community.github.io/nixvim/plugins/lsp/servers/nixd/settings/formatting.html
	  formatting.command = [ "nixfmt" ];
	  # See https://nix-community.github.io/nixvim/plugins/lsp/servers/nixd/settings/diagnostic.html
          diagnostic.suppress = [
              "sema-escaping-with"
              "var-bind-to-this"
            ];
	  # See https://nix-community.github.io/nixvim/plugins/lsp/servers/nixd/settings/index.html#pluginslspserversnixdsettingsoptions
          options = rec {
            nixos.expr = "${flake}.nixosConfigurations.DANIELKNB1.options";
	    # as in https://github.com/nix-community/NixOS-WSL/blob/d34d9412556d3a896e294534ccd25f53b6822e80/modules/wsl-conf.nix#L21
	    nixos-wsl.expr = "${nixos.expr}.wsl.wslConf.type.getSubOptions [ ]";
	    # as in https://github.com/nix-community/home-manager/blob/e8c19a3cec2814c754f031ab3ae7316b64da085b/nixos/common.nix#L112
            home-manager.expr = config.custom.programs.neovim.nixd.expr.home-manager;
	    # TODO split up by making *.expr configurable by host in that neovim.nix module here
            #home_manager.expr = ''
            #  ${flake}.homeConfigurations."dani@maiziedemacchiato".options
            #'';
	    /* TODO https://github.com/nix-community/nixvim/blob/1fb1bf8a73ccf207dbe967cdb7f2f4e0122c8bd5/flake/default.nix#L10, is another approach i. e. with that config https://github.com/khaneliman/khanelivim/blob/a33e6ab/flake.nix
	    nix-repl> :lf github:khaneliman/khanelivim
	    nix-repl> nixvimConfigurations.x86_64-linux.khanelivim.options 
	    same as
	    nix-repl> nixvimConfigurations.x86_64-linux.khanelivim.options
	    */
            nixondroid.expr = ''
              ${flake}.nixOnDroidConfigurations.sams9.options
            '';
          };
        };
      };
    };

    keymaps.lspBuf = {
      # See :h lsp-buf
      K = {
        action = "hover";
        desc = "Show documentation";
      };
      gd = {
        action = "definition";
        desc = "Goto definition";
      };
      gD = {
        action = "declaration";
        desc = "Goto declaration";
      };
      gi = {
        action = "implementation";
        desc = "Goto implementation";
      };
      gt = {
        # FIXME conflicts with "next tab page" :h gt
        action = "type_definition";
        desc = "Goto type definition";
      };
      ga = {
        action = "code_action";
        desc = "Show code actions";
      };
      "g*" = {
        action = "document_symbol";
        desc = "Show document symbols";
      };
      "<leader>rn" = {
        action = "rename";
        desc = "Rename symbol";
      };
    };
  };

  luasnip.enable = true;

  telescope = {
    enable = true;
    # Keymaps defined in ./keymaps.nix

    extensions = {
      fzf-native.enable = true;
      media-files.enable = true;
    };

    keymaps = {
      "<leader>bb" = {
        action = "buffers ignore_current_buffer=true sort_mru=true";
        options.desc = "List buffers";
      };
      "<leader>h" = {
        action = "help_tags";
        options.desc = "Browse help";
      };
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Grep files";
      };
      "<leader>`" = {
        action = "marks";
        options.desc = "Browse marks";
      };
      "<leader>\"" = {
        action = "registers";
        options.desc = "Browse registers";
      };
      "<leader>gs" = {
        action = "git_status";
        options.desc = "Git status";
      };
      "gr" = {
        action = "lsp_references";
        options.desc = "Browse references";
      };
      "gA" = {
        action = "diagnostics";
        options.desc = "Browse diagnostics";
      };
      "gs" = {
        action = "treesitter";
        options.desc = "Browse symbols";
      };
    };
  };

  extraConfigLuaPre = /* lua */ ''
    -- Helper for telescope (<leader>ff)
    function telescope_project_files()
      -- We cache the results of "git rev-parse"
      -- Process creation is expensive in Windows, so this reduces latency
      local is_inside_work_tree = {}

      local opts = {}

      return function()
        local cwd = vim.fn.getcwd()
        if is_inside_work_tree[cwd] == nil then
          vim.fn.system("git rev-parse --is-inside-work-tree")
          is_inside_work_tree[cwd] = vim.v.shell_error == 0
        end

        if is_inside_work_tree[cwd] then
          require("telescope.builtin").git_files(opts)
        else
          require("telescope.builtin").find_files(opts)
        end
      end
    end
  '';

  # TODO https://xnacly.me/posts/2023/configure-fzf-nvim/ :FZF there is :FzfLua here
  fzf-lua = {
    enable = true;
    profile = "telescope";
    keymaps = {
      "<Leader>ff" = {
        action = "files";
        settings = {
          cwd = "~";
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
in
{

  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  ###### interface

  options = {
    custom.programs.neovim = {

      enable = mkEnableOption "neovim config";

      nixd = {
        expr = {
	  home-manager = mkOption {
	    type = types.str;
	    default = ''(builtins.getFlake "${inputs.self}").nixosConfigurations.DANIELKNB1.options.home-manager.users.type.getSubOptions [ ]'';
	    description = let flake = ''(builtins.getFlake "${inputs.self}")''; in ''
	    Either like ${flake}.homeConfigurations.nonnixos.options or like ${flake}.nixosConfigurations.nixosmachine.options.home-manager.users.type.getSubOptions [ ]
	    '';
	    };
	};
      };

      lightWeight = mkEnableOption "light weight neovim (vi) config for low performance hosts" // {
        default = true;
      };

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

  # FIXME add nvim-lsp as in https://github.com/nix-community/nixd/blob/main/nixd/docs/editors/nvim-lsp.nix
  config = mkIf cfg.enable (mkMerge [
    {
      # minimal nvim
      custom.programs.neovim.minimalPackage =       makeNixvimWithModule {
        #inherit pkgs;
        module = { helpers, ... }: # import ./config; # import the module directly
          {
            enableMan = false;

            colorschemes.catppuccin.enable = true;

            inherit extraConfigLuaPre;

            # TODO my old setup https://github.com/573/nix-config-1/blob/dc2da3bc963aeba2c6616a993e6973041120fd3d/home/programs/neovim.nix
            extraConfigLua = ''
	            -- alacritty (+ tmux + neovim) workaround
                    -- DONT vim.opt.paste = true -- as it breaks many other things i.e. fzf
		    -- DONT [also] rather see https://jdhao.github.io/2021/02/01/bracketed_paste_mode/
		    --      is nice but does not work even with only alacritty and no tmux inbetween  
                    -- DONE like follows (hitting F2 to toggle paste on demand before C-S-v)
		    -- see * https://stackoverflow.com/a/78629377
		    --     * https://www.reddit.com/r/neovim/comments/uuh8xw/noob_vimkeymapset_vs_vimapinvim_set_keymap_key/
                    --     * https://www.reddit.com/r/neovim/comments/xilic1/comment/ip3saw1/
                    --     * or just using <BAR> as see https://www.reddit.com/r/neovim/comments/yd6ne9/comment/itq9ocx/
		    vim.api.nvim_set_keymap('n', '<f2>', ':set paste!<cr>i', { noremap = true, silent = true })
		    -- TODO vim.notify("paste toggled")
		    --      potentially add message about toggle state https://www.reddit.com/r/neovim/comments/vbf609/comment/id5tbuz/
		    --      :set paste?<cr> https://stackoverflow.com/a/12060528
                    -- not working see https://superuser.com/questions/468640/f2-in-paste-mode
		    --             also https://vimhelp.org/options.txt.html#%27paste%27
		    --vim.keymap.set('i', "<f2>", '<c-\><c-o>:set paste!<cr>', { noremap = true })

              	    require('faster').setup()

              	    -- <C-x> <C-k> triggers dictionary completion, https://www.reddit.com/r/neovim/comments/16o22w0/how_to_use_nvimcmp_to_autocomplete_for_plain/
              	    -- only for cmp-dictionary not for cmp-look	  
              	    vim.api.nvim_set_option_value('dictionary', "${pkgs.scowl}/share/dict/words.txt", { buf = buf })

              	    vim.g.clipboard = {
              	      name = 'OSC 52',
              	      copy = {                                                     
              	        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
                        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
              	      },
                      paste = {
              	        ['+'] = require('vim.ui.clipboard.osc52').paste('+'), 
              		['*'] = require('vim.ui.clipboard.osc52').paste('*'),                                                  
              	      },                                                       
              	    }
              	    '';



            extraPlugins =
              builtins.attrValues {
                inherit (pkgs.vimPlugins)
                  neoterm
                  #nnn-vim
                  faster-nvim
                  ;
              }
            ;

            inherit keymaps;

            nixpkgs.pkgs = pkgs;

            # Override neovim-unwrapped with one from a flake input
            # Using `stdenv.hostPlatform` to access `system`
            nixpkgs.overlays = [
              (
                final: prev: {
                  #neovim-unwrapped =
                  #  inputs.neovim-nightly-overlay.packages.${final.stdenv.hostPlatform.system}.default;

                  vimPlugins =
                    prev.vimPlugins
                    // {
                      faster-nvim = final.vimUtils.buildVimPlugin {
                        name = "faster-nvim";
                        src = inputs.faster-nvim;
                      };
                    };
                }
              )
            ];

            plugins = {
              inherit
	        fzf-lua
                mini
                which-key
                comment
                lsp
                cmp
                cmp-buffer# m
                trouble
		cmp_luasnip
                cmp-path# m
                cmp-look# m
		luasnip
		gitsigns
		telescope
		#yazi
                ;
            };
          };
        # You can use `extraSpecialArgs` to pass additional arguments to your module files
        extraSpecialArgs = {
          # inherit (inputs) foo;
        };

      };

      home.packages =
        let
          inherit (config.custom.programs.neovim) minimalPackage;
        in
        [
          (pkgs.runCommand "minimal-nvim" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
            mkdir -p $out/bin
            makeWrapper ${minimalPackage.outPath}/bin/nvim $out/bin/vi --argv0 nvim
          '')
        ];

      home.sessionVariables = { EDITOR = lib.mkDefault "vi"; };


      custom.programs.shell.shellAliases = {
        f2clip = ''vi '+execute "normal ggVG\"+y"' +wq'';
      };
    }

    /*(mkIf (!cfg.lightWeight) {
      # full nvim
      custom.programs.neovim.finalPackage = config.programs.nixvim.build.package;

      programs.nixvim = lib.mkForce {
        enable = true;

        enableMan = false;

        colorschemes.gruvbox.enable = true;

        extraPlugins =
          builtins.attrValues
            {
              inherit (pkgs.vimPlugins)
                #nnn-vim
                neoterm
                ;
            }
          ++ [
            (pluggo "faster-nvim")
          ];

        inherit keymaps;

        nixpkgs.pkgs = pkgs;

        # Override neovim-unwrapped with one from a flake input
        # Using `stdenv.hostPlatform` to access `system`
        nixpkgs.overlays = [
          (
            final: prev: {
              #neovim-unwrapped =
              #  inputs.neovim-nightly-overlay.packages.${final.stdenv.hostPlatform.system}.default;
            }
          )
        ];

        plugins = {
          inherit
            fzf-lua
            mini
            which-key
            comment
            lsp
            cmp
            cmp-buffer# m
            #cmp-emoji
            cmp-nvim-lsp
            cmp-path# m
            cmp_luasnip
            cmp-look# m
	    #yazi
            ;
        };
      };
    })*/
  ]);
}
