{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.mediainfo = pkgs.yaziPlugins.mediainfo;

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

      extraPackages = with pkgs; [
        mediainfo
        imagemagick
        ffmpeg
        ffmpegthumbnailer
      ];
    };
  };
}
