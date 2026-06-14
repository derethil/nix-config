{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.ouch = pkgs.yaziPlugins.ouch;

      settings.plugin.prepend_previewers = [
        {
          mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
          run = "ouch --archive-icon=''";
        }
      ];

      keymap.mgr.prepend_keymap = [
        {
          on = ["C"];
          run = ["plugin ouch"];
          desc = "Compress with ouch";
        }
      ];

      extraPackages = [pkgs.ouch];
    };
  };
}
