{
  config,
  lib,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.cli.zoxide;
in {
  options.glace.cli.zoxide = {
    enable = mkBoolOpt false "Whether to enable zoxide.";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
    };
  };
}
