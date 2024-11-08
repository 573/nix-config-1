{
  inputs,
  rootPath,
  system,
  pkgsSet ? inputs.nixpkgs,
  nixOnDroid ? false,
  config ? {
    # FIXME https://discourse.nixos.org/t/unexpected-11h-build-after-auto-update/39907/9
    allowAliases = false;
    allowUnfreePredicate =
      pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) [
        "nvidia-x11"
        "google-chrome"
      ];
  },
}:
import pkgsSet {
  inherit config system rootPath;
  overlays =
    [
      #inputs.rust-overlay.overlays.default # now commented out due to:  error: attribute 'rust-analyzer' missing https://github.com/573/nix-config-1/actions/runs/4923802480/jobs/8796067915#step:6:826 # rustc still 1.64 when building as opposed to nix shell 1.67
      #(import inputs.rust-overlay)
      (
        final: prev:
        let
          inherit (prev.stdenv.hostPlatform) system;
          inherit (prev.lib.attrsets) genAttrs;
          # inherit rootPath;
          #unstable = inputs.unstable.legacyPackages.${system}; 
          #import inputs.unstable { inherit config system; };

          #import inputs.nixos-2311 { inherit config system; }; #import inputs.ghc-nixpkgs-unstable { inherit config system; };

          #          nixos-2211 = inputs.nixos-2211.legacyPackages.${system}; #import inputs.nixos-2211 { inherit config system; }; #import inputs.ghc-nixpkgs-unstable { inherit config system; };
          # TODO https://github.com/onekey-sec/unblob/blob/4e900ff/flake.nix#L21
          moreOverlays = (
            map (x: x.overlays.default) [
              inputs.ocaml-overlay # see i. e. https://github.com/nix-ocaml/nix-overlays/blob/51c3d87/README.md#alternative-advanced
            ]
          );
        in
        {
          # see https://github.com/NixOS/nixpkgs/issues/271989, I think this comes down to not having the correct udev rules in place
          # on the host os for the home-manager managed nix, thus on a non-nixos currently (release-23-11) there is no scanner
          # detected
          # simple-scan (v42.5) from nixos-22.11 seems to work with sane from arch linux
          # also simple-scan (v44.0) from nixos-23.11 does NOT seem to work with sane from arch linux
          # there is still the problem of crashing (https://github.com/NixOS/nixpkgs/issues/271991), which will not fixed for that v42.5 which would mean being stuck at it with oom bug, so maybe rather use arch linux' simple-scan also until the scanner missing bug (https://github.com/NixOS/nixpkgs/issues/271989) is sorted out as well.
          #          inherit (nixos-2211) simple-scan/*sane-backends*/; # nixos-23.11 Scanner not found

          git-issue = inputs.git-issue;

          /*
            openai-whisper =
            let
              inherit (latest) openai-whisper;
            in
            openai-whisper.override {
              torch = prev.python3.pkgs.torch-bin;
            };
          */

          # TODO https://matrix.to/#/!RRerllqmbATpmbJgCn:nixos.org/$mP53sN976wEgmMCKeM5JWPABO1lh17x7ucXtgKp1cWY?via=nixos.org&via=matrix.org&via=tchncs.de https://nixpk.gs/pr-tracker.html?pr=239005 (https://discourse.nixos.org/t/a-nixpkgs-pr-tracker-with-pure-front-end/50096)

          #yt-dlp =
          #  prev.yt-dlp.overrideAttrs
          #    { src = inputs.yt-dlp; }; # > Checking runtime dependencies for yt_dlp-2024.5.27-py3-none-any.whl
          # >   - requests<3,>=2.32.2 not satisfied by version 2.31.0

          # DONE [gist] For later ref - override to i. e. nix_2_13 - see https://github.com/Gerschtli/nix-config/commit/da486994d122eb4e64a8b7940e9ef3469b44e06c#diff-3bcbef26c40d018f46094799af27a3698c921aa094bb2bffdaac77266c90ec21L64
          /*
            nixVersions =
            prev.nixVersions
            // {
              inherit
                (unstable.nixVersions)
                latest;
            };
          */
          inherit (inputs.unstable.legacyPackages.${system}) nixos-facter;
          /*
            vimUtils =
            prev.vimUtils
            // {
              inherit
                (unstable.vimUtils)
                buildVimPlugin
                ;
            };
          */

          desed = final.callPackage "${rootPath}/drvs/desed" { };

          devenv = inputs.devenv.packages.${system}.devenv;

          somemore = prev.lib.composeManyExtensions moreOverlays final prev;

          firefox = inputs.firefox.packages.${system}.firefox-bin;

          # the only alias that I need, this allows me to set allowAliases=false
          inherit
            system
            # rootPath

            ;
        }
        // genAttrs [
          "bundix"
          "talon"
          "devenv"
          "zen-browser"
        ] (name: inputs.${name}.packages.${system}.default)
      )
    ]
    ++ (map (x: x.overlays.default) [
      # FIXME when to do this: https://github.com/jtojnar/nixfiles/blob/522466da4dd5206c7b444ba92c8d387eedf32a22/hosts/brian/profile.nix#L10-L12
      inputs.nixGL
      #inputs.rust-overlay
      inputs.nixpkgs-ruby
#      inputs.neovim-nightly-overlay
      inputs.deploy-rs
    ])
    ++ [
      (_final: prev: {
        # https://discourse.nixos.org/t/overriding-torch-with-torch-bin-for-all-packages/37086/2
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (py-final: _py-prev: {
            torch = py-final.torch-bin;
          })
        ];
      })
      (self: super: { deploy-rs = { inherit (pkgsSet.legacyPackages.${super.stdenv.hostPlatform.system}) deploy-rs; lib = super.deploy-rs.lib; }; })
    ]
    ++ inputs.nixpkgs.lib.optionals nixOnDroid [
      inputs.nix-on-droid.overlays.default
      # prevent uploads to remote builder, https://ryantm.github.io/nixpkgs/functions/prefer-remote-fetch
      (final: prev: prev.prefer-remote-fetch final prev)
    ];
}
