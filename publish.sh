#!/usr/bin/env bash
# Publishes the public parts of this repository to the usejinn GitHub
# organisation, each folder as its own repository's history:
#   sdk/go → jinn-go, sdk/ts → jinn-node, cli → jinn-cli, github → .github
#
#   github/publish.sh                    every repository's main branch
#   github/publish.sh jinn-go v0.2.0     one repository, and tag it
#
# Release the SDK before a CLI that needs it: cli/go.mod names a published
# usejinn.com/go version. Needs gh, signed in.
set -euo pipefail
cd "$(dirname "$0")/.."
declare -A folder=([jinn-go]=sdk/go [jinn-node]=sdk/ts [jinn-cli]=cli [.github]=github)
auth="$(gh auth token)"
publish() { # repository [version]
  local commit
  commit=$(git subtree split --prefix="${folder[$1]}" HEAD 2>/dev/null)
  git push -q "https://x-access-token:$auth@github.com/usejinn/$1.git" "$commit:refs/heads/main"
  if [ -n "${2:-}" ]; then
    git push -q "https://x-access-token:$auth@github.com/usejinn/$1.git" "$commit:refs/tags/$2"
  fi
  echo "usejinn/$1 ← ${folder[$1]} ${2:-}"
}
if [ $# -gt 0 ]; then
  [ -n "${folder[$1]:-}" ] || { echo "no repository $1" >&2; exit 1; }
  publish "$1" "${2:-}"
else
  for repo in "${!folder[@]}"; do publish "$repo"; done
fi
