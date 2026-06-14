{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      programs.yazi = {
        plugins.recycle-bin = pkgs.yaziPlugins.recycle-bin;

        initLua = lib.mkAfter ''
          require("recycle-bin"):setup()
        '';

        keymap.mgr.prepend_keymap = [
          {
            on = ["T"];
            run = ["plugin recycle-bin"];
            desc = "Open Trash menu";
          }
        ];

        extraPackages = [pkgs.trash-cli];
      };
    };
}
