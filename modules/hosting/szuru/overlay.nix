# Override szurubooru.server to pin alembic at the older version so it stays
# compatible with sqlalchemy 1.3. Upstream nixpkgs hits a duplicate-package
# conflict from a partial alembic update. Remove once
# https://github.com/NixOS/nixpkgs/issues/522895 lands.
# Mirrored from https://github.com/anpandey/nixpkgs/commit/820215fe0318fb20770165949dfa2f309a476219
_: {
  flake.overlays.szurubooru = final: prev: let
    serverOverride = {
      src,
      version,
      lib,
      nixosTests,
      fetchPypi,
      python3,
      ffmpeg_4-full,
      szurubooru,
      patch,
    }: let
      overrides = [
        (self: super: {
          alembic = super.alembic.overridePythonAttrs (oldAttrs: rec {
            version = "1.8.1";
            src = fetchPypi {
              pname = "alembic";
              inherit version;
              sha256 = "sha256-zQteRbFLcGQmuDPwY2m5ptXuA/gm7DI4cjzoyq9uX/o=";
            };
            doCheck = false;
            dependencies =
              (builtins.filter (p: p.pname or "" != "sqlalchemy") (oldAttrs.dependencies or []))
              ++ [self.sqlalchemy_1_3];
          });
        })
      ];

      python = python3.override {
        self = python;
        packageOverrides = lib.composeManyExtensions overrides;
      };
    in
      python.pkgs.buildPythonApplication {
        pname = "szurubooru-server";
        inherit version src;
        pyproject = true;

        patches = [patch];

        nativeBuildInputs = with python.pkgs; [setuptools];
        propagatedBuildInputs = with python.pkgs; [
          certifi
          coloredlogs
          legacy-cgi
          numpy
          pillow
          pillow-heif
          psycopg2-binary
          pynacl
          pyrfc3339
          pytz
          pyyaml
          sqlalchemy_1_3
          yt-dlp
        ];

        makeWrapperArgs = [
          "--prefix PATH : ${lib.makeBinPath [ffmpeg_4-full]}"
        ];

        postInstall = ''
          mkdir $out/bin
          install -m0755 $src/szuru-admin $out/bin/szuru-admin
        '';

        passthru.tests.szurubooru = nixosTests.szurubooru;

        passthru.alembic = python.pkgs.alembic.overrideAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [szurubooru.server];
        });
        passthru.waitress = python.pkgs.waitress.overrideAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [szurubooru.server];
        });

        meta = {
          description = "Server of szurubooru, an image board engine for small and medium communities";
          homepage = "https://github.com/rr-/szurubooru";
          license = lib.licenses.gpl3;
          maintainers = with lib.maintainers; [ratcornu];
        };
      };
  in {
    szurubooru =
      prev.szurubooru
      // {
        server = final.callPackage serverOverride {
          inherit (prev.szurubooru.server) src version;
          patch = "${prev.path}/pkgs/servers/web-apps/szurubooru/001-server-pillow-heif.patch";
        };
      };
  };
}
