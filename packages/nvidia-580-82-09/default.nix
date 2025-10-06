{
  lib,
  linuxPackages,
  kernelPackages ? linuxPackages,
  ...
}:
kernelPackages.nvidiaPackages.mkDriver {
  version = "580.82.09";
  sha256_64bit = "sha256-Puz4MtouFeDgmsNMKdLHoDgDGC+QRXh6NVysvltWlbc=";
  sha256_aarch64 = "sha256-YB+mQD+oEDIIDa+e8KX1/qOlQvZMNKFrI5z3CoVKUjs=";
  openSha256 = "sha256-YB+mQD+oEDIIDa+e8KX1/qOlQvZMNKFrI5z3CoVKUjs=";
  settingsSha256 = "sha256-um53cr2Xo90VhZM1bM2CH4q9b/1W2YOqUcvXPV6uw2s=";
  persistencedSha256 = lib.fakeHash;
}
