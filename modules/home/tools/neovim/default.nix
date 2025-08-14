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
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.nvim-config.packages.${pkgs.system}.default
    ];
    secrets. "neovim/tavily_api_key" = {};
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TAVILY_API_KEY = "$(cat ${config.sops.secrets."neovim/tavily_api_key".path})";
    };
  };
}
