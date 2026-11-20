#!/usr/bin/env sh
# The desktop's coverage floors: the Rust groups of the repository's
# tool/coverage.sh, against tool/coverage-floors.txt (cat-1016).
set -eu
exec "$(dirname "$0")/../../tool/coverage.sh" rust-core rust-gui rust-l10n "$@"
