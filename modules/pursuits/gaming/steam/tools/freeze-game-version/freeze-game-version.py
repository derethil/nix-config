import sys
import os
import re
import subprocess
import tempfile

CHATTR = os.environ.get("CHATTR", "chattr")
LSATTR = os.environ.get("LSATTR", "lsattr")
STEAMAPPS_PATHS = [
    os.path.expanduser("~/.local/share/Steam/steamapps"),
    os.path.expanduser("~/.steam/steam/steamapps"),
]

HELP = """\
Usage: freeze-game-version <command> [appid]

Commands:
  freeze [appid]    Freeze a game at its current version
  unfreeze [appid]  Remove the freeze, allowing Steam to update
  info [appid]      Show installed version and freeze status
  steamdb [appid]   Open the SteamDB depots page for the app

If appid is omitted, you will be prompted for it.

Freezing requires Steam to be closed. It will open SteamDB and prompt for:
  - The new build ID (shown at the top of the Depots tab)
  - download_depot lines for each depot:
      1. Find the depot, click the version you want
      2. Click "Manifests"
      3. Set format to "Steam Console"
      4. Click Copy, then paste the line here
"""


def find_steamapps() -> str | None:
    for path in STEAMAPPS_PATHS:
        if os.path.isdir(path):
            return path
    return None


def get_manifest_path(appid: int) -> str:
    steamapps = find_steamapps()
    if not steamapps:
        print("Error: Steam steamapps directory not found", file=sys.stderr)
        sys.exit(1)
    path = os.path.join(steamapps, f"appmanifest_{appid}.acf")
    if not os.path.exists(path):
        print(f"Error: {path} not found", file=sys.stderr)
        sys.exit(1)
    return path


def update_field(content: str, key: str, value: str) -> str:
    return re.sub(
        r'("' + re.escape(key) + r'"\s+)"[^"]*"',
        lambda m: m.group(1) + '"' + value + '"',
        content,
    )


def update_depot_manifest(content: str, depot_id: str, manifest_id: str) -> str:
    key_str = f'"{depot_id}"'
    depot_pos = content.find(key_str)
    if depot_pos < 0:
        return content
    brace_start = content.find("{", depot_pos)
    if brace_start < 0:
        return content
    depth, i = 0, brace_start
    while i < len(content):
        if content[i] == "{":
            depth += 1
        elif content[i] == "}":
            depth -= 1
            if depth == 0:
                block = content[brace_start : i + 1]
                updated_block = update_field(block, "manifest", manifest_id)
                return content[:brace_start] + updated_block + content[i + 1 :]
        i += 1
    return content


def open_steamdb(appid: int):
    _ = subprocess.run(["xdg-open", f"https://steamdb.info/app/{appid}/depots/"])


def get_installed_depot_ids(content: str) -> list[str]:
    depot_start = content.find('"InstalledDepots"')
    if depot_start < 0:
        return []
    brace_start = content.find("{", depot_start)
    if brace_start < 0:
        return []
    depth, i = 0, brace_start
    while i < len(content):
        if content[i] == "{":
            depth += 1
        elif content[i] == "}":
            depth -= 1
            if depth == 0:
                return re.findall(r'"(\d+)"\s*\{', content[brace_start : i + 1])
        i += 1
    return []


def prompt_depot_manifests(required: list[str]) -> dict[str, str]:
    print(f"Required depots: {', '.join(required) if required else 'unknown'}")
    print(
        "For each depot: click the version → Manifests → set format to Steam Console → Copy"
    )
    print("Paste the 'download_depot' lines here (empty line when done):")

    manifests: dict[str, str] = {}
    while True:
        try:
            line = input().strip()
        except EOFError:
            break
        if not line:
            missing = [d for d in required if d not in manifests]
            if not missing:
                break
            print(f"Missing depots: {', '.join(missing)}. Paste their lines:")
            continue
        parts = line.split()
        if len(parts) >= 4 and parts[0] == "download_depot":
            depot_id, manifest_id = parts[2], parts[3]
            manifests[depot_id] = manifest_id
            print(f"  depot {depot_id}: {manifest_id}")

    return manifests


def apply_manifest_updates(
    content: str, build_id: str, depot_manifests: dict[str, str]
) -> str:
    for key, val in [
        ("StateFlags", "4"),
        ("buildid", build_id),
        ("TargetBuildID", build_id),
        ("BytesToDownload", "0"),
        ("BytesDownloaded", "0"),
        ("BytesToStage", "0"),
        ("BytesStaged", "0"),
        ("DownloadType", "0"),
        ("ScheduledAutoUpdate", "0"),
        ("AutoUpdateBehavior", "1"),
    ]:
        content = update_field(content, key, val)
    for depot_id, manifest_id in depot_manifests.items():
        updated = update_depot_manifest(content, depot_id, manifest_id)
        if updated == content:
            print(
                f"Warning: depot {depot_id} not found in manifest — skipped",
                file=sys.stderr,
            )
        content = updated
    return content


def freeze(appid: int):
    if subprocess.run(["pgrep", "-x", "steam"], capture_output=True).returncode == 0:
        print("Error: Steam is running. Close it before freezing.", file=sys.stderr)
        sys.exit(1)

    manifest_path = get_manifest_path(appid)
    with open(manifest_path) as f:
        content = f.read()

    print("Current state:")
    for line in content.splitlines():
        if any(k in line for k in ['"buildid"', '"TargetBuildID"', '"StateFlags"']):
            print(" ", line.strip())
    print()

    print("Opening SteamDB depots page...")
    open_steamdb(appid)

    build_id = input("New build ID (from SteamDB): ").strip()
    depot_manifests = prompt_depot_manifests(get_installed_depot_ids(content))
    content = apply_manifest_updates(content, build_id, depot_manifests)

    dir_ = os.path.dirname(manifest_path)
    with tempfile.NamedTemporaryFile("w", dir=dir_, delete=False, suffix=".tmp") as tmp:
        _ = tmp.write(content)
        tmp_path = tmp.name
    os.rename(tmp_path, manifest_path)

    print("\nManifest updated. Locking with chattr +i (requires sudo)...")
    result = subprocess.run(["sudo", CHATTR, "+i", manifest_path])
    if result.returncode == 0:
        print(f"Frozen at build {build_id}: {manifest_path}")
        print(f"To unfreeze: freeze-game-version unfreeze {appid}")
    else:
        print(f"chattr failed — run manually: sudo chattr +i {manifest_path}")


def unfreeze(appid: int):
    if subprocess.run(["pgrep", "-x", "steam"], capture_output=True).returncode == 0:
        print("Error: Steam is running. Close it before unfreezing.", file=sys.stderr)
        sys.exit(1)

    manifest_path = get_manifest_path(appid)
    result = subprocess.run(["sudo", CHATTR, "-i", manifest_path])
    if result.returncode == 0:
        print(f"Unfrozen: {manifest_path}")
    else:
        print(f"chattr failed — run manually: sudo chattr -i {manifest_path}")


def info(appid: int):
    manifest_path = get_manifest_path(appid)

    with open(manifest_path) as f:
        content = f.read()

    fields: dict[str, str] = {}
    for key in ["name", "buildid", "TargetBuildID", "StateFlags"]:
        m = re.search(r'"' + re.escape(key) + r'"\s+"([^"]*)"', content)
        fields[key] = m.group(1) if m else "unknown"

    lsattr = subprocess.run([LSATTR, manifest_path], capture_output=True, text=True)
    lsattr_parts = lsattr.stdout.split()
    is_frozen = lsattr.returncode == 0 and bool(lsattr_parts) and "i" in lsattr_parts[0]

    state = int(fields["StateFlags"]) if fields["StateFlags"].isdigit() else 0
    update_pending = bool(state & 2)

    print(f"  name:          {fields['name']}")
    print(f"  buildid:       {fields['buildid']}")
    print(f"  target build:  {fields['TargetBuildID']}")
    print(f"  update queued: {'yes' if update_pending else 'no'}")
    print(f"  frozen:        {'yes' if is_frozen else 'no'}")


def main():
    args = sys.argv[1:]

    if not args or args[0] in ("-h", "--help"):
        print(HELP)
        sys.exit(0)

    command = args[0]

    def get_appid() -> int:
        raw = args[1] if len(args) > 1 else input("Steam App ID: ").strip()

        if not raw.isdigit():
            print(f"Error: app ID must be an integer, got: {raw!r}", file=sys.stderr)
            sys.exit(1)

        return int(raw)

    match command:
        case "unfreeze":
            unfreeze(get_appid())
        case "info":
            info(get_appid())
        case "freeze":
            freeze(get_appid())
        case "steamdb":
            open_steamdb(get_appid())
        case _:
            print(f"Unknown command: {command!r}", file=sys.stderr)
            print(HELP)
            sys.exit(1)


if __name__ == "__main__":
    main()
