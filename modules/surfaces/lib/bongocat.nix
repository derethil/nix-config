{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.bongocat = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:saatvik333/wayland-bongocat";
  };

  flake.modules.nixos.bongocat = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.bongocat.nixosModules.default
    ];

    programs.wayland-bongocat = {
      enable = true;
      autostart = true;
      catAlign = "center";
      catHeight = 48;
      catXOffset = 24;
      catYOffset = 12;
      enableScheduledSleep = true;
      fps = 60;
      idleFrame = 0;
      idleSleepTimeout = 30;
      # Find input devices with bongocat-find-devices
      inputDevices = [];
      keypressDuration = 150;
      overlayHeight = 48;
      overlayOpacity = 0;
      overlayPosition = "bottom";
      sleepBegin = "23:00";
      sleepEnd = "07:00";
    };

    users.users = self.lib.forEachNormalUser config (_: {
      extraGroups = ["input"];
    });

    assertions = [
      {
        assertion = lib.length config.programs.wayland-bongocat.inputDevices > 0;
        message = "wayland-bongocat requires at least one input device to be specified in inputDevices. you can find available input devices using the bongocat-find-devices script.";
      }
    ];
  };
}
