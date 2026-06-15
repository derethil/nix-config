{
  flake.modules.nixos.steam-options = {lib, ...}: {
    key = "gaming-steam-options";

    options.gaming.steam.extraEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
  };
}
