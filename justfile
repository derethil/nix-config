# Bootstrap & host management recipes
import 'just/bootstrap.just'

# Restic backup management and restoration
mod backups 'just/backups.just'

# Darwin (macOS) maintenance recipes
mod darwin 'just/darwin.just'

# Flake maintenance recipes
mod flake 'just/flake.just'

# Linting recipes
mod lint 'just/lint.just'

# Secrets management recipes
mod secrets 'just/secrets.just'

[private]
default:
    @just --list
