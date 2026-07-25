{
  flake.modules.homeManager.yazi = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.yazi = {
      initLua = lib.mkAfter ''
        require("starship"):setup({
          config_file = "${config.programs.starship.configPath}"
        })
      '';

      plugins.starship = pkgs.yaziPlugins.starship;
    };
  };
}
