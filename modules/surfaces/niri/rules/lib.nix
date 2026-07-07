{...}: let
  appIdMatch = appId: {_props.app-id._raw = ''r#"${appId}"#'';};
  appIdMatches = appIds:
    map appIdMatch (
      if builtins.isList appIds
      then appIds
      else [appIds]
    );
in {
  flake.lib.niri-rules = {
    workspaceRule = workspace: appIds: {
      match = appIdMatches appIds;
      open-on-workspace = toString workspace;
      open-focused = true;
    };

    fullscreenRule = appIds: {
      match = appIdMatches appIds;
      open-fullscreen = true;
      open-focused = true;
    };

    floatRule = appIds: {
      match = appIdMatches appIds;
      open-floating = true;
    };

    sizedFloatRule = appIds: w: h: {
      match = appIdMatches appIds;
      open-floating = true;
      default-column-width.fixed = w;
      default-window-height.fixed = h;
    };

    tileRule = appIds: {
      match = appIdMatches appIds;
      open-floating = false;
      tiled-state = true;
    };

    widthRule = appIds: widthConfig: {
      match = appIdMatches appIds;
      default-column-width = widthConfig;
    };

    hideRule = pairs: {
      match =
        map (p: {
          _props = {
            app-id._raw = ''r#"${p.appId}"#'';
            inherit (p) title;
          };
        })
        pairs;
      block-out-from = "screen-capture";
    };
  };
}
