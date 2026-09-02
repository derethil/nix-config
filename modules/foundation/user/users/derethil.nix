{self, ...}: {
  flake.modules = self.factory.user rec {
    email = "jarenglenn@pm.me";
    fullName = "Jaren Glenn";
    name = "derethil";
    passwordSecret = "users/${name}/hashedPassword";
  };
}
