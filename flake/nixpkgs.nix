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
	  inherit (prev.lib.attrsets) genAttrs;
          # inherit rootPath;
          unstable = inputs.unstable.legacyPackages.${system}; 
	  #import inputs.unstable { inherit config system; };


          latest = inputs.latest.legacyPackages.${system}; #import inputs.latest { inherit config system; }; #import inputs.nixos-2305 { inherit config system; };
          nixos-2311 = inputs.nixos-2311.legacyPackages.${system}; 
	  #import inputs.nixos-2311 { inherit config system; }; #import inputs.ghc-nixpkgs-unstable { inherit config system; };

#          nixos-2211 = inputs.nixos-2211.legacyPackages.${system}; #import inputs.nixos-2211 { inherit config system; }; #import inputs.ghc-nixpkgs-unstable { inherit config system; };

          # TODO https://github.com/onekey-sec/unblob/blob/4e900ff/flake.nix#L21
          moreOverlays =
            (map (x: x.overlays.default) [
              inputs.ocaml-overlay # see i. e. https://github.com/nix-ocaml/nix-overlays/blob/51c3d87/README.md#alternative-advanced
            ])
          ;

        in
        {
          inherit (latest) csvlens;
          inherit (unstable) tailscale oxker cachix/*nixVersions*/ eza mermaid-cli scrcpy yazi powerline-rs pwvucontrol gscan2pdf htmx-lsp/* for nixvim */ gtt nixd docker_25;
	  #inherit (nixos-2311) ;
          inherit (unstable.cudaPackages) cudatoolkit;
	  inherit (inputs.libreoffice-postscript.legacyPackages.${system}) libreoffice;

          # see https://github.com/NixOS/nixpkgs/issues/271989, I think this comes down to not having the correct udev rules in place
          # on the host os for the home-manager managed nix, thus on a non-nixos currently (release-23-11) there is no scanner
          # detected
          # simple-scan (v42.5) from nixos-22.11 seems to work with sane from arch linux
          # also simple-scan (v44.0) from nixos-23.11 does NOT seem to work with sane from arch linux
          # there is still the problem of crashing (https://github.com/NixOS/nixpkgs/issues/271991), which will not fixed for that v42.5 which would mean being stuck at it with oom bug, so maybe rather use arch linux' simple-scan also until the scanner missing bug (https://github.com/NixOS/nixpkgs/issues/271989) is sorted out as well.
#          inherit (nixos-2211) simple-scan/*sane-backends*/; # nixos-23.11 Scanner not found

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

        # TODO https://matrix.to/#/!RRerllqmbATpmbJgCn:nixos.org/$mP53sN976wEgmMCKeM5JWPABO1lh17x7ucXtgKp1cWY?via=nixos.org&via=matrix.org&via=tchncs.de https://nixpk.gs/pr-tracker.html?pr=239005 (https://discourse.nixos.org/t/a-nixpkgs-pr-tracker-with-pure-front-end/50096)

          # fix pam-service in xsecurelock, see https://git.rauhala.info/MasseR/temp-fix-xsecurelock/commit/129fcc5eb285ece0f7c414b42bef6281fc4edc42
          # https://github.com/google/xsecurelock/issues/102#issuecomment-621432204
          xsecurelock =
            prev.xsecurelock.overrideAttrs
              # simply replacing the configureFlags rn
              (oldAttrs: { configureFlags = (remove "--with-pam-service-name=login" (flatten oldAttrs.configureFlags)) ++ [ "--with-pam-service-name=system_auth" ]; }); # if doesn't work, try --with-pam-service-name=authproto_pam here or ...=common_auth or ...system-local-login, https://github.com/google/xsecurelock/blob/8a448bd/README.md#installation and https://sourcegraph.com/search?q=context%3Aglobal+content%3A--with-pam-service-name&patternType=standard&sm=1&groupBy=repo

          #yt-dlp =
          #  prev.yt-dlp.overrideAttrs
          #    (_: { src = inputs.yt-dlp; }); # > Checking runtime dependencies for yt_dlp-2024.5.27-py3-none-any.whl
                                              # >   - requests<3,>=2.32.2 not satisfied by version 2.31.0

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
          # DONE [gist] For later ref - override to i. e. nix_2_13 - see https://github.com/Gerschtli/nix-config/commit/da486994d122eb4e64a8b7940e9ef3469b44e06c#diff-3bcbef26c40d018f46094799af27a3698c921aa094bb2bffdaac77266c90ec21L64
          nixVersions =
            prev.nixVersions
            // {
              inherit
                (unstable.nixVersions)
                latest;
            };

          vimUtils =
            prev.vimUtils
            // {
              inherit
                (unstable.vimUtils)
                buildVimPlugin
                ;
            };


          somemore = prev.lib.composeManyExtensions moreOverlays final prev;

          firefox = inputs.firefox.packages.${system}.firefox-bin;

          # the only alias that I need, this allows me to set allowAliases=false
          inherit
            system
            # rootPath

            ;
        } // genAttrs [ "nix-inspect" "nixvim-config" "bundix" "talon" "devenv" ] (name: inputs.${name}.packages.${system}.default))
    ] ++ (map (x: x.overlays.default) [
      # FIXME when to do this: https://github.com/jtojnar/nixfiles/blob/522466da4dd5206c7b444ba92c8d387eedf32a22/hosts/brian/profile.nix#L10-L12
      inputs.nixGL
#      inputs.rust-overlay
      inputs.nixpkgs-ruby
      inputs.neovim-nightly-overlay
    ])
    ++ inputs.nixpkgs.lib.optionals nixOnDroid [
      inputs.nix-on-droid.overlays.default
      # prevent uploads to remote builder
      (final: prev: prev.prefer-remote-fetch final prev)
    ];
}
