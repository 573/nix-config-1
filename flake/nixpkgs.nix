{ inputs
, rootPath
, system
, nixOnDroid ? false
,
}:
let
  config = {
    allowAliases = false;
    allowUnfree = true;
  };
in
import inputs.nixpkgs {
  inherit config system rootPath;

  overlays =
    [
      #inputs.rust-overlay.overlays.default # now commented out due to:  error: attribute 'rust-analyzer' missing https://github.com/573/nix-config-1/actions/runs/4923802480/jobs/8796067915#step:6:826 # rustc still 1.64 when building as opposed to nix shell 1.67
      #(import inputs.rust-overlay)
      (final: prev:
        let
          inherit (prev.stdenv.hostPlatform) system;
          # inherit rootPath;

          unstable = import inputs.unstable { inherit config system; };
          latest = import inputs.latest { inherit config system; };
          #        staging = import inputs.staging { inherit config system; };

          # TODO https://github.com/onekey-sec/unblob/blob/4e900ff/flake.nix#L21
          moreOverlays =
            (map (x: x.overlays.default) [
              # NOTE: overlays listed here are meant to use the overlays.${system} syntax (?) (is that so ?)
              # dont use see https://github.com/nix-community/neovim-nightly-overlay/issues/153#issuecomment-1264366764
              #inputs.neovim-nightly-overlay.overlay # What I try to achieve here is to have neovim as overridden in the overlay below be the neovim neovim-nightly-overlay provides !??
              #inputs.neovim-flake.overlay
              #inputs.rust-overlay # letzer versuch
              #inputs.emacs-overlay
              #inputs.talon
              #inputs.nixpkgs-ruby
              inputs.ocaml-overlay # see i. e. https://github.com/nix-ocaml/nix-overlays/blob/51c3d87/README.md#alternative-advanced
              #inputs.nixpkgs-wayland
            ])
            /*++ [
              inputs.tree-grepper.overlay."${system}" # https://github.com/bnjmnt4n/system/blob/28a560b/flake.nix#L55 (fixes error lib/fixed-points.nix:76:22:)
            ]*/
          ;
        in
        {
          /*inherit
            (unstable)
            #lua-language-server
            #texlab
            ##deno # long rebuild needed in unstable so taking release-version

            #stylua
            ##sqlite # long rebuild needed in unstable so taking release-version

            #nodejs_latest# long rebuild needed in unstable so taking release-version

            #broot

            #chafa
            ##w3m # long rebuild needed in unstable so taking release-version, see i. e. nix why-depends --derivation nixos-unstable#w3m nixos-unstable#fontforge

            ##fff # long rebuild needed in unstable so taking release-version, see i. e. nix why-depends --derivation nixos-unstable#w3m nixos-unstable#fontforge

            #epr
            #vale
            #ltex-ls
            # TODO https://github.com/rocktimsaikia/cambd-cli

            #ripgrep-all
            #pandoc
            #micro
            #jdt-language-server
            #ranger
            #masterpdfeditor
            #ouch

            #playwright-test

             	    # hydra build still in queue for mdbook-0.4.30 my gha fails to build that
             	    # https://discourse.nixos.org/t/hydra-check-does-package-x-still-build-on-channel-y/6126/6
             	    # https://hydra.nixos.org/job/nixos/trunk-combined/nixpkgs.mdbook.aarch64-linux
             	    # https://hydra.nixos.org/build/223289643
             	    mdbook
            ; */

          #inherit (latest) photoprism cups-filters abcde git-absorb flutter dart difftastic diffoscope bashdb scrcpy hydra-check hledger hledger-web autorandr mons maim xdotool xclip nil keepassxc signal-desktop julia_19 sd openssh tailscale;

          inherit (latest) julia_19;

          inherit (inputs.emacs-overlay.lib.${system}) emacsWithPackagesFromUsePackage;
          inherit (inputs.emacs-overlay.packages.${system}) emacs-git-nox;

          #inherit (latest.xorg) libxcvt;

          #inherit (latest.python311Packages) bpython;

          talon = inputs.talon.packages.${system}.default;

          nixd = inputs.nixd.packages.${system}.default;

          openai-whisper =
            let
              inherit (latest) openai-whisper;
            in
            openai-whisper.override {
              torch = prev.python3.pkgs.torch-bin;
            };

          # https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/6
          /*
                   nil = (prev.makeRustPlatform {
            cargo = prev.rust-bin.stable.latest.default;
            rustc = prev.rust-bin.stable.latest.default;
          }).buildRustPackage {
              pname = "nil";
              version = "2023.02.23";
                     src = inputs.nil;
              nativeBuildInputs = [
                       prev.rust-bin.stable.latest.default
                     ];
                     cargoSha256 = "sha256-DaUFXksA/GDSjLqoEhK1uNMD7Nh474yZN4uu4YQytvI=";
            };
          */

          /*
                  nil = prev.callPackage "${inputs.unstable}/pkgs/development/tools/language-servers/nil" {
            rustPlatform = prev.rustPlatform // {
              buildRustPackage = args:
                prev.rustPlatform.buildRustPackage (args // {
           nativeBuildInputs = [
                    prev.rust-bin.stable.latest.default
                  ];
                  src = inputs.nil;
           version = "2023.02.23";
                  cargoHash = "sha256-DaUFXksA/GDSjLqoEhK1uNMD7Nh474yZN4uu4YQytvI=";
                });
            };
          };
          */

          yt-dlp =
            prev.yt-dlp.overrideAttrs
              (_: { src = inputs.yt-dlp; });

          pup =
            let
              inherit (unstable) pup;
            in
            pup.overrideAttrs
              (_: { src = inputs.pup; });

          nodePackages =
            prev.nodePackages
            // {
              inherit
                (latest.nodePackages)
                bash-language-server
                vim-language-server
                vscode-json-languageserver-bin
                yaml-language-server
                ;
            };

          gradle-vscode-extension =
            prev.vscode-extensions.vscjava
            // {
              inherit
                (latest.vscode-extensions.vscjava)
                vscode-gradle
                ;
            };

          vimPlugins =
            prev.vimPlugins
            // {
              inherit
                (latest.vimPlugins)
                nvim-lspconfig
                nix-develop-nvim
                ;
              inherit
                (latest.vimPlugins)
                cmp-cmdline
                plenary-nvim
                #nvim-lspconfig
                trouble-nvim
                nvim-cmp
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
                #            LanguageTool-nvim

                #vim-grammarous
                comment-nvim
                nvim-treesitter
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
                lualine-nvim
                nvim-osc52
                nvim-dap-python
                nvim-dap
                nvim-gdb
                neoterm
                nvim-dap-ui
                nvim-treesitter-endwise
                orgmode
                neorg
                ;
            };

          builtGrammars =
            prev.tree-sitter.builtGrammars
            // {
              inherit
                (unstable.tree-sitter.builtGrammars)
                tree-sitter-lua
                tree-sitter-python
                tree-sitter-nix
                tree-sitter-ruby
                tree-sitter-vim
                tree-sitter-json
                tree-sitter-bash
                tree-sitter-comment
                tree-sitter-latex
                ;
            };

          #nvim-lspconfig = prev.vimUtils.buildVimPluginFrom2Nix {
          #  pname = "nvim-lspconfig";
          #  version = "2023-06-03";
          #  src = inputs.nvim-lspconfig;
          #};

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
          fsread-nvim = prev.vimUtils.buildVimPlugin {
            name = "fsread.nvim";
            src = inputs.fsread-nvim;
          };
          duck-nvim = prev.vimUtils.buildVimPlugin {
            name = "duck.nvim";
            src = inputs.duck-nvim;
          };
          deferred-clipboard-nvim = prev.vimUtils.buildVimPlugin {
            name = "deferred-clipboard.nvim";
            src = inputs.deferred-clipboard-nvim;
          };

          statusline-action-hints-nvim = prev.vimUtils.buildVimPlugin {
            name = "statusline-action-hints.nvim";
            src = inputs.statusline-action-hints-nvim;
          };

          murmur-lua-nvim = prev.vimUtils.buildVimPlugin {
            name = "murmur.lua";
            src = inputs.murmur-lua-nvim;
          };

          filetype-nvim = prev.vimUtils.buildVimPluginFrom2Nix {
            pname = "filetype.nvim";
            src = inputs.filetype-nvim;
            version = "2022.06";
            meta.homepage = "https://github.com/nathom/filetype.nvim/";
          };


          vscode-extensions-new =
            (final.vscode-extensions.vscjava).overrideAttrs
              (_: { vscode-gradle = latest.vscode-extensions.vscjava.vscode-gradle; });

          nvim-treesitter-full-latest =
            latest.vimPlugins.nvim-treesitter.withAllGrammars;

          nvim-treesitter-full =
            (final.vimPlugins.nvim-treesitter.withAllGrammars).overrideAttrs
              (_: { src = inputs.nvim-treesitter; });

          nvim-treesitter-as-in-manual = unstable.vimPlugins.nvim-treesitter.withPlugins (
            plugins:
              with plugins; [
                nix
                python
              ]
          );

          nvim-treesitter-selection = (final.vimPlugins.nvim-treesitter.withPlugins (_:
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

          ghcWithHoogle = final.haskellPackages.ghcWithHoogle (haskellPackages:
            with haskellPackages; [
              # libraries
              arrows
              async
              cgi
              criterion
              # tools
              cabal-install
              haskintex
              haskell-language-server
            ]);

          # inherit (inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}) neovim; # see staging PR note


          desed = final.callPackage "${rootPath}/drvs/desed" { };

          /*
                	  As in:
                	  nix-repl> nixosConfigurations.DANIELKNB1.pkgs.neovim.unwrapped.version
              		"84378c4"
              		nix-repl> nixosConfigurations.DANIELKNB1.pkgs.neovim-nightly.version
              		"84378c4"
              	  */
          /* TODO This is home/programs/neovim.nix now
          my-neovim =
            let
              inherit (final) neovim;
            in
            neovim.override {
              #	  in unstable.neovim.override {
              # final.neovim-nightly.override { # error: attribute 'neovim-nightly' missing # final, weil das overlay bereits applied wurde # inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.neovim.override { # error: anonymous function at /nix/store/yz0w1s863vqsas7jpzg5rpc29ig17566-source/pkgs/applications/editors/neovim/default.nix:1:1 called with unexpected argument 'viAlias' # inputs.neovim-flake.packages.${prev.stdenv.hostPlatform.system}.neovim.override { # I wonder why final.neovim-nightly doesn't work here or eveb final.neovim when the overlay is applied already above
              viAlias = true;
              vimAlias = true;
              # vimdiffAlias = true; # for this needs to override wrapNeovimUnstable in overlay (https://github.com/NixOS/nixpkgs/pull/121339#issuecomment-830868690)
              configure = {
                packages.plugins = {
                  start =
                    (with final.vimPlugins; [
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
                      final.nvim-treesitter-full-latest
                      #pkgs.nvim-treesitter-selection
                    ])
                    ++ (with final; [
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
                };

                customRC = ''
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
              };
            };
           	    */

          inherit
            (final)
            tree-grepper
            /*
            talon # getting  error: attribute 'pango' missing gnome2.pango
            */
            ;

          #inherit (inputs) sanemacs;

          # see https://sourcegraph.com/github.com/johnae/world@016fbbb0d64af7fc3963e2253e6dffada8d26cb5/-/blob/packages/overlays.nix?L78
          # better: https://sourcegraph.com/search?q=context:global+content:%22emacsWithPackagesFromUsePackage%22+file:%5E.*%5C.nix%24&patternType=standard&sm=1
          # TODO https://github.com/nix-community/emacs-overlay/issues/341#issuecomment-1605290875
          # TODO init.el ?:
          # https://matrix.to/#/!ZmUSesoOjmVsKbzFbp:nixos.org/$IvE50XOAU4T4eBJZfZtHoY7QaXfsDuEMGiuPcF-gKXA?via=nixos.org&via=matrix.org&via=tchncs.de
          # https://www.gnu.org/software/emacs/manual/html_node/emacs/Init-File.html
          # https://www.reddit.com/r/emacs/comments/phb5sw/should_i_use_emacs_or_initel_file_if_i_want_to/
          # https://emacs.stackexchange.com/questions/51559/difference-between-emacs-and-init-el-and-the-point-of-not-keeping-multiple-in
          my-emacs =
            let
              # see https://github.com/nix-community/emacs-overlay/blob/eb1d1ce/overlays/package.nix and https://github.com/nix-community/emacs-overlay/blob/842fdae/overlays/emacs.nix
              inherit (inputs.emacs-overlay.lib.${system}) emacsWithPackagesFromUsePackage;
              inherit (inputs.emacs-overlay.packages.${system}) emacs-git-nox;
              inherit rootPath;
              my-default-el = final.runCommand "default.el" { text = builtins.readFile "${rootPath}/home/misc/emacs.el"; } ''
                	      target=$out/share/emacs/site-lisp/default.el
                	      mkdir -p "$(dirname "$target")"
                	      echo -n "$text" > "$target"
              '';
            in
            emacsWithPackagesFromUsePackage {
              package = emacs-git-nox;
              config = ""; # just an empty string as defaultInitFile is false anyway and default.el as an emacs package is used (my-default-el), see https://github.com/nix-community/emacs-overlay/commit/94c7550ae2155ebd04a7527b3a200deafece86dc#diff-576b45d3b2393944d2637eab91a52fa6522a49148ec3424a0bb1345c4a38b14dR48
              #defaultInitFile = false; # false by default anyway, meaning not using value of config, see https://github.com/nix-community/emacs-overlay/blob/94c7550ae2155ebd04a7527b3a200deafece86dc/elisp.nix#L15C1-L15C1
              alwaysEnsure = true;
              #override = epkgs: epkgs // { inherit my-default-el; };
              extraEmacsPackages = epkgs:
                with epkgs; [
                  my-default-el # including this here seems essential while override = epkgs: epkgs // { inherit my-default-el; }; seems not and is also not sufficient itself
                  vterm
                  #treesit-grammars.with-all-grammars
                  use-package
                  moe-theme
                  deft
                  zetteldeft
                  company-emoji
                  org
                  org-contrib
                  visual-fill-column
                  org-bullets
                  writeroom-mode
                ];
            };

          devenv = inputs.devenv.packages.${system}.devenv;


          # works only when rust-overlay not nested in moreOverlays
          rustenv = let inherit (final.rust-bin.stable.latest) default; in default.override {
            extensions = [ "rust-src" "rust-analyzer" ];
            targets = [ "aarch64-unknown-linux-gnu" "wasm32-unknown-unknown" ];
          };

          somemore = prev.lib.composeManyExtensions moreOverlays final prev;

          # TODO [gist] For later ref - override to i. e. nix_2_13 - see https://github.com/Gerschtli/nix-config/commit/da486994d122eb4e64a8b7940e9ef3469b44e06c#diff-3bcbef26c40d018f46094799af27a3698c921aa094bb2bffdaac77266c90ec21L64

          # the only alias that I need, this allows me to set allowAliases=false
          inherit
            system
            # rootPath

            ;
        })
    ] ++ (map (x: x.overlays.default) [
      inputs.nixGL
      inputs.rust-overlay
      ###########inputs.emacs-overlay
      inputs.nixpkgs-ruby
      #	inputs.talon
      #       inputs.ocaml-overlay
      inputs.nixpkgs-wayland
      inputs.neovim-nightly-overlay
    ])
    ++ [
      inputs.tree-grepper.overlay."${system}"
      #inputs.ocaml-overlay.overlays."${system}"
    ]
    ++ inputs.nixpkgs.lib.optional nixOnDroid
      inputs.nix-on-droid.overlays.default;
}
