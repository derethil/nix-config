{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkAfter getExe;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.nix-shell-fix;
in {
  options.glace.cli.nix-shell-fix = {
    enable = mkBoolOpt true "Whether to enable user shells when using nix-shell commands.";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      interactiveShellInit = mkAfter ''
        ${getExe pkgs.any-nix-shell} fish --info-right | source
      '';
    };
  };
}
