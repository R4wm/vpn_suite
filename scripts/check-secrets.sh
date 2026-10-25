#!/usr/bin/env bash
# Fail if staged content contains a real WireGuard private or preshared key.
# Usage: scripts/check-secrets.sh            (scan staged files)
#        scripts/check-secrets.sh --all      (scan all tracked files at HEAD)
#        scripts/check-secrets.sh --install-hook

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
PATTERN='(PrivateKey|PresharedKey)[[:space:]]*=[[:space:]]*[A-Za-z0-9+/]{43}='

case "${1:-}" in
  --install-hook)
    HOOK="$(git rev-parse --git-path hooks)/pre-commit"
    printf '#!/usr/bin/env bash\nexec "%s/scripts/check-secrets.sh"\n' "${REPO_ROOT}" > "${HOOK}"
    chmod +x "${HOOK}"
    echo "Installed pre-commit hook: ${HOOK}"
    exit 0
    ;;
  --all)
    if git -C "${REPO_ROOT}" grep -qE "${PATTERN}" HEAD -- .; then
      echo "ERROR: WireGuard key material found in tracked files:" >&2
      git -C "${REPO_ROOT}" grep -lE "${PATTERN}" HEAD -- . >&2
      exit 1
    fi
    echo "OK: no key material in tracked files."
    exit 0
    ;;
esac

found=0
while IFS= read -r -d '' path; do
  if git -C "${REPO_ROOT}" show ":${path}" 2>/dev/null | grep -qE "${PATTERN}"; then
    echo "ERROR: staged file contains WireGuard key material: ${path}" >&2
    found=1
  fi
done < <(git -C "${REPO_ROOT}" diff --cached --name-only --diff-filter=ACMR -z)

if [[ "${found}" -ne 0 ]]; then
  echo "Unstage it (git restore --staged <path>) and keep plaintext configs under native-clients/plaintext/." >&2
  exit 1
fi
