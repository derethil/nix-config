{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }: {
    programs.yazi = {
      plugins.relative-motions = pkgs.yaziPlugins.relative-motions;

      keymap.mgr.prepend_keymap = map (n: {
        on = ["${toString n}"];
        run = ["plugin relative-motions ${toString n}"];
        desc = "Move in relative steps";
      }) (lib.range 1 9);

      initLua = lib.mkAfter ''
        require("relative-motions"):setup({
          show_numbers = "relative",
          show_motion = true,
          only_motions = false,
        })
      '';
    };
  };
}
