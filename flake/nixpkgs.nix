{ inputs
, rootPath
, system
, nixOnDroid ? false
}:
let
  config = {
    # FIXME https://discourse.nixos.org/t/unexpected-11h-build-after-auto-update/39907/9
    allowAliases = false;
    allowUnfree = true;
    cudaSupport = true;
    cudnnSupport = true;
    cudaVersion = "12";
    # https://discourse.nixos.org/t/laggy-mouse-when-use-nvidia-driver/38410
    nvidia.acceptLicense = true;
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
          inherit (prev.lib) remove flatten;
          # inherit rootPath;
          unstable = inputs.unstable.legacyPackages.${system}; 
	  #import inputs.unstable { inherit config system; };


          latest = inputs.latest.legacyPackages.${system}; #import inputs.latest { inherit config system; }; #import inputs.nixos-2305 { inherit config system; };
          nixos-2311 = inputs.nixos-2311.legacyPackages.${system}; 
	  #import inputs.nixos-2311 { inherit config system; }; #import inputs.ghc-nixpkgs-unstable { inherit config system; };

          nixos-2211 = inputs.nixos-2211.legacyPackages.${system}; #import inputs.nixos-2211 { inherit config system; }; #import inputs.ghc-nixpkgs-unstable { inherit config system; };

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

          inherit (inputs.agenix-cli.packages.${system}) agenix-cli;
          inherit (latest) tailscale csvlens oxker;
          inherit (unstable) cachix/*nixVersions*/ eza mermaid-cli scrcpy yazi powerline-rs pwvucontrol gscan2pdf htmx-lsp/* for nixvim */ gtt nixd docker_25;
	  #inherit (nixos-2311) ;
          inherit (unstable.cudaPackages) cudatoolkit;
	  inherit (inputs.libreoffice-postscript.legacyPackages.${system}) libreoffice;

          # see https://github.com/NixOS/nixpkgs/issues/271989, I think this comes down to not having the correct udev rules in place
          # on the host os for the home-manager managed nix, thus on a non-nixos currently (release-23-11) there is no scanner
          # detected
          # simple-scan (v42.5) from nixos-22.11 seems to work with sane from arch linux
          # also simple-scan (v44.0) from nixos-23.11 does NOT seem to work with sane from arch linux
          # there is still the problem of crashing (https://github.com/NixOS/nixpkgs/issues/271991), which will not fixed for that v42.5 which would mean being stuck at it with oom bug, so maybe rather use arch linux' simple-scan also until the scanner missing bug (https://github.com/NixOS/nixpkgs/issues/271989) is sorted out as well.
          inherit (nixos-2211) simple-scan/*sane-backends*/; # nixos-23.11 Scanner not found

          #inherit (latest.xorg) libxcvt;

          #inherit (latest.python311Packages) bpython;

          #inherit (latest) nix-inspect;
	  nix-inspect = inputs.nix-inspect.packages.${system}.default;

          nvim-configured = inputs.nixvim-config.packages.${system}.default;

          bundixcli = inputs.bundix.packages.${system}.default;

          feedback = inputs.feedback.packages.${system}.default;

          #yazi = inputs.yazi.packages.${system}.default;

          firefox = inputs.firefox.packages.${system}.firefox-bin; #.unwrapped;

          # rustShell = inputs.rust-dev-template.devShells.${system}.default;

          talon = inputs.talon.packages.${system}.default;

          #nixd = inputs.nixd.packages.${system}.default;

          rime = inputs.rime.packages.${system}.default;

          nix-ld-rs = inputs.nix-ld-rs.packages.${system}.default;

          git-issue = inputs.git-issue;

          # FIXME is workaround until upstream has the PR accepted, see https://github.com/nix-community/NixOS-WSL/issues/262#issuecomment-1825648537
          wsl-vpnkit =
            let inherit (unstable)
              lib
              findutils
              pstree
              resholve
              wsl-vpnkit;
            in
            wsl-vpnkit.override {
              resholve =
                resholve
                // {
                  mkDerivation = attrs @ { solutions, ... }:
                    resholve.mkDerivation (lib.recursiveUpdate attrs {
                      src = inputs.wsl-vpnkit;
                      #src = fetchFromGitHub {
                      #  owner = "sakai135";
                      #  repo = "wsl-vpnkit";
                      #  rev = "28992229fedfa64979faa9ec84b1b4bcf5c8f449";
                      #  sha256 = "sha256-6VKFUoPAhVOmORTGELZu00SnGmYSbumPOZ64giWq14Q=";
                      #};

                      solutions.wsl-vpnkit = {
                        inputs =
                          solutions.wsl-vpnkit.inputs
                          ++ [
                            findutils
                            pstree
                          ];

                        execer =
                          solutions.wsl-vpnkit.execer
                          ++ [ "cannot:${pstree}/bin/pstree" ];
                      };
                    });
                };
            };

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

         ubootRaspberryPi2 = prev.ubootRaspberryPi2.overrideAttrs (oldAttrs: {
	 # see this for more https://discourse.nixos.org/t/rpi-zero-2w-in-prusa-3d-printer-aka-data-received-via-uart-over-gpio-disturbs-the-boot-process/36133/9
        extraConfig = ''
        '';
      });

          # fix pam-service in xsecurelock, see https://git.rauhala.info/MasseR/temp-fix-xsecurelock/commit/129fcc5eb285ece0f7c414b42bef6281fc4edc42
          # https://github.com/google/xsecurelock/issues/102#issuecomment-621432204
          xsecurelock =
            prev.xsecurelock.overrideAttrs
              # simply replacing the configureFlags rn
              (oldAttrs: { configureFlags = (remove "--with-pam-service-name=login" (flatten oldAttrs.configureFlags)) ++ [ "--with-pam-service-name=system_auth" ]; }); # if doesn't work, try --with-pam-service-name=authproto_pam here or ...=common_auth or ...system-local-login, https://github.com/google/xsecurelock/blob/8a448bd/README.md#installation and https://sourcegraph.com/search?q=context%3Aglobal+content%3A--with-pam-service-name&patternType=standard&sm=1&groupBy=repo

          # FIXME Remove when fixed in upstream nixvim
          #elixir_ls = let
          #  inherit (unstable) elixir-ls;
          #in elixir-ls;

          #yt-dlp =
          #  prev.yt-dlp.overrideAttrs
          #    (_: { src = inputs.yt-dlp; }); # > Checking runtime dependencies for yt_dlp-2024.5.27-py3-none-any.whl
                                              # >   - requests<3,>=2.32.2 not satisfied by version 2.31.0

          #python3Packages =
          #  prev.python311Packages
          #  // {
          #    inherit
          #      (nixos-2305.python311Packages) 
          #	ruff-lsp
          #	;
          #  };
          pup =
            let
              inherit (unstable) pup;
            in
            pup.overrideAttrs
              (_: { src = inputs.pup; });

          emacsPackages =
            prev.emacsPackages
            // {
              inherit
                (unstable.emacsPackages)
                mistty
                ;
            };
          cudaPackages =
            prev.cudaPackages
            // {
              inherit
                (unstable.cudaPackages)
                cudatoolkit
                ;
            };
          nixVersions =
            prev.nixVersions
            // {
              inherit
                (unstable.nixVersions)
                latest;
            };
          nodePackages =
            prev.nodePackages
            // {
              inherit
                (latest.nodePackages)
                bash-language-server
                vim-language-server
                vscode-json-languageserver-bin
                # mermaid-cli # at latest in top-level now
                ;
              #inherit
              #  (nixos-2305.nodePackages) 
              #	prettier_d_slim
              #	markdownlint-cli
              #	eslint_d
              #	;
            };

          gradle-vscode-extension =
            prev.vscode-extensions.vscjava
            // {
              inherit
                (latest.vscode-extensions.vscjava)
                vscode-gradle
                ;
            };

          vimUtils =
            prev.vimUtils
            // {
              inherit
                (unstable.vimUtils)
                buildVimPlugin
                ;
            };

          /*vimPlugins = let
                                 	    inherit (prev.vimPlugins) surround-nvim;
                         	  in  
                         	  prev.vimPlugins
                         	  // {
                                   	      surround = surround-nvim;
                       	  };*/

          vimPlugins =
            prev.vimPlugins
            // rec {
              inherit
                (unstable.vimPlugins)
                nvim-lspconfig
                nix-develop-nvim
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
                markid
                virtual-types-nvim
                gitsigns-nvim
                # FIXME remove when fixed in nixvim upstream
                #surround-nvim
                ;

              #surround = surround-nvim;
            };

          builtGrammars =
            prev.tree-sitter.builtGrammars
            // {
              inherit
                (unstable.tree-sitter.builtGrammars)
                tree-sitter-lua
                #tree-sitter-python
                tree-sitter-nix
                #tree-sitter-ruby
                #tree-sitter-vim
                #tree-sitter-json
                #tree-sitter-bash
                tree-sitter-comment
                tree-sitter-latex
                ;
            };

          vscode-extensions-new =
            (final.vscode-extensions.vscjava).overrideAttrs
              (_: { vscode-gradle = latest.vscode-extensions.vscjava.vscode-gradle; });

          # FIXME 2.2.2024, take this again if things went awe
          nvim-treesitter-full-latest =
            unstable.vimPlugins.nvim-treesitter.withAllGrammars;

          nvim-treesitter-full =
            (final.vimPlugins.nvim-treesitter.withAllGrammars).overrideAttrs
              (_: { src = inputs.nvim-treesitter; });

          nvim-treesitter-as-in-manual =
            unstable.vimPlugins.nvim-treesitter.withPlugins (
              plugins:
                with plugins; [
                  nix
                  latex
                  nix
                  comment
                  lua
                  json
                  bash
                  vim
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

          #inherit (inputs) sanemacs;

          # see https://sourcegraph.com/github.com/johnae/world@016fbbb0d64af7fc3963e2253e6dffada8d26cb5/-/blob/packages/overlays.nix?L78
          # better: https://sourcegraph.com/search?q=context:global+content:%22emacsWithPackagesFromUsePackage%22+file:%5E.*%5C.nix%24&patternType=standard&sm=1
          # TODO https://github.com/nix-community/emacs-overlay/issues/341#issuecomment-1605290875
          # TODO init.el ?
          # https://matrix.:to/#/!ZmUSesoOjmVsKbzFbp:nixos.org/$IvE50XOAU4T4eBJZfZtHoY7QaXfsDuEMGiuPcF-gKXA?via=nixos.org&via=matrix.org&via=tchncs.de
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
      # FIXME when to do this: https://github.com/jtojnar/nixfiles/blob/522466da4dd5206c7b444ba92c8d387eedf32a22/hosts/brian/profile.nix#L10-L12
      inputs.nixGL
      inputs.rust-overlay
      ###########inputs.emacs-overlay
      inputs.nixpkgs-ruby
      #	inputs.talon
      #       inputs.ocaml-overlay
      #inputs.nixpkgs-wayland
      inputs.neovim-nightly-overlay
    ])
    /*++ [
      #      inputs.tree-grepper.overlay."${system}"
      # DONT when enabling this overlay as in my setup it will start i. e. to build chromium-unwrapped for whatever reason for my nix-on-droid machine: inputs.ruby-nix.overlays.ruby # DONT do not enable TODO review my setup
      #inputs.ocaml-overlay.overlays."${system}"
    ]*/
    ++ inputs.nixpkgs.lib.optionals nixOnDroid [
      inputs.nix-on-droid.overlays.default
      # prevent uploads to remote builder
      (final: prev: prev.prefer-remote-fetch final prev)
    ];
}
