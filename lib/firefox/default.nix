{
  lib,
  inputs,
}: {
  buildFirefoxXpiAddon = {
    stdenv,
    pkgs,
    pname,
    version,
    addonId,
    src,
    meta,
    ...
  }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta src;

      preferLocalBuild = true;
      allowSubstitutes = false;

      nativeBuildInputs = [pkgs.zip];

      buildCommand = ''
        # Create a temporary build directory
        mkdir build
        cd build
        cp -r $src/* .
        
        # Package only existing files (skip non-existent ones)
        files_to_zip=""
        for file in manifest.json inject_css_override_no_edit.css inject_css_override_top_only.css inject_css_override.css inject_css_suggested.css inject_css_suggested_no_edit.css imageWorker.js background.js entities.json uDarkEncoder.js icons/ Listeners.js contentScriptClass.js backgroundClass.js fakeContentScriptClass.js popup/; do
          if [[ -e "$file" ]]; then
            files_to_zip="$files_to_zip $file"
          fi
        done
        
        ${pkgs.zip}/bin/zip -r addon.xpi $files_to_zip
        
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 addon.xpi "$dst/${addonId}.xpi"
      '';
    };
}
