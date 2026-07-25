{
  flake.modules.darwin.login = {
    system.defaults = {
      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 15;
      };
    };
  };
}
