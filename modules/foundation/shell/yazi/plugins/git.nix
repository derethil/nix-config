{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }: {
    programs.yazi = {
      plugins.git = pkgs.yaziPlugins.git;

      settings.plugin.prepend_fetchers = [
        {
          id = "git";
          url = "*";
          run = "git";
          group = "git";
        }
        {
          id = "git";
          url = "*/";
          run = "git";
          group = "git";
        }
      ];

      initLua = lib.mkAfter ''
        th.git = th.git or {}
        th.git.updated_sign = ""
        th.git.modified_sign = ""
        th.git.added_sign = ""
        th.git.deleted_sign = ""
        th.git.ignored_sign = "󰊠"
        th.git.untracked_sign = ""
        require("git"):setup()
      '';
    };
  };
}
