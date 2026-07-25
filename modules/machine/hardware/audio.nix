{
  self,
  inputs,
  ...
}: {
  flake.modules.nixos = {
    audio = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [self.modules.nixos.pipewire-low-latency];
      environment.systemPackages = [pkgs.pulsemixer];
      security.rtkit.enable = true;

      services = {
        pipewire = {
          enable = true;

          alsa = {
            enable = true;
            support32Bit = true;
          };

          audio.enable = true;

          lowLatency = {
            enable = true;
            quantum = 1024;
            rate = 24000;
          };

          pulse.enable = true;
        };

        pulseaudio.enable = lib.mkForce false;
      };

      users.users = self.lib.forEachNormalUser config (_: {
        extraGroups = ["audio"];
      });
    };

    pipewire-low-latency = {
      key = "pipewire-low-latency";
      imports = [inputs.nix-gaming.nixosModules.pipewireLowLatency];
    };
  };
}
