let
  appIdMatch = appId: {_props.app-id._raw = ''r#"${appId}"#'';};
  appIdMatches = appIds:
    map appIdMatch (
      if builtins.isList appIds
      then appIds
      else [appIds]
    );
in {
  flake.lib.niri-rules = {
    floatRule = appIds: {
      match = appIdMatches appIds;
      open-floating = true;
    };

    fullscreenRule = appIds: {
      match = appIdMatches appIds;
      open-focused = true;
      open-fullscreen = true;
    };

    hideRule = pairs: {
      block-out-from = "screen-capture";

      match =
        map (p: {
          _props = {
            inherit (p) title;
            app-id._raw = ''r#"${p.appId}"#'';
          };
        })
        pairs;
    };

    sizedFloatRule = appIds: w: h: {
      default-column-width.fixed = w;
      default-window-height.fixed = h;
      match = appIdMatches appIds;
      open-floating = true;
    };

    tileRule = appIds: {
      match = appIdMatches appIds;
      open-floating = false;
      tiled-state = true;
    };

    widthRule = appIds: widthConfig: {
      default-column-width = widthConfig;
      match = appIdMatches appIds;
    };

    workspaceRule = workspace: appIds: {
      match = appIdMatches appIds;
      open-focused = true;
      open-on-workspace = toString workspace;
    };
  };
}
