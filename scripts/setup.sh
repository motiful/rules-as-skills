#!/usr/bin/env bash
# rules-as-skills dependency checker.
# Protocol Skill: no skill deps, but prints activation hint at the end so the
# upstream install_skill cascade can surface it to the user naturally.
set -euo pipefail

echo "rules-as-skills: checking dependencies..."
echo ""

errors=0

# --- CLI tools ---
# install-meta-rule.sh uses bash, awk, grep, mkdir, mv, printf (all POSIX core).
for tool in bash awk grep; do
  if command -v "$tool" &>/dev/null; then
    echo "  $tool: $(command -v "$tool")"
  else
    echo "  ERROR: $tool not found"
    errors=$((errors + 1))
  fi
done

echo ""

# --- Skill dependencies via shared lib ---
# rules-as-skills has no skill dependencies. We still source the lib to keep
# the setup.sh template uniform across the ecosystem. If a future dependency
# is added, call `install_skill "name" "org/repo" || errors=$((errors + 1))`
# here before the result gate below.
source "$(dirname "$0")/install-skill-lib.sh"

# --- Result gate ---
if [ $errors -gt 0 ]; then
  echo "BLOCKED: $errors dependency issue(s). Fix above errors and re-run."
  exit 1
fi

# --- Protocol Skill activation hint ---
# Printed at tail because rules-as-skills activation modifies global rule
# files (~/.claude/rules/, ~/.codex/rules/, etc.) and must be user-consented.
# The upstream install_skill cascade will naturally surface this hint when
# another skill depends on rules-as-skills.
cat <<EOF
rules-as-skills: dependencies ready.

NOTE: rules-as-skills is a Protocol Skill.
To activate the meta-rule protocol across agent platforms, run:

  $(dirname "$0")/install-meta-rule.sh install

This modifies global rule files (~/.claude/rules/, ~/.codex/rules/, etc.).
Run with 'uninstall' to revert. Activation is idempotent but visibly changes
user-facing configuration, so it is NOT run automatically — user consent
required before first execution.
EOF

exit 0
