# Bootstrap & host management recipes
import 'just/bootstrap.just'

# Restic backup management and restoration
mod backups 'just/backups.just'

# Flake maintenance recipes
mod flake 'just/flake.just'

# Secrets management recipes
mod secrets 'just/secrets.just'

[private]
default:
    @just --list
