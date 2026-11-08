{self, ...}: {
  flake.modules = self.factory.user rec {
    name = "derethil";
    email = "jarenglenn@pm.me";
    fullName = "Jaren Glenn";
    passwordSecret = "users/${name}/hashedPassword";
  };
}
