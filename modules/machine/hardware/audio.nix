{
  self,
  inputs,
  ...
}: {
  flake.modules.nixos.pipewire-low-latency = {
    key = "pipewire-low-latency";
    imports = [inputs.nix-gaming.nixosModules.pipewireLowLatency];
  };

  flake.modules.nixos.audio = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [self.modules.nixos.pipewire-low-latency];

    security.rtkit.enable = true;
    services.pulseaudio.enable = lib.mkForce false;

    services.pipewire = {
      enable = true;
      audio.enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      lowLatency = {
        enable = true;
        quantum = 1024;
        rate = 24000;
      };
    };

    environment.systemPackages = [pkgs.pulsemixer];

    users.users = self.lib.forEachNormalUser config (_: {
      extraGroups = ["audio"];
    });
  };
}
