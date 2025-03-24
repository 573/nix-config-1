{
  config,
  lib,
  inputs,
  pkgs,
  unstable,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.custom.programs.helix;

  # i. e. nix-repl> :p (homeConfigurations."dani@maiziedemacchiato".pkgs.vimUtils.buildVimPluginFrom2Nix { pname = "markid"; src = inputs.markid; version = inputs.markid.rev; }).drvAttrs
  #	  pluggo = name: pkgs.vimUtils.buildVimPlugin {
  #	    pname = name;
  #	    src = inputs."${name}";
  #	    version = "2023-20-10";
  #	  };

in
{

  ###### interface

  options = {
    custom.programs.helix = {

      enable = mkEnableOption "helix config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final helix.
        '';
      };

    };

  };

  ###### implementation

  # TODO https://discourse.nixos.org/t/default-options-aren-t-applied/35402
  # NOTE I think important https://github.com/helix-editor/helix/issues/2573#issuecomment-1309735155
  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      defaultEditor = true;
      extraPackages = builtins.attrValues {
        inherit (pkgs)
          # language servers / formatters
          nil
          nixd
          nixfmt-rfc-style
          taplo
          lua-language-server
          shellcheck
          vscode-langservers-extracted
          marksman
          bash-language-server
          ;
      };

      package = unstable.helix;

      ignores = [
        ".build/"
        "!.gitignore"
      ];

      languages = {
        # the language-server option currently requires helix from the master branch at https://github.com/helix-editor/helix/
        language-server.nixd = {
          command = "nixd";
          args = [
            "--inlay-hints=true"
            "--semantic-tokens=true"
	    "--nixpkgs-worker-stderr=~/.cache/helix/nixpkgs-worker.log"
            "--option-worker-stderr=~/.cache/helix"
          ];
          formatting.command = [ "nixfmt" ];
          config.nixd =
            let
              flake = ''(builtins.getFlake "${inputs.self}")'';
              nixosOptions = "${flake}.nixosConfigurations.DANIELKNB1.options";
            in
            {
              nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
              options = {
                nixos.expr = nixosOptions;
                # as in https://github.com/nix-community/NixOS-WSL/blob/d34d9412556d3a896e294534ccd25f53b6822e80/modules/wsl-conf.nix#L21
                nixos-wsl.expr = "${nixosOptions}.wsl.wslConf.type.getSubOptions [ ]";
                # as in https://github.com/nix-community/home-manager/blob/e8c19a3cec2814c754f031ab3ae7316b64da085b/nixos/common.nix#L112
                home-manager.expr = "${nixosOptions}.home-manager.users.type.getSubOptions [ ]";
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

        language = [
          {
            name = "nix";
            formatter.command = "nixfmt";
            auto-format = true;
            language-servers = [ "nixd" ];
          }
        ];
      };
      settings = {
        keys.normal = {
          X = "extend_line_above";
          C-h = "jump_view_left";
          C-j = "jump_view_down";
          C-k = "jump_view_up";
          C-l = "jump_view_right";
          C-r = ":reload";
        };
        editor = {
          shell = [
            "bash"
            "-c"
          ];
          cursorline = true;
          cursorcolumn = true;
          color-modes = true;
          file-picker.hidden = true;
          line-number = "relative";
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
          soft-wrap.enable = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          statusline = {
            left = [
              "mode"
              "spinner"
              "file-type"
              "diagnostics"
            ];
            center = [ "file-name" ];
            right = [
              "selections"
              "position"
              "separator"
              "spacer"
              "position-percentage"
            ];
            separator = "|";
          };
          indent-guides = {
            render = true;
            skip-levels = 1;
          };
        };
      };
    };
  };
}
