{ config
, lib
, inputs
, pkgs
, unstable
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
    ;
    inherit
      (pkgs.nodePackages)
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
		args = ["--inlay-hints" "--semantic-tokens"];
          config.nixd =
        let
            flake = ''(builtins.getFlake "${inputs.self}")'';
       #     system = ''''${builtins.currentSystem}'';
        in
	  {
	    nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
            options.home-manager.expr = "${flake}.nixosConfigurations.DANIELKNB1.options.home-manager.users.type.getSubOptions [ ]";
	  };
	};

  language = [{
            name = "nix";
            formatter.command = "nixfmt";
	language-servers = [ "nixd" ];
  }];
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
