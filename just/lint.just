set working-directory := ".."

[private]
default:
    @just --list lint

# Run all linters and format checks
check:
    statix check --ignore .direnv .
    fd -e nix | xargs deadnix --fail
    pedantix --check $(fd -e nix)

# Auto-fix statix warnings and reformat with pedantix
fix:
    statix fix --ignore .direnv .
    pedantix $(fd -e nix)
