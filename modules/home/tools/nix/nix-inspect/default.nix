{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;

  cfg = config.glace.tools.nix.nix-inspect;
in {
  options.glace.tools.nix.nix-inspect = {
    enable = mkBoolOpt false "Whether to enable nix-inspect for package/file searching.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.nix-inspect];
  };
}
