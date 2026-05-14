{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
in {
  options.glace.apps.social.discord.enable = mkBoolOpt false "Whether to enable Discord";
  options.glace.apps.social.vesktop.enable = mkBoolOpt false "Whether to enable Vesktop";

  config = {
    home.packages = with pkgs; [
      (mkIf config.glace.apps.social.discord.enable discord)
      (mkIf config.glace.apps.social.vesktop.enable unstable.vesktop)
    ];

    # NOTE: Standalone arRPC is required because Vencord's WebRichPresence plugin connects
    # to ws://127.0.0.1:1337, but Vesktop's built-in arRPC only exposes ports 6463-6472.
    # Vesktop's built-in arRPC must be disabled in ~/.config/vesktop/settings.json
    # ("arRPC": false) to avoid conflicting on the discord-ipc-0 Unix socket.
    # Revisit once Vesktop exposes its arRPC on port 1337 natively.
    systemd.user.services.arrpc = mkIf config.glace.apps.social.vesktop.enable {
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
