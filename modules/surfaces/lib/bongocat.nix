{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.bongocat = {
    url = "github:saatvik333/wayland-bongocat";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.bongocat = {
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.bongocat.nixosModules.default
    ];

    users.users = self.lib.forEachNormalUser config (_: {
      extraGroups = ["input"];
    });

    programs.wayland-bongocat = {
      enable = true;
      autostart = true;

      catXOffset = 24;
      catYOffset = 12;

      catHeight = 48;
      catAlign = "center";

      overlayHeight = 48;
      overlayOpacity = 0;
      overlayPosition = "bottom";

      fps = 60;
      idleFrame = 0;
      keypressDuration = 150;

      idleSleepTimeout = 30;
      enableScheduledSleep = true;
      sleepBegin = "23:00";
      sleepEnd = "07:00";

      # Find input devices with bongocat-find-devices
      inputDevices = [];
    };

    assertions = [
      {
        assertion = lib.length config.programs.wayland-bongocat.inputDevices > 0;
        message = "wayland-bongocat requires at least one input device to be specified in inputDevices. you can find available input devices using the bongocat-find-devices script.";
      }
    ];
  };
}
