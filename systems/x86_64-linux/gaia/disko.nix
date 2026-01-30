let
  device = "/dev/sda";
  bootSize = "2G";
  swapSize = "32G";
  isSSD = true;
in {
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/home".neededForBoot = true; # so sops can retrieve ~/.config/sops/age/keys.txt

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        inherit device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = bootSize;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = swapSize;
              content = {
                type = "swap";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "enc";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = isSSD;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                    };
                    "/root-blank" = {};
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=home" "compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["subvol=persist" "compress=zstd" "noatime"];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["subvol=log" "compress=zstd" "noatime"];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
