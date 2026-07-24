{lib, ...}: let
  mkPortOption = default:
    lib.mkOption {
      inherit default;
      type = lib.types.port;
    };
in {
  flake.modules.nixos.ports = {config, ...}: let
    ports = lib.attrValues config.internal.homelab.ports;
    duplicates = lib.unique (lib.filter (port: lib.count (other: other == port) ports > 1) ports);
  in {
    options.internal.homelab.ports = {
      tandoor = mkPortOption 20010;
    };

    config.assertions = [
      {
        assertion = duplicates == [];
        message = "internal.homelab.ports: ports must be unique across services; reused: ${lib.concatMapStringsSep ", " toString duplicates}";
      }
    ];
  };
}
