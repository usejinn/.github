#!/usr/bin/env bash
# Publishes the public parts of this repository to the usejinn GitHub
# organisation, each folder as its own repository's history:
#   sdk/go → usejinn/jinn-go, sdk/ts → usejinn/jinn-node, github/ → usejinn/.github
# Pass a version (v0.1.0) to tag jinn-go and jinn-node too. Needs gh, signed in.
set -euo pipefail
cd "$(dirname "$0")/.."
version="${1:-}"
auth="$(gh auth token)"
publish() { # folder repository
  local commit
  commit=$(git subtree split --prefix="$1" HEAD)
  git push "https://x-access-token:$auth@github.com/usejinn/$2.git" "$commit:refs/heads/main"
  if [ -n "$version" ] && [ "$2" != .github ]; then
    git push "https://x-access-token:$auth@github.com/usejinn/$2.git" "$commit:refs/tags/$version"
  fi
}
publish sdk/go jinn-go
publish sdk/ts jinn-node
publish github .github
