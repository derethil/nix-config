{
  flake.modules.homeManager.spotify = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.spotify];

    # Spotify's auto-updater can break the macOS app sandbox. Locking the Update
    # directory with `chflags uchg` prevents Spotify from writing into it.
    home.activation.disableSpotifyUpdates = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      config.lib.dag.entryAfter ["writeBoundary"] ''
        SPOTIFY_UPDATE_DIR="${config.home.homeDirectory}/Library/Application Support/Spotify/PersistentCache/Update"
        if ! /usr/bin/stat -f "%Sf" "$SPOTIFY_UPDATE_DIR" 2> /dev/null | grep -q uchg; then
          rm -rf "$SPOTIFY_UPDATE_DIR"
          mkdir -p "$SPOTIFY_UPDATE_DIR"
          /usr/bin/chflags uchg "$SPOTIFY_UPDATE_DIR"
        fi
      ''
    );
  };
}
