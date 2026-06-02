# TODO: remove this overlay when https://github.com/NixOS/nixpkgs/issues/522895
# is resolved. szurubooru's alembic override leaves alembic depending on
# sqlalchemy 2.x while the server pins sqlalchemy_1_3, causing a duplicate
# package conflict at build time.
# Fix mirrored from https://github.com/anpandey/nixpkgs/commit/820215fe0318fb20770165949dfa2f309a476219
_: final: prev: {
  szurubooru =
    prev.szurubooru
    // {
      server = final.callPackage ./server.nix {
        inherit (prev.szurubooru.server) src version;
        patch = "${prev.path}/pkgs/servers/web-apps/szurubooru/001-server-pillow-heif.patch";
      };
    };
}
