{
  flake.modules.homeManager.niri = let
    materialDesignDecelerate = {
      duration-ms = 100;
      curve = ["cubic-bezier" 0.05 0.7 0.1 1.0];
    };

    materialDesignAccelerate = {
      duration-ms = 75;
      curve = ["cubic-bezier" 0.3 0.0 0.8 0.15];
    };

    menuDecelerate = {
      duration-ms = 100;
      curve = ["cubic-bezier" 0.1 1.0 0.0 1.0];
    };
    #
    # menuAccelerate = {
    #   duration-ms = 100;
    #   curve = ["cubic-bezier" 0.38 0.04 1.0 0.07];
    # };
  in {
    wayland.windowManager.niri.settings.animations = {
      exit-confirmation-open-close = menuDecelerate;
      screenshot-ui-open = menuDecelerate;

      horizontal-view-movement = materialDesignDecelerate;
      overview-open-close = menuDecelerate;

      window-open = materialDesignDecelerate;
      window-close = materialDesignAccelerate;
      window-movement = materialDesignDecelerate;
      window-resize = materialDesignDecelerate;
      workspace-switch = menuDecelerate // {duration-ms = 300;};
    };
  };
}
