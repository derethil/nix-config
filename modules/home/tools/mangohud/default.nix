{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.mangohud;
in {
  options.glace.tools.mangohud = {
    enable = mkBoolOpt false "Whether to enable MangoHud.";
  };

  config = mkIf cfg.enable {
    programs.mangohud = {
      enable = true;
      settings = {
        # Start with HUD disabled
        no_display = true;

        # Toggle keybind (Shift_R+F12)
        toggle_hud = "Shift_R+F12";

        # Basic HUD elements
        fps = true;
        frametime = true;
        cpu_temp = true;
        gpu_temp = true;
        ram = true;
        vram = true;

        # Position and appearance
        position = "top-left";
        background_alpha = 0.5;
        font_size = 24;
      };
    };
  };
}
