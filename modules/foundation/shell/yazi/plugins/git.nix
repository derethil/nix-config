{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }: {
    programs.yazi = {
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

      plugins.git = pkgs.yaziPlugins.git;

      settings.plugin.prepend_fetchers = [
        {
          group = "git";
          id = "git";
          run = "git";
          url = "*";
        }
        {
          group = "git";
          id = "git";
          run = "git";
          url = "*/";
        }
      ];
    };
  };
}
