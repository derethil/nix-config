{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.mediainfo;
in {
  options.glace.cli.yazi.plugins.mediainfo = {
    enable = mkBoolOpt true "Whether to enable mediainfo plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) mediainfo;
      };

      settings = {
        plugin = {
          prepend_preloaders = [
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            {
              mime = "application/postscript";
              run = "mediainfo";
            }
          ];

          prepend_previewers = [
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            {
              mime = "application/postscript";
              run = "mediainfo";
            }
          ];
        };

        tasks.image_alloc = 1073741824;
      };

      keymap.mgr.prepend_keymap = [
        {
          on = ["<F9>"];
          run = ["plugin mediainfo -- toggle-metadata"];
          desc = "Toggle media preview metadata";
        }
      ];

      extraPackages = [
        pkgs.mediainfo
        pkgs.imagemagick
        pkgs.ffmpeg
        pkgs.ffmpegthumbnailer
      ];
    };
  };
}
