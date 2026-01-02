{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.nix-your-shell;
in {
  options.glace.cli.nix-your-shell = {
    enable = mkBoolOpt true "Whether to enable nix-your-shell.";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.nix-your-shell
    ];

    programs.fish = {
      interactiveShellInit = mkAfter ''
        nix-your-shell fish | source
      '';
    };
  };
}
