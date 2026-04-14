{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf optionalString types;
  inherit (lib.glace) mkBoolOpt mkNullableOpt;
  cfg = config.glace.tools.gaming.mangohud;
in {
  options.glace.tools.gaming.mangohud = {
    enable = mkBoolOpt false "Whether to enable MangoHud.";
    coolantSensor = mkNullableOpt types.str null "Path to hwmon temp input for coolant display, e.g. /sys/class/hwmon/hwmon6/temp2_input";
  };

  config = mkIf cfg.enable {
    programs.mangohud.enable = true;

    xdg.configFile."MangoHud/MangoHud.conf".text = ''
      no_display=true
      legacy_layout=false
      pci_dev=0000:03:00.0
      table_columns=4


      custom_text_center=-------- CPU Information --------

      cpu_stats
      cpu_temp
      cpu_mhz

      cpu_load_color
      core_load_change
      core_load
      core_bars

      custom_text=
      custom_text_center=-------- GPU Information --------

      gpu_stats
      gpu_core_clock
      gpu_temp

      custom_text=

      vram
      proc_vram

      custom_text=
      fps
      fps_text=AVG
      fps_color_change
      fps_metrics=0.01
      frame_timing

      custom_text=
      custom_text_center=------ System Information -------

      ${optionalString (cfg.coolantSensor != null) ''
        custom_text=CLT
        exec=awk '{printf "%.0f°C", $1/1000}' ${cfg.coolantSensor}
      ''}

      custom_text=
      ram
      procmem
      procmem_shared
      swap
      custom_text=


      # Keybinds
      toggle_hud=Shift_R+F12
      toggle_hud_position=Shift_R+F11
      toggle_logging=Shift_L+F2
      toggle_fps_limit=Shift_L+F1
      fps_limit_method=late

      # Appearance
      position=top-left
      font_size=24
      font_size_secondary=22
      round_corners=6
      background_alpha=0.5

      # Colors
      background_color=000000
      text_color=ffffff
      frametime_color=00ff00
      gpu_color=2e9762
      cpu_color=2e97cb
      vram_color=ad64c1
      ram_color=c26693
      wine_color=eb5b5b
      engine_color=eb5b5b
      media_player_color=ffffff
      network_color=e07b85
      battery_color=92e79a

      # FPS thresholds
      # nevermind fps_value only supports 2 values
      # fps_value=30,45,60,75,90
      # fps_color=cc0000,ff8e2b,d6b302,dbf246,6bf246,0e8c12

      # Load thresholds
      gpu_load_value=60,90
      gpu_load_color=92e79a,ffaa7f,cc0000
      cpu_load_value=60,90
      cpu_load_color=92e79a,ffaa7f,cc0000

      # Media
      media_player_format={title};{artist};{album}
    '';
  };
}
