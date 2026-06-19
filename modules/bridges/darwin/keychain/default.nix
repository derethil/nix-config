{
  flake.modules.darwin.keychain = {
    lib,
    config,
    ...
  }: let
    inherit (lib) mkAfter optionalString;

    preamble = ''
      CURRENT_USER="$(stat -f "%Su" /dev/console)"
      KEYCHAIN_PATH="/Users/$CURRENT_USER/Library/Keychains/login.keychain-db"

      if ! dscl . -read /Groups/admin GroupMembership 2>/dev/null | grep -qw "$CURRENT_USER"; then
        echo >&2 "error: keychain sync requires $CURRENT_USER to be an admin user"
        exit 1
      fi
    '';

    mkKeychainScript = item: ''
      echo >&2 "Syncing keychain entry for ${item.service}..."

      NEW_SECRET="$(cat ${item.secretFile})"
      EXISTING_SECRET="$(sudo -u "$CURRENT_USER" security find-generic-password -a "${item.account}" -s "${item.service}" -w "$KEYCHAIN_PATH" 2>/dev/null || echo "")"

      if [ "$NEW_SECRET" != "$EXISTING_SECRET" ]; then
        sudo -u "$CURRENT_USER" /usr/bin/security add-generic-password \
          -U \
          -a "${item.account}" \
          -s "${item.service}" \
          -w "$NEW_SECRET" \
          ${optionalString (item.comment != "") ''-j "${item.comment}"''} \
          ${optionalString (item.trustedApp != null) ''-T "${item.trustedApp}"''} \
          "$KEYCHAIN_PATH"
      fi
    '';
  in {
    system.activationScripts.postActivation.text = mkAfter (
      preamble + lib.concatStringsSep "\n" (lib.map mkKeychainScript config.internal.system.keychain.entries)
    );
  };
}
