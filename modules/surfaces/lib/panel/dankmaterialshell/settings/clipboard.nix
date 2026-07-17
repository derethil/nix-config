{
  flake.modules.homeManager.dankmaterialshell-panel = {
    programs.dank-material-shell.clipboardSettings = {
      maxHistory = 10000;
      maxEntrySize = 5242880;
      autoClearDays = 7;
      clearAtStartup = false;
      disabled = false;
    };
  };
}
