{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.tools.neovim;
in {
  options.tools.neovim = {
    enable = mkBoolOpt false "Whether to enable Neovim.";
  };

  config = mkIf cfg.enable {
    programs.nvim-config = {
      enable = true;
      neovim = {
        defaultEditor = true;
        nightly = false;
      };
      claude = {
        enable = true;
        package = pkgs.claude-code;
      };
    };
  };
}
