{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.glace) mkBoolOpt;
  inherit (pkgs.stdenv) hostPlatform;
  cfg = config.glace.apps.spotify;
in {
  options.glace.apps.spotify = {
    enable = mkBoolOpt false "Whether to enable Spotify";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        pkgs.spotify
      ];
    }

    (mkIf hostPlatform.isDarwin {
      home.activation.disableSpotifyUpdates = lib.hm.dag.entryAfter ["writeBoundary"] ''
        SPOTIFY_UPDATE_DIR=~/Library/Application\ Support/Spotify/PersistentCache/Update
        if ! /usr/bin/stat -f "%Sf" "$SPOTIFY_UPDATE_DIR" 2> /dev/null | grep -q uchg; then
          rm -rf "$SPOTIFY_UPDATE_DIR"
          mkdir -p "$SPOTIFY_UPDATE_DIR"
          /usr/bin/chflags uchg "$SPOTIFY_UPDATE_DIR"
        fi
      '';
    })
  ]);
}
