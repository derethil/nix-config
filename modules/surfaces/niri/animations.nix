{
  flake.modules.homeManager.niri = let
    materialDesignDecelerate = {
      curve = ["cubic-bezier" 0.05 0.7 0.1 1.0];
      duration-ms = 100;
    };

    materialDesignAccelerate = {
      curve = ["cubic-bezier" 0.3 0.0 0.8 0.15];
      duration-ms = 75;
    };

    menuDecelerate = {
      curve = ["cubic-bezier" 0.1 1.0 0.0 1.0];
      duration-ms = 100;
    };
    #
    # menuAccelerate = {
    #   duration-ms = 100;
    #   curve = ["cubic-bezier" 0.38 0.04 1.0 0.07];
    # };
  in {
    wayland.windowManager.niri.settings.animations = {
      exit-confirmation-open-close = menuDecelerate;
      horizontal-view-movement = materialDesignDecelerate;
      overview-open-close = menuDecelerate;
      screenshot-ui-open = menuDecelerate;
      window-close = materialDesignAccelerate;
      window-movement = materialDesignDecelerate;
      window-open = materialDesignDecelerate;
      window-resize = materialDesignDecelerate;
      workspace-switch = menuDecelerate // {duration-ms = 300;};
    };
  };
}
