#!/usr/bin/env bash
# review-orchestrator installer / updater
# Idempotent: first run installs, subsequent runs update.
#
# Usage:
#   Global (default):   curl -fsSL <raw-url>/install.sh | sh
#   Project-local:      curl -fsSL <raw-url>/install.sh | sh -s -- --project

set -eu

REPO_URL="https://github.com/cainaican/review-orchestrator.git"

TARGET="${HOME}/.config/opencode"
if [ "${1:-}" = "--project" ]; then
  TARGET="$(pwd)/.opencode"
fi

SKILL_DIR="${TARGET}/skills/review-orchestrator"
AGENTS_DIR="${TARGET}/agents"

mkdir -p "${AGENTS_DIR}"
mkdir -p "$(dirname "${SKILL_DIR}")"

if [ -d "${SKILL_DIR}/.git" ]; then
  echo "→ Updating ${SKILL_DIR}"
  git -C "${SKILL_DIR}" pull --ff-only
else
  echo "→ Cloning into ${SKILL_DIR}"
  rm -rf "${SKILL_DIR}"
  git clone --depth 1 "${REPO_URL}" "${SKILL_DIR}"
fi

cp "${SKILL_DIR}/agents/"*.md "${AGENTS_DIR}/"

echo
echo "✓ Skill:   ${SKILL_DIR}"
echo "✓ Agents:  ${AGENTS_DIR}/{code-reviewer,critic-correctness,critic-security,critic-performance,critic-angular,critic-tests,critic-shape}.md"
echo
echo "Restart your opencode session so the Task tool picks up the agents."
