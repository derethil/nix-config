{
  flake.modules.homeManager.discord = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [
      (
        if pkgs.stdenv.hostPlatform.isLinux
        then pkgs.unstable.vesktop
        else pkgs.discord
      )
    ];

    # Standalone arRPC is required because Vencord's WebRichPresence plugin connects
    # to ws://127.0.0.1:1337, but Vesktop's built-in arRPC only exposes ports 6463-6472.
    # Vesktop's built-in arRPC must be disabled in ~/.config/vesktop/settings.json
    # ("arRPC": false) to avoid conflicting on the discord-ipc-0 Unix socket.
    systemd.user.services.arrpc = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "arRPC - Open Discord RPC server";
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.arrpc}/bin/arrpc";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
