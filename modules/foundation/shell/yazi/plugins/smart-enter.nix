{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }: {
    programs.yazi = {
      initLua = lib.mkAfter ''
        require("smart-enter"):setup({
          open_multi = true,
        })
      '';

      keymap.mgr.prepend_keymap = [
        {
          desc = "Enter the child directory, or open the file";
          on = ["l"];
          run = ["plugin smart-enter"];
        }
      ];

      plugins.smart-enter = pkgs.yaziPlugins.smart-enter;
    };
  };
}
