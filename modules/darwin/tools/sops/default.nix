{pkgs, ...}: {
  config = {
    environment.systemPackages = with pkgs; [sops age];
    sops = {
      age.keyFile = "/var/lib/sops/age/keys.txt";
      gnupg.sshKeyPaths = [];
      age.sshKeyPaths = [];
    };
  };
}
