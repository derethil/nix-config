{
  flake.modules.darwin.paneru = {
    services.paneru.settings = {
      restore = {
        enabled = false;
        missing_windows = "ignore";
        startup_grace_ms = 2000;
      };

      windows.alacritty = {
        bindings_passthrough = ["ctrl-h" "ctrl-j" "ctrl-k" "ctrl-l"];
        bundle_id = "org.alacritty";
        title = ".*";
      };
    };
  };
}
