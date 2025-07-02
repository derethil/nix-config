{
  config,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.zoxide;
in {
  options.cli.zoxide = {
    enable = mkBoolOpt false "Whether to enable zoxide.";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
    };
  };
}
