{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      extraPackages = [pkgs.ouch];

      keymap.mgr.prepend_keymap = [
        {
          desc = "Compress with ouch";
          on = ["C"];
          run = ["plugin ouch"];
        }
      ];

      plugins.ouch = pkgs.yaziPlugins.ouch;

      settings.plugin.prepend_previewers = [
        {
          mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
          run = "ouch --archive-icon=''";
        }
      ];
    };
  };
}
