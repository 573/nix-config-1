/**
  Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

  Parameter `[inputs]` here is a deviation from the orinal author's intent (doing that via overlay) and should maybe be fixed
  For `[inputs]` parameter determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{
  config,
  lib,
  pkgs,
  inputs,
  #unstable,
  hostname,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    mkEnableOption
    mkAfter
    mkIf
    mkMerge
    ;
  /**
    Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

    If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
  */
  #inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.custom.base.general;
  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";
in
{
  ###### interface
  #  using inputs.nixvim.homeModules.nixvim, for a Home Manager installation
  imports = [ inputs.nixvim.homeModules.nixvim ];

  options = {
    custom.base.general = {
      enable = mkEnableOption "basic config" // {
        default = true;
      };

      lightWeight = mkEnableOption "light weight config for low performance hosts" // {
        default = false;
      };

      wsl = mkEnableOption "config for NixOS-WSL instances";

      minimal = mkEnableOption "minimal config";

      # FIXME https://github.com/nix-community/nix-on-droid/issues/257
      termux = mkEnableOption "config for the non-nixos termux android app";
    };
  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      custom.programs = {
        #emacs-novelist.enable = true;
        #emacs-no-el.enable = true;
        #emacs-nano.enable = true;
        bash.enable = true;
        #shell = {
        #  initExtra = mkAfter ''
        #                eval "$(${unstable.bat-extras.batpipe}/bin/batpipe)"
        #    	  '';
        #};
        htop.enable = true;
        nix-index.enable = true;
        #helix.enable = true;
        #yazi.enable = true;
        #xplr.enable = true;
        /*
          nixvim = {
            #          enable = true;
            # not inherit not same attr
            lightWeight = cfg.lightWeight;
          };
        */
      };

      programs = {
        # replaces my module as of https://github.com/573/nix-config-1/commit/5450342df3690d8d464c286952c977f1701dbeb5 (last rev of module)
        nixvim = {
          enable = true;
          lsp = {
            keymaps = [
              {
                key = "K";
                lspBufAction = "hover";
              }
            ];
            servers = {
              nixd = {
                enable = true;
                package = inputs.nixd.packages.x86_64-linux.default;
                config = {
                  nixpkgs.expr = ''import $(builtins.getFlake "${inputs.self}").inputs.nixpkgs { }'';
                  formatting.command = [ "nixfmt" ];
                  diagnostic.suppress = [
                    "sema-escaping-with"
                    "var-bind-to-this"
                  ];
                  options = {
                    home-manager.expr = ''(builtins.getFlake "${inputs.self}").homeConfigurations."dani@maiziedemacchiato".options'';
                    nixvim.expr = ''((builtins.getFlake "${inputs.self}").homeConfigurations."dani@maiziedemacchiato".options.programs.nixvim.type.getSubOptions [ ]'';
                    nixos.expr = ''(builtins.getFlake "${inputs.self}").nixosConfigurations.DANIELKNB1.options'';
                  };
                };
              };
            };
          };
          plugins = {

            cmp = {
              enable = true;

              autoEnableSources = true;
              settings = {
                # see https://stackoverflow.com/a/74714258 and https://stackoverflow.com/a/74730907
                completion = {
                  keyword_length = 3;
                };
                sources = [
                  # alternative would only be not enable cmp and using C-x C-o - probably not how it is supposed to work,
                  # see https://gpanders.com/blog/whats-new-in-neovim-0-11/#builtin-auto-completion
                  # and here under lsp = ...
                  { name = "buffer"; }
                  { name = "cmdline"; }
                  { name = "cmdline-history"; }
                  #             { name = "nvim_lsp"; }
                  #             { name = "nvim_lsp_document_symbol"; }
                  { name = "nvim-lsp-signature-help"; }
                  { name = "omni"; }
                  { name = "path"; }
                  { name = "rg"; }
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

            cmp-buffer.enable = true;
            cmp-cmdline.enable = true;
            cmp-cmdline-history.enable = true;
            #        cmp-nvim-lsp.enable = true;
            #        cmp-nvim-lsp-document-symbol.enable = true;
            cmp-nvim-lsp-signature-help.enable = true;
            cmp-omni.enable = true;
            cmp-path.enable = true;
            cmp-rg.enable = true;
            cmp-treesitter.enable = true;

            conform-nvim = {
              enable = true;
              settings = {
                formatters_by_ft = {
                  nix = [ "nixfmt" ];
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

            # https://github.com/ruifm/gitlinker.nvim, <lk>gy
            gitlinker.enable = true;

            gitsigns = {
              enable = true;
              settings = {
                current_line_blame = false;
                current_line_blame_opts = {
                  virt_text = true;
                  virt_text_pos = "eol";
                };
                signcolumn = true;
                signs = {
                  add = {
                    text = "│";
                  };
                  change = {
                    text = "│";
                  };
                  changedelete = {
                    text = "~";
                  };
                  delete = {
                    text = "_";
                  };
                  topdelete = {
                    text = "‾";
                  };
                  untracked = {
                    text = "┆";
                  };
                };
                watch_gitdir = {
                  follow_files = true;
                };
                status_formatter = ''
                  function(status)
                    local added, changed, removed = status.added, status.changed, status.removed
                    local status_txt = {}
                    if added and added > 0 then
                      table.insert(status_txt, '+' .. added)
                    end
                    if changed and changed > 0 then
                      table.insert(status_txt, '~' .. changed)
                    end
                    if removed and removed > 0 then
                      table.insert(status_txt, '-' .. removed)
                    end
                    return table.concat(status_txt, ' ')
                  end
                '';
              };
            };

            lsp.enable = true;

            lsp-format.enable = true;

            lsp-lines = {
              enable = true;
              # Removed this due to the evaluation warning, see lz-n plugin further down
              #lazyLoad.settings = {
              #  keys = [
              #    {
              #      __unkeyed-1 = "<leader>l";
              #      __unkeyed-3 = "function() require('lsp_lines').toggle() end";
              #      desc = "Toggle lsp_lines";
              #    }
              #  ];
              #};
            };

            # installed this due to
            # evaluation warning: Nixvim (lazy loading): You have enabled lazy loading support for the following plugins but have not enabled a lazy loading provider.
            #          1. plugins.lsp-lines
            #
            #        Currently supported lazy providers:
            #          - lz-n
            lz-n = {
              enable = true;

              keymaps = [
                {
                  action = config.lib.nixvim.mkRaw "function() require('lsp_lines').toggle() end";
                  key = "<leader>l";
                  options = {
                    desc = "Toggle lsp_lines";
                  };
                  plugin = "lsp-lines";
                }
              ];

              # see https://nix-community.github.io/nixvim/plugins/lz-n/index.html#pluginslz-nimports
              # and see https://nix-community.github.io/nixvim/plugins/lz-n/plugins.html
              # plugins = [];
            };

            indent-blankline = {
              enable = true;
              settings = {
                exclude = {
                  buftypes = [
                    "terminal"
                    "quickfix"
                  ];
                  filetypes = [
                    ""
                    "checkhealth"
                    "help"
                    "lspinfo"
                    "packer"
                    "TelescopePrompt"
                    "TelescopeResults"
                    "yaml"
                  ];
                };
                indent = {
                  char = "│";
                };
                scope = {
                  show_end = false;
                  show_exact_scope = true;
                  show_start = false;
                };
              };
            };

            no-neck-pain.enable = true;

            nvim-autopairs.enable = true;

            # nvim-lightbulb.enable = true;

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
                "<leader>ff" = {
                  action = "find_files";
                  options = {
                    desc = "Find files";
                  };
                };
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

            toggleterm = {
              enable = true;
              settings = {
                direction = "float";
                float_opts = {
                  border = "curved";
                  height = 30;
                  width = 130;
                };
                open_mapping = "[[<c-\\>]]";
              };
            };

            trouble.enable = true;

            # reason:
            # evaluation warning: nixos profile: Nixvim (plugins.web-devicons): This plugin was enabled automatically because the following plugins are enabled.
            #                  This behaviour is deprecated. Please explicitly define `plugins.web-devicons.enable` or alternatively
            #                  enable `plugins.mini.enable` with `plugins.mini.modules.icons` and `plugins.mini.mockDevIcons`, or
            #                  `plugins.mini-icons.enable` with `plugins.mini-icons.mockDevIcons`.
            #                  plugins.telescope
            #                  plugins.trouble
            #                  plugins.fzf-lua
            web-devicons.enable = true;

            # FIXME without this which-key config strangely the leader key is not working
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
          };

          enableMan = false;
          viAlias = true;
          vimAlias = true;
          env = {
            EDITOR = "nvim";
            VISUAL = "nvim";
          };
          globals = {
            clipboard = "osc52";
          };
        };

        bash = {
          sessionVariables =
            # https://unix.stackexchange.com/a/18443/102072 and https://github.com/nix-community/home-manager/blob/83665c39fa688bd6a1f7c43cf7997a70f6a109f9/modules/home-environment.nix#L296 - ''... ''\${PROMPT_COMMAND}'' did not work on Arch+nix
            # On NixOS systems I can see the immediate effect in /home/nixos/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh
            # See here as well https://github.com/nix-community/home-manager/blob/fce051eaf881220843401df545a1444ab676520c/modules/misc/vte.nix#L40
            # and https://www.reddit.com/r/NixOS/comments/1e2quog/help_escaping_triple_single_quotes/
            # TODO problem on non-NixOS (generic-linux, see https://github.com/nix-community/home-manager/blob/11cc5449c50e0e5b785be3dfcb88245232633eb8/modules/targets/generic-linux.nix#L4) with duplicate sourcing of nix.sh (both in hm-session-vars.sh and in .bashrc) and hm-session-vars.sh (both in .profile and in .bashrc) comes from https://github.com/nix-community/home-manager/blob/98d030f723e0a4a446e56b276573efb8bef422f5/modules/targets/generic-linux.nix#L41 (via https://github.com/nix-community/home-manager/issues/1782#issue-802788592). This comment described the prior on-demand workaround https://github.com/nix-community/home-manager/pull/797#issuecomment-544783247. The duplication basically happening here https://github.com/nix-community/home-manager/blob/11cc5449c50e0e5b785be3dfcb88245232633eb8/modules/programs/bash.nix#L268 (via ignoredly https://github.com/nix-community/home-manager/commit/d06bcf4c970e45fa260e992d96160b48712504e6#r40204451).
            # another example https://github.com/ajeetdsouza/zoxide/blob/2299f2834bcc6e1c07a0118460a638577a890d89/templates/bash.txt#L57
            # FIXME having it in programs.bash.sessionVariables leads to it being ignored for PROMPT_COMMAND on NixOS
            #PROMPT_COMMAND = ''history -n; history -w; history -c; history -r'' + lib.optionalString (!config.custom.base.non-nixos.enable) "; $PROMPT_COMMAND";
            lib.optionalAttrs (config.custom.base.non-nixos.enable) {
              PROMPT_COMMAND = "history -n; history -w; history -c; history -r";
            };
        };

        zoxide = {
          enable = true;
          #package = unstable.zoxide;
          enableBashIntegration = true;
        };
        eza = {
          enable = true;
          enableBashIntegration = true;
          #package = unstable.eza;
        };
      };

      home = {
        language = {
          base = localeEnglish;
          address = localeEnglish;
          #collate = localeEnglish;
          #ctype = localeEnglish;
          measurement = localeGerman;
          #messages = localeEnglish;
          monetary = localeEnglish;
          name = localeEnglish;
          #numeric = localeEnglish;
          paper = localeGerman;
          telephone = localeEnglish;
          #time = localeGerman;
        };

        packages = attrValues {
          inherit (pkgs)
            pptx2md
            desed
            # TODO Put into home/programs/neovim ASAP
            # https://discourse.nixos.org/t/how-can-i-distinguish-between-two-packages-who-has-the-same-name-for-the-binary/39770/2
            #(inputs.nixvim.packages."${system}".default)
            # this way can have nvim-mini in parallel
            # https://discourse.nixos.org/t/how-can-i-distinguish-between-two-packages-who-has-the-same-name-for-the-executable/39770/4
            # FIXME assumes now broken https://github.com/nix-community/nixvim/commit/d53afe0d7348b6c41a9127db4217adeaf1e9d69b
            # https://github.com/nix-community/nixvim/compare/main...573:nixvim:fit-23.11
            #(pkgs.runCommand "nix-nvim" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
            #           mkdir -p $out/bin
            #           makeWrapper ${inputs.nixvim.packages."${system}".default}/bin/nvim $out/bin/nix-nvim
            #           '')
            #nixvim-configured
            #bc
            file
            # httpie   # build for aarch64-linux times out, https://github.com/573/nix-config-1/actions/runs/3744580521/jobs/6358117765#step:5:7429
            #iotop
            jq
            #mmv-go
            nmap
            #ncdu
            #nload # network traffic monitor
            #pwgen
            #ripgrep # build broken on aarch64-linux, https://github.com/573/nix-config-1/actions/runs/6309380420/job/17129186691, also build unmaintained currently
            #silver-searcher
            tree
            #wget
            yq-go

            gzip
            unzip
            xz
            zip

            bind # dig
            netcat

            psmisc # killall
            whois

            sqlite

            #actionlint
            #powerline-rs

            #gist
            fd
            sd
            #pv

            # TODO https://www.arthurkoziel.com/restic-backups-b2-nixos
            #backblaze-b2
            attr

            nix-inspect
            #            zellij
            #viddy
            #zoxide # rather home module
            #qrencode
            nixfmt

            sendme
            ;

          # see https://jvns.ca/til/vim-osc52/
          pbcopy = pkgs.writeShellApplication {
            name = "pbcopy";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              printf "\033]52;c;%s\007" "$(base64 | tr -d '\n')"
            '';
          };

          #inherit (unstable)
          # eza
          #            yazi
          #;

          #	  batman = (unstable.bat-extras.batman.overrideAttrs (oldAttrs: {
          #    propagatedBuildInputs = [
          #      unstable.bat
          #    ];
          #  }));

        }; # replaces with pkgs; [], i. e. because nixd catches duplicates this way

        sessionVariables = {
          LESS = concatStringsSep " " [
            "--RAW-CONTROL-CHARS"
            "--no-init"
            "--quit-if-one-screen"
            "--tabs=4"
          ];
          MY_BM_HMSESSIONVARS = "/etc/profiles/per-user/nixos/etc/profile.d/hm-session-vars.sh";
          PAGER = lib.getExe pkgs.less;
          SHELL = "bash";
          # TODO how does that interfere with same attr in neovim.nix
          EDITOR = "nvim";
          VISUAL = "nvim"; # config.home.sessionVariables.EDITOR;
          # (ft-man-plugin),
          # https://neovim.io/doc/user/starting.html#starting,
          # https://www.chrisdeluca.me/2022/03/07/use-neovim-as.html
          # nix-repl> nixOnDroidConfigurations.sams9.config.home-manager.config.home.sessionVariables.MANPAGER
          # MANPAGER="nvim -u NONE -i NONE \"+runtime plugin/man.lua\" -c \"Man"'!'"\" -o -"
          # export MANPAGER='nvim -u NONE -i NONE "+runtime plugin/man.lua" -c "Man"''!'' -o -'
          #working#MANPAGER = "${config.custom.programs.neovim.finalPackage}/bin/nvim -u NONE -i NONE '+runtime plugin/man.lua' -c Man! -o -";

          # https://unix.stackexchange.com/a/18443/102072 and https://github.com/nix-community/home-manager/blob/83665c39fa688bd6a1f7c43cf7997a70f6a109f9/modules/home-environment.nix#L296 - ''... ''\${PROMPT_COMMAND}'' did not work on Arch+nix
          # On NixOS systems I can see the immediate effect in /home/nixos/.local/state/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh
          # See here as well https://github.com/nix-community/home-manager/blob/fce051eaf881220843401df545a1444ab676520c/modules/misc/vte.nix#L40
          # and https://www.reddit.com/r/NixOS/comments/1e2quog/help_escaping_triple_single_quotes/
          # TODO problem on non-NixOS (generic-linux, see https://github.com/nix-community/home-manager/blob/11cc5449c50e0e5b785be3dfcb88245232633eb8/modules/targets/generic-linux.nix#L4) with duplicate sourcing of nix.sh (both in hm-session-vars.sh and in .bashrc) and hm-session-vars.sh (both in .profile and in .bashrc) comes from https://github.com/nix-community/home-manager/blob/98d030f723e0a4a446e56b276573efb8bef422f5/modules/targets/generic-linux.nix#L41 (via https://github.com/nix-community/home-manager/issues/1782#issue-802788592). This comment described the prior on-demand workaround https://github.com/nix-community/home-manager/pull/797#issuecomment-544783247. The duplication basically happening here https://github.com/nix-community/home-manager/blob/11cc5449c50e0e5b785be3dfcb88245232633eb8/modules/programs/bash.nix#L268 (via ignoredly https://github.com/nix-community/home-manager/commit/d06bcf4c970e45fa260e992d96160b48712504e6#r40204451).
          # another example https://github.com/ajeetdsouza/zoxide/blob/2299f2834bcc6e1c07a0118460a638577a890d89/templates/bash.txt#L57
          # FIXME having it in programs.bash.sessionVariables leads to it being ignored for PROMPT_COMMAND on NixOS
          #PROMPT_COMMAND = ''history -n; history -w; history -c; history -r'' + lib.optionalString (!hostname == "maiziedemacchiato") "; $PROMPT_COMMAND";
        }
        // lib.optionalAttrs (!config.custom.base.non-nixos.enable) {
          PROMPT_COMMAND = "history -n; history -w; history -c; history -r; $PROMPT_COMMAND";
        };
      };
    }

    {
      home.stateVersion = "24.11";
    }

    {
      programs.fzf = {
        enable = true;
        #enableBashIntegration = true;
        # see https://sourcegraph.com/search?q=file:%5E*.nix%24+%22--bind%22+fzf&patternType=keyword&sm=0 and https://github.com/junegunn/fzf/issues/2323#issuecomment-991335353
        defaultOptions = [
          "--bind 'ctrl-e:execute(echo {+} | ${lib.getExe' pkgs.findutils "xargs"} -o vi)'"
        ];
      };

      # FIXME: set to sd-switch once it works for krypton, https://home-manager-options.extranix.com/?query=systemd.user.startServices&release=release-24.05
      systemd.user.startServices = true;
    }

    (mkIf (!cfg.minimal) {
      custom = {

        # see ./home/programs
        programs = {
          git.enable = true;
          #nnn.enable = true;
          rsync.enable = true;
          ssh = {
            enable = true;
            #  modules = [ "vcs" ];
          };
        };
      };

      programs.home-manager.enable = true;
    })

    (mkIf cfg.wsl {
      custom.programs.shell.shellAliases = {
        pbcopy = "powershell.exe -NoProfile -Command \"Set-Clipboard -Value \\\$input\"";
        pbpaste = "powershell.exe -NoProfile -Command 'Get-Clipboard'";
      };

      # programs.starship.enable = true; # long lines are distorted
    })

    (mkIf (!cfg.lightWeight && !cfg.wsl) {
      custom.misc.util-bins.enable = true;
      custom.programs = {
        #tmux.enable = true;
        # comment this out to enable:
        # nix build --eval-store auto --store ssh-ng://root@eu.nixbuild.net -L -v --show-trace --impure .#nixosConfigurations.guitar.config.system.build.toplevel
        # works then, tested it
        emacs-configured.enable = true;
        #helix.enable = true;
        #yazi.enable = true;
      };

      home.packages = attrValues {
        inherit (pkgs)
          lshw
          ouch
          strace
          lineselect
          cyme

          # poc
          age
          ;
      };
    })
  ]);
}
