"""Overlay Home Manager settings without losing Codex's mutable TOML state."""

from collections.abc import Mapping
import os
from pathlib import Path
import sys
import tempfile

import tomlkit


def merge(target, settings):
    for key, value in settings.items():
        if isinstance(value, Mapping) and isinstance(target.get(key), Mapping):
            merge(target[key], value)
        else:
            target[key] = value


def sync(source, target):
    original = target.read_text() if target.exists() else ""
    document = tomlkit.parse(original)
    merge(document, tomlkit.parse(source.read_text()))
    updated = tomlkit.dumps(document)
    if updated == original and not target.is_symlink():
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", dir=target.parent, delete=False
        ) as output:
            temporary = Path(output.name)
            output.write(updated)
        # Replace symlinks too, leaving the config writable and private (0600).
        os.replace(temporary, target)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    source = Path(sys.argv[1])
    for filename in dict.fromkeys(sys.argv[2:]):
        sync(source, Path(filename))
