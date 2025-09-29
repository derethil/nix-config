{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkAfter types optionalString;
  inherit (lib.glace) mkBoolOpt mkOpt mkSubmoduleListOpt;
  cfg = config.glace.system.keychain;

  keychainPath = "/Users/${config.glace.user.name}/Library/Keychains/login.keychain-db";

  mkKeychainScript = item: ''
    echo >&2 "Syncing keychain entry for ${item.service}..."

    # Check if secret needs updating by comparing with existing keychain entry
    NEW_SECRET="$(cat ${item.secretFile})"
    EXISTING_SECRET="$(sudo -u "${config.glace.user.name}" security find-generic-password -a "${item.account}" -s "${item.service}" -w "${keychainPath}" 2>/dev/null || echo "")"

    if [ "$NEW_SECRET" != "$EXISTING_SECRET" ]; then
      sudo -u "${config.glace.user.name}" /usr/bin/security add-generic-password \
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
  options.glace.system.keychain = {
    enable = mkBoolOpt (cfg.entries != []) "Whether to enable keychain management";
    entries = mkSubmoduleListOpt "Entries to add to the keychain." {
      secretFile = mkOpt types.str null "Path to the secret file (usually from SOPS)";
      service = mkOpt types.str null "Keychain service identifier";
      account = mkOpt types.str "default" "Keychain account name";
      comment = mkOpt types.str "" "Comment for the keychain entry";
      trustedApp = mkOpt (types.nullOr types.str) null "Path to trusted application";
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.extraActivation.text = mkAfter (
      lib.concatStringsSep "\n" (lib.map mkKeychainScript cfg.entries)
    );
  };
}
