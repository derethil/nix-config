{lib, ...}: let
  inherit (lib) types;
  inherit (lib.glace) mkBoolOpt mkOpt;
in {
  options.glace.services.openssh = with types; {
    enable = mkBoolOpt false "Whether to enable OpenSSH server.";
    authorizedKeyFiles = mkOpt (listOf str) [] "List of files containing authorized SSH public keys.";
  };

  config = {
    glace.services.openssh = {
      authorizedKeyFiles = ["%h/.ssh/id_ed25519.pub"];
    };
  };
}
