{
  flake.modules.darwin.paneru = {
    services.paneru.settings = {
      restore = {
        enabled = false;
        startup_grace_ms = 2000;
        missing_windows = "ignore";
      };

      windows.alacritty = {
        title = ".*";
        bundle_id = "org.alacritty";
        bindings_passthrough = ["ctrl-h" "ctrl-l" "ctrl-j" "ctrl-k"];
      };
    };
  };
}
