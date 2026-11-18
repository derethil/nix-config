# Repo/dev tooling — operates on this git repo and flake only, never a live host

[private]
default:
    @just --list repo

# Flake maintenance recipes
mod flake 'repo/flake.just'

# Linting recipes
mod lint 'repo/lint.just'

# Renovate maintenance recipes
mod renovate 'repo/renovate.just'
