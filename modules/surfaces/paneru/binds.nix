{self, ...}: {
  flake.modules.darwin.paneru = {
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) listToAttrs range;

    mkVirtualNumBinds = mod: action:
      listToAttrs (map (i: {
          name = "window_virtual${action}_${toString i}";
          value = "${mod} - ${toString i}";
        })
        (range 1 9));
  in {
    imports = [self.modules.darwin.skhd];

    services.skhd.skhdConfig = let
      toggleScript = pkgs.writeShellScript "paneru-focus-toggle" ''
        STATE=/tmp/.paneru_focus_toggle
        if [ -f "$STATE" ]; then
          rm "$STATE"
          paneru send-cmd window focusunmanaged
        else
          touch "$STATE"
          paneru send-cmd window focusmanaged
        fi
      '';
    in "cmd - space : ${toggleScript}";

    # Note: paneru does not support mouse button bindings (no equivalent to niri's
    # Mod+MouseForward etc.). Would need skhd + BetterMouse or LinearMouse to
    # intercept mouse buttons and call `paneru send-cmd`.
    services.paneru.settings.bindings =
      {
        window_fullwidth = "alt - m";
        window_snap = "alt - c";
        window_manage = "alt + shift - space";

        window_focus_west = "alt - h";
        window_focus_east = "alt - l";
        window_focus_north = "alt - k";
        window_focus_south = "alt - j";
        window_focus_first = "alt - ,";
        window_focus_last = "alt - .";

        window_swap_west = "alt + shift - h";
        window_swap_east = "alt + shift - l";
        window_swap_north = "alt + shift - k";
        window_swap_south = "alt + shift - j";
        window_swap_first = "alt + shift - ,";
        window_swap_last = "alt + shift - .";
        window_stack = "alt + ctrl - h";
        window_unstack = "alt + ctrl - l";

        window_resize = "alt - r";
        window_shrink = "alt + shift - r";

        window_virtual_north = "alt - [";
        window_virtual_south = "alt - ]";
        window_virtualmove_north = "alt + shift - [";
        window_virtualmove_south = "alt + shift - ]";
      }
      // (mkVirtualNumBinds "alt" "num")
      // (mkVirtualNumBinds "alt + shift" "movenum");
  };
}
