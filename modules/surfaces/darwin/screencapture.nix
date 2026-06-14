{
  flake.modules.darwin.screencapture = {
    system.defaults.screencapture = {
      include-date = true;
      target = "preview";
    };
  };
}
