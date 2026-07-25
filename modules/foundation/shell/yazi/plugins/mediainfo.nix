{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      extraPackages = with pkgs; [
        ffmpeg
        ffmpegthumbnailer
        imagemagick
        mediainfo
      ];

      keymap.mgr.prepend_keymap = [
        {
          desc = "Toggle media preview metadata";
          on = ["<F9>"];
          run = ["plugin mediainfo -- toggle-metadata"];
        }
      ];

      plugins.mediainfo = pkgs.yaziPlugins.mediainfo;

      settings = {
        plugin = {
          prepend_preloaders = [
            {
              mime = "application/postscript";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
          ];

          prepend_previewers = [
            {
              mime = "application/postscript";
              run = "mediainfo";
            }
            {
              mime = "application/subrip";
              run = "mediainfo";
            }
            {
              mime = "{audio,video,image}/*";
              run = "mediainfo";
            }
          ];
        };

        tasks.image_alloc = 1073741824;
      };
    };
  };
}
