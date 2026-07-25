{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }: {
    programs.yazi = {
      initLua = lib.mkAfter ''
        require("relative-motions"):setup({
          show_numbers = "relative",
          show_motion = true,
          only_motions = false,
        })
      '';

      keymap.mgr.prepend_keymap = map (n: {
        desc = "Move in relative steps";
        on = ["${toString n}"];
        run = ["plugin relative-motions ${toString n}"];
      }) (lib.range 1 9);

      plugins.relative-motions = pkgs.yaziPlugins.relative-motions;
    };
  };
}
