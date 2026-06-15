{
  flake.modules.darwin.login = {
    system.defaults = {
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 15;
      };

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };
    };
  };
}
