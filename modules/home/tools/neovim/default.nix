{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.neovim;
in {
  options.tools.neovim = {
    enable = mkBoolOpt false "Whether to enable Neovim.";
    variant = mkOpt (types.enum ["nvf" "vanilla"]) "nvf" "Which Neovim variant to use: 'nvf' for configured nvim-config flake, 'vanilla' for standard neovim.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (
        if cfg.variant == "nvf"
        then inputs.nvim-config.packages.${pkgs.system}.default
        else neovim
      )
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
