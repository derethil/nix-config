{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; {
  options.apps.insomnia = {
    enable = mkBoolOpt false "Whether to enable Insomnia.";
  };

  config = mkIf config.apps.insomnia.enable {
    home.packages = with pkgs; [
      insomnia
    ];
  };
}
