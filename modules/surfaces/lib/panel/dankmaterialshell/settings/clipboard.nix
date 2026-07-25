{
  flake.modules.homeManager.dankmaterialshell-panel = {
    programs.dank-material-shell.clipboardSettings = {
      autoClearDays = 7;
      clearAtStartup = false;
      disabled = false;
      maxEntrySize = 5242880;
      maxHistory = 10000;
    };
  };
}
