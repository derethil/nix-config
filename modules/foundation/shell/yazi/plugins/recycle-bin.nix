{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      programs.yazi = {
        extraPackages = [pkgs.trash-cli];

        initLua = lib.mkAfter ''
          require("recycle-bin"):setup()
        '';

        keymap.mgr.prepend_keymap = [
          {
            desc = "Open Trash menu";
            on = ["T"];
            run = ["plugin recycle-bin"];
          }
        ];

        plugins.recycle-bin = pkgs.yaziPlugins.recycle-bin;
      };
    };
}
