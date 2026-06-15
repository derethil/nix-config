{
  # NOTE: not sure how to make this work with more than one user on the same machine since it is a system-level module
  # so for now we will just assume the keychain entries are for the primary user and use their home directory to determine the keychain path.
  flake.modules.darwin.keychain = {
    lib,
    config,
    ...
  }: let
    inherit (lib) mkAfter optionalString;

    primaryUser = config.users.users.${config.system.primaryUser};

    keychainPath = "${primaryUser.home}/Library/Keychains/login.keychain-db";

    mkKeychainScript = item: ''
      echo >&2 "Syncing keychain entry for ${item.service}..."

      # Check if secret needs updating by comparing with existing keychain entry
      NEW_SECRET="$(cat ${item.secretFile})"
      EXISTING_SECRET="$(sudo -u "${primaryUser.name}" security find-generic-password -a "${item.account}" -s "${item.service}" -w "${keychainPath}" 2>/dev/null || echo "")"

      if [ "$NEW_SECRET" != "$EXISTING_SECRET" ]; then
        sudo -u "${primaryUser.name}" /usr/bin/security add-generic-password \
          -U \
          -a "${item.account}" \
          -s "${item.service}" \
          -w "$NEW_SECRET" \
          ${optionalString (item.comment != "") ''-j "${item.comment}"''} \
          ${optionalString (item.trustedApp != null) ''-T "${item.trustedApp}"''} \
          "${keychainPath}"
      fi
    '';
  in {
    system.activationScripts.postActivation.text = mkAfter (
      lib.concatStringsSep "\n" (lib.map mkKeychainScript config.internal.system.keychain.entries)
    );
  };
}
