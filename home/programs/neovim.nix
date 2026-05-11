{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.neovim;

  # keymaps
  #keymaps = [];

  # plugins
  trouble.enable = true;

  cmp = {
    enable = true;

    autoEnableSources = true;
    settings = {
      # see https://stackoverflow.com/a/74714258 and https://stackoverflow.com/a/74730907
      completion = {
        completeopt = "menu,menuone,noinsert,noselect";
        keyword_length = 3;
      };
      sources = [
        # alternative would only be not enable cmp and using C-x C-o - probably not how it is supposed to work,
        # see https://gpanders.com/blog/whats-new-in-neovim-0-11/#builtin-auto-completion
        # and here under lsp = ...
        { name = "nvim_lsp"; }
        { name = "nvim_lsp_document_symbol"; }
        { name = "path"; }
        { name = "buffer"; }
        { name = "omni"; }
        { name = "rg"; }
        { name = "cmdline"; }
        { name = "cmdline-history"; }
        { name = "nvim-lsp-signature-help"; }
        { name = "treesitter"; }
      ];
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-e>" = "cmp.mapping.close()";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        # see https://stackoverflow.com/a/74714258
        "<CR>" = "cmp.mapping.confirm({ select = false })";
        "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      };
    };

  };

  cmp-cmdline.enable = true;
  cmp-cmdline-history.enable = true;
  cmp-nvim-lsp-signature-help.enable = true;
  cmp-treesitter.enable = true;
  cmp-omni.enable = true;
  cmp-nvim-lsp.enable = true;
  cmp-nvim-lsp-document-symbol.enable = true;
  cmp-buffer.enable = true;
  cmp-path.enable = true;
  cmp-rg.enable = true;

  lsp-format = {
    enable = true;
  };

  which-key = {
    enable = true;
    settings = {
      delay = 200;
      expand = 1;
      notify = false;
      preset = false;
      replace = {
        desc = [
          [
            "<space>"
            "SPACE"
          ]
          [
            "<leader>"
            "SPACE"
          ]
          [
            "<[cC][rR]>"
            "RETURN"
          ]
          [
            "<[tT][aA][bB]>"
            "TAB"
          ]
          [
            "<[bB][sS]>"
            "BACKSPACE"
          ]
        ];
      };
      spec = [
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffers";
          icon = "󰓩 ";
        }
        {
          __unkeyed-1 = "<leader>bs";
          group = "Sort";
          icon = "󰒺 ";
        }
        {
          __unkeyed-1 = [
            {
              __unkeyed-1 = "<leader>f";
              group = "Normal Visual Group";
            }
            {
              __unkeyed-1 = "<leader>f<tab>";
              group = "Normal Visual Group in Group";
            }
          ];
          mode = [
            "n"
            "v"
          ];
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "windows";
          proxy = "<C-w>";
        }
      ];
      win = {
        border = "single";
      };
    };

  };

  no-neck-pain.enable = true;

  nvim-bqf = {
    enable = true;
    settings = {
      preview = {
        border = "double";
        show_scroll_bar = false;
        show_title = false;
        winblend = 0;
      };
    };
  };

  nvim-lightbulb.enable = true;

  nvim-autopairs.enable = true;

  faster = {
    enable = true;

    settings = {
      behaviours = {
        bigfile = {
          extra_patterns = [
            {
              filesize = 1.1;
              pattern = "*.md";
            }
            {
              pattern = "*.log";
            }
          ];
          features_disabled = [
            "lsp"
            "treesitter"
          ];
          filesize = 2;
          on = true;
          pattern = "*";
        };
        fastmacro = {
          features_disabled = [
            "lualine"
          ];
          on = true;
        };
      };
      features = {
        lsp = {
          defer = false;
          on = true;
        };
        treesitter = {
          defer = false;
          on = true;
        };
      };
    };
  };

  lspconfig.enable = true;

  lsp = {
    enable = true;

    keymaps.diagnostic = {
      "<leader>j" = "goto_next";
      "<leader>k" = "goto_prev";
    };

    keymaps.lspBuf = {
      K = "hover";
      gD = "references";
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
    };

    # see https://lazy.folke.io/spec/lazy_loading#%EF%B8%8F-lazy-key-mappings
    lazyLoad.settings.ft = [
      "nix"
      "java"
    ];

    # see https://github.com/nix-community/nixvim/blob/b8f76bf5751835647538ef8784e4e6ee8deb8f95/modules/lsp/default.nix#L7
    # via https://nix-community.github.io/nixvim/25.11/lsp/luaConfig.html#lspluaconfigpre
    # got here https://github.com/nix-community/nixvim/discussions/3427#discussioncomment-13356384
    luaConfig.pre =
      let
        java-debug = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server";
        java-test = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server";
      in
      ''
               -- see https://vi.stackexchange.com/q/42707
               -- if client.name == "jdtls" then
        --	end
      '';

    # This would be useful only for very minimal completion, i.e., only builtin lsp completion
    # Also, in combination with cmp-nvim-lsp / cmp at least, C-x C-o does not really trigger: Only
    # using just and only vim.lsp.completion.* without cmp.
    # search machine: vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true }) and cmp
    # search machine: vim.lsp.completion.enable vs nvim-cmp is it compatible
    # search machine: c-x c-o not working when cmp plugin active
    # https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion/217feffc675a17d8ab95259ed9d4c6d62e1cd2e1#autocompletion-not-built-in-vs-completion-built-in
    # https://github.com/hrsh7th/cmp-nvim-lsp/blob/5af77f54de1b16c34b23cba810150689a3a90312/README.md?plain=1#L9
    # https://martinopilia.com/posts/2024/10/27/vim-config-update.html
    # https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
    # tl;dr while it is possible to use vim.lsp.completion next to cmp see , it might create issues
    # due to incompatibilities
    /*
      onAttach = ''
        -- https://github.com/neovim/neovim/issues/33142#issue-2957264231
        -- remove this next line soon - only for debugging purposes inserted
        -- client.server_capabilities.completionProvider.triggerCharacters = vim.split("qwertyuiopasdfghjklzxcvbnm. ", "")

        -- see https://gpanders.com/blog/whats-new-in-neovim-0-11/#builtin-auto-completion
        if client:supports_method('textDocument/completion') then
          vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
        end
      '';
    */

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
              /*
                TODO https://github.com/nix-community/nixvim/blob/1fb1bf8a73ccf207dbe967cdb7f2f4e0122c8bd5/flake/default.nix#L10, is another approach i. e. with that config https://github.com/khaneliman/khanelivim/blob/a33e6ab/flake.nix
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
  };

  telescope = {
    enable = true;

    # https://nix-community.github.io/nixvim/25.11/plugins/telescope/index.html#pluginstelescopeenabledextensions
    extensions = {
      advanced-git-search = {
        enable = true;
        settings = {
          diff_plugin = "diffview";
          git_flags = [
            "-c"
            "delta.side-by-side=false"
          ];
        };
      };
      fzf-native.enable = true;
      live-grep-args = {
        enable = true;
        settings = {
          auto_quoting = true;
          mappings = {
            # These are meant to be used when the telescope dialog is open, i.e., not in the "regular" neovim buffer
            # For more keys in the preview, result etc, see https://github.com/nvim-telescope/telescope.nvim/blob/e6cdb4d/README.md#default-mappings
            i = {
              "<C-i>" = {
                __raw = "require(\"telescope-live-grep-args.actions\").quote_prompt({ postfix = \" --iglob \" })";
              };
              "<C-k>" = {
                __raw = "require(\"telescope-live-grep-args.actions\").quote_prompt()";
              };
              "<C-space>" = {
                __raw = "require(\"telescope.actions\").to_fuzzy_refine";
              };
            };
          };
          theme = "dropdown";
        };
      };
      project.enable = true;
    };

    # Found out via :Telescope keymaps or simply :Telescope <TAB>
    keymaps = {
      "<C-p>" = {
        action = "git_files";
        options = {
          desc = "Telescope Git Files";
        };
      };
      "<leader>bb" = {
        action = "buffers";
        options = {
          desc = "Telescope Buffers";
        };
      };
      "<leader>gs" = {
        action = "grep_string";
        options = {
          desc = "Telescope grep for the word under the cursor";
        };
      };
      "<leader>fg" = "live_grep";
    };

    settings = {
      defaults = {
        file_ignore_patterns = [
          "^.git/"
          "^.mypy_cache/"
          "^__pycache__/"
          "^output/"
          "^data/"
          "%.ipynb"
        ];
        layout_config = {
          prompt_position = "top";
        };
        mappings = {
          i = {
            "<A-j>" = {
              __raw = "require('telescope.actions').move_selection_next";
            };
            "<A-k>" = {
              __raw = "require('telescope.actions').move_selection_previous";
            };
          };
          /*
            n = {
            	    # IDK where that belongs, definitly not in settings.defaults.mappings as the shortcut is not visible then
                        # The example from https://github.com/nvim-telescope/telescope-live-grep-args.nvim/blob/d600409/README.md#shortcut-functions
                        # just demo, as it seems to be redundant with :Telescope grep_string ?
                        "<leader>gc" = {
                          __raw = "require('telescope-live-grep-args.shortcuts').grep_word_under_cursor";
                        };
                      };
          */
        };
        selection_caret = "> ";
        set_env = {
          COLORTERM = "truecolor";
        };
        sorting_strategy = "ascending";
      };
    };
  };

  # TODO https://xnacly.me/posts/2023/configure-fzf-nvim/ :FZF there is :FzfLua here
  fzf-lua = {
    enable = true;
    profile = "telescope";
    keymaps = {
      "<leader>fg" = "live_grep";
      "<C-p>" = {
        action = "git_files";
        settings = {
          previewers.cat.cmd = lib.getExe' pkgs.coreutils "cat";
          winopts.height = 0.5;
        };
        options = {
          silent = true;
          desc = "Fzf-Lua Git Files";
        };
      };
    };
    settings = {
      files = {
        color_icons = true;
        file_icons = true;
        find_opts = {
          __raw = "[[-type f -not -path '*.git/objects*' -not -path '*.env*']]";
        };
        multiprocess = true;
        prompt = "Files❯ ";
      };
      winopts = {
        col = 0.3;
        height = 0.4;
        row = 0.99;
        width = 0.93;
      };
    };
  };
in
{

  #  using inputs.nixvim.homeModules.nixvim, for a Home Manager installation
  imports = [ inputs.nixvim.homeModules.nixvim ];

  ###### interface

  options = {
    custom.programs.neovim = {

      enable = mkEnableOption "neovim config";

      nixd = {
        expr = {
          home-manager = mkOption {
            type = types.str;
            default = ''(builtins.getFlake "${inputs.self}").nixosConfigurations.DANIELKNB1.options.home-manager.users.type.getSubOptions [ ]'';
            description =
              let
                flake = ''(builtins.getFlake "${inputs.self}")'';
              in
              ''
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
  config = mkIf cfg.enable {

    programs.nixvim = {
      enable = true;

      # see https://github.com/nix-community/nixvim/blob/948b6c0125b35eab7b37e7f7edc79552027075a1/README.md?plain=1#L298
      plugins = {
        inherit
          fzf-lua
          which-key
          lspconfig
          lsp
          trouble
          telescope
          cmp
          cmp-nvim-lsp
          cmp-nvim-lsp-document-symbol
          cmp-buffer
          cmp-path
          cmp-rg
          cmp-omni
          cmp-cmdline
          cmp-cmdline-history
          cmp-nvim-lsp-signature-help
          cmp-treesitter
          no-neck-pain
          nvim-autopairs
          nvim-lightbulb
          faster
          lsp-format
          nvim-bqf
          ;
      };

      # see https://github.com/nix-community/nixvim/blob/948b6c0125b35eab7b37e7f7edc79552027075a1/README.md?plain=1#L315
      #	extraPlugins = builtins.attrValues {};

      # see https://github.com/nix-community/nixvim/blob/948b6c0125b35eab7b37e7f7edc79552027075a1/README.md?plain=1#L365
      #opts = {};

      # see https://github.com/nix-community/nixvim/blob/948b6c0125b35eab7b37e7f7edc79552027075a1/README.md?plain=1#L385
      #inherit keymaps;

      # see https://github.com/nix-community/nixvim/blob/948b6c0125b35eab7b37e7f7edc79552027075a1/README.md?plain=1#L452
      #globals.mapleader = "";

      # see https://github.com/nix-community/nixvim/blob/nixos-25.11/modules/output.nix#L83
      # via https://nix-community.github.io/nixvim/25.11/NeovimOptions/index.html#extraconfigluapre
      #inherit extraConfigLuaPre;

      # see https://github.com/nix-community/nixvim/blob/948b6c0125b35eab7b37e7f7edc79552027075a1/README.md?plain=1#L464
      # TODO my old setup https://github.com/573/nix-config-1/blob/dc2da3bc963aeba2c6616a993e6973041120fd3d/home/programs/neovim.nix
      #extraConfigLua = '''';

      # see https://github.com/nix-community/nixvim/blob/nixos-25.11/modules/doc.nix#L3
      # via https://nix-community.github.io/nixvim/25.11/NeovimOptions/index.html#enableman
      enableMan = false;

      # see https://github.com/nix-community/nixvim/blob/nixos-25.11/modules/top-level/output.nix#L19
      # via https://nix-community.github.io/nixvim/25.11/NeovimOptions/index.html#vialias
      viAlias = true;

      # see https://github.com/nix-community/nixvim/blob/nixos-25.11/modules/top-level/nixpkgs.nix#L41
      # via https://nix-community.github.io/nixvim/25.11/NeovimOptions/nixpkgs/index.html#nixpkgspkgs
      #nixpkgs.pkgs = pkgs;

      # see https://github.com/nix-community/nixvim/blob/nixos-25.11/modules/top-level/nixpkgs.nix#L133 (via
      # https://nix-community.github.io/nixvim/25.11/NeovimOptions/nixpkgs/index.html#nixpkgsoverlays)
      # Override neovim-unwrapped with one from a flake input
      # Using `stdenv.hostPlatform` to access `system`

      # TODO https://nix-community.github.io/nixvim/25.11/plugins/gitlinker/index.html?highlight=osc5#pluginsgitlinkersettings
      # https://nix-community.github.io/nixvim/25.11/clipboard/index.html?highlight=clipboar#clipboardregister
      # https://nix-community.github.io/nixvim/25.11/clipboard/providers/index.html?highlight=clipboar#clipboardproviders
      # and see :h clipboard and :h clipboard-osc52
      # TODO https://jvns.ca/til/vim-osc52/
      globals = {
        clipboard = "osc52";
      };
    };

    # see also viAlias, see https://github.com/nix-community/nixvim/blob/nixos-25.11/modules/top-level/output.nix#L19
    # via https://nix-community.github.io/nixvim/25.11/NeovimOptions/index.html#vialias
    home.sessionVariables = {
      EDITOR = lib.mkDefault "vi";
    };
  };
}
