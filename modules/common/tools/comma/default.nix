{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.comma;
in {
  options.glace.tools.comma = {
    enable = mkBoolOpt false "Whether to enable Comma, a tool to run software without installing it.";
  };

  config = mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
  };
}
