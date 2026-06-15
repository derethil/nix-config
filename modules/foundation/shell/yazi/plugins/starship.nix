{
  flake.modules.homeManager.yazi = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.yazi = {
      plugins.starship = pkgs.yaziPlugins.starship;

      initLua = lib.mkAfter ''
        require("starship"):setup({
          config_file = "${config.programs.starship.configPath}"
        })
      '';
    };
  };
}
