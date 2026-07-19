{lib, ...}: {
  flake.lib.mkYaziApplication = {
    config,
    pkgs,
    flavor,
    yaziConfig,
    openToPath ? "",
    icon ? "file-manager",
    name ? "Yazi [${flavor}]",
    genericName ? "File Manager",
    comment ? "Open Yazi file manager",
    mimeType ? [],
  }: let
    mkYaziSymlink = p: config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/yazi/${p}";

    yaziConfigPath = "${config.xdg.configHome}/${flavor}";

    launchScript = pkgs.writeShellScript "${flavor}-launch" ''
      exec ${lib.getExe pkgs.xdg-terminal-exec} --app-id=yazi env YAZI_CONFIG_HOME=${yaziConfigPath} yazi${lib.optionalString (openToPath != "") " ${lib.escapeShellArg openToPath}"}
    '';
  in {
    xdg = {
      configFile = {
        "${flavor}/yazi.toml".text = yaziConfig;
        "${flavor}/init.lua".source = mkYaziSymlink "init.lua";
        "${flavor}/keymap.toml".source = mkYaziSymlink "keymap.toml";
        "${flavor}/theme.toml".source = mkYaziSymlink "theme.toml";
        "${flavor}/plugins".source = mkYaziSymlink "plugins";
        "${flavor}/flavors".source = mkYaziSymlink "flavors";
      };

      desktopEntries = {
        "${flavor}" =
          {
            inherit icon name genericName comment;
            type = "Application";
            categories = ["System" "FileTools" "FileManager"];
            exec = "${launchScript}";
          }
          // lib.optionalAttrs (mimeType != []) {inherit mimeType;};
      };
    };
  };
}
