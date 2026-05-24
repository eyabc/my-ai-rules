#!/usr/bin/env bash
# Set up ~/.cursor/rules/ as relative symlinks to my-ai-rules SSOT.
# Idempotent: removes existing links first.
#
# Layer model:
#   - Universal rules → live HERE (my-ai-rules/.cursor/rules/)
#                       reflected at ~/.cursor/rules/ via symlink
#   - Repo-specific   → live in each {repo}/.cursor/rules/
#
# No other repo should symlink into my-ai-rules. See rule-architecture.mdc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)/.cursor/rules"
USER_DIR="${HOME}/.cursor/rules"

if [ ! -d "${SSOT_DIR}" ]; then
  echo "error: SSOT not found at ${SSOT_DIR}" >&2
  exit 1
fi

mkdir -p "${USER_DIR}"

echo "Linking universal rules:"
echo "  source: ${SSOT_DIR}"
echo "  target: ${USER_DIR}"
echo

shopt -s nullglob
for f in "${SSOT_DIR}"/*.mdc; do
  base="$(basename "${f}")"
  target="${USER_DIR}/${base}"
  if [ -L "${target}" ] || [ -e "${target}" ]; then
    rm -f "${target}"
  fi
  ln -s "${f}" "${target}"
  echo "  + ${base}"
done

echo
echo "Done. Verify with: ls -la ${USER_DIR}"
