#!/usr/bin/env bash
# scripts/check-deps.sh
# Validate all VibeCrew dependencies
# Returns JSON with status of each dependency
#
# Flags:
#   --auto-install   Include install_commands in JSON output
#
# Exit 0: all required dependencies met
# Exit 1: required dependency missing

set -euo pipefail

AUTO_INSTALL=false
for arg in "$@"; do
  case "$arg" in
    --auto-install) AUTO_INSTALL=true ;;
  esac
done

PASS=0; FAIL=0; WARN=0; RESULTS=(); INSTALL_CMDS=()

# Detect package manager
if command -v brew &>/dev/null; then
  PKG_MGR="brew"
elif command -v apt-get &>/dev/null; then
  PKG_MGR="apt"
else
  PKG_MGR="unknown"
fi

check_dep() {
  local name="$1" command="$2" min_version="$3" level="$4"
  local brew_pkg="${5:-$command}" apt_pkg="${6:-$command}"
  local version_flag="${7:---version}"

  # Build install hint based on detected package manager
  local install_hint
  case "$PKG_MGR" in
    brew) install_hint="brew install $brew_pkg" ;;
    apt)  install_hint="sudo apt-get install -y $apt_pkg" ;;
    *)    install_hint="Install $name ($command) manually" ;;
  esac

  if ! command -v "$command" &>/dev/null; then
    RESULTS+=("{\"name\":\"$name\",\"command\":\"$command\",\"status\":\"missing\",\"required\":\"$min_version\",\"install\":\"$install_hint\",\"level\":\"$level\"}")
    if [[ "$level" == "required" ]]; then
      FAIL=$(( FAIL + 1 ))
      INSTALL_CMDS+=("$install_hint")
    else
      WARN=$(( WARN + 1 ))
      INSTALL_CMDS+=("$install_hint")
    fi
    return
  fi

  local version
  version=$("$command" $version_flag 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  RESULTS+=("{\"name\":\"$name\",\"command\":\"$command\",\"status\":\"ok\",\"found\":\"${version:-unknown}\",\"required\":\"$min_version\",\"level\":\"$level\"}")
  PASS=$(( PASS + 1 ))
}

# Required dependencies (block /setup if missing)
check_dep "Git"     "git"  "2.30.0" "required" "git"  "git"  "--version"
check_dep "Node.js" "node" "18.0.0" "required" "node" "nodejs" "--version"
check_dep "jq"      "jq"   "1.6"    "required" "jq"   "jq"   "--version"

# Optional dependencies (warn but don't block)
check_dep "GitHub CLI"        "gh"                  "2.0.0" "optional" "gh"                  "gh"                  "--version"
check_dep "GitLab CLI"        "glab"                "1.0.0" "optional" "glab"                "glab"                "--version"
check_dep "terminal-notifier" "terminal-notifier"   "2.0.0" "optional" "terminal-notifier"   "terminal-notifier"   "--version"

# Check gh auth status (informational, never blocks)
GH_AUTH="not_installed"
if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null 2>&1; then
    GH_AUTH="ok"
  else
    GH_AUTH="not_authenticated"
  fi
fi

# Check glab auth status (informational, never blocks)
GLAB_AUTH="not_installed"
if command -v glab &>/dev/null; then
  if glab auth status &>/dev/null 2>&1; then
    GLAB_AUTH="ok"
  else
    GLAB_AUTH="not_authenticated"
  fi
fi

# Build output JSON
DEPS_JSON=$(printf '%s,' "${RESULTS[@]}" | sed 's/,$//')

if [[ "$AUTO_INSTALL" == "true" ]]; then
  # Include install commands for missing deps
  CMDS_JSON="[]"
  if [[ ${#INSTALL_CMDS[@]} -gt 0 ]]; then
    CMDS_JSON=$(printf '%s\n' "${INSTALL_CMDS[@]}" | jq -R . | jq -s .)
  fi
  jq -n --argjson deps "[$DEPS_JSON]" --arg gh_auth "$GH_AUTH" --arg glab_auth "$GLAB_AUTH" \
    --argjson pass "$PASS" --argjson fail "$FAIL" --argjson warn "$WARN" \
    --argjson cmds "$CMDS_JSON" --arg pkg_mgr "$PKG_MGR" \
    '{dependencies:$deps, gh_authenticated:$gh_auth, glab_authenticated:$glab_auth, package_manager:$pkg_mgr, install_commands:$cmds, summary:{passed:$pass, required_failed:$fail, optional_missing:$warn, ready:($fail==0)}}'
else
  jq -n --argjson deps "[$DEPS_JSON]" --arg gh_auth "$GH_AUTH" --arg glab_auth "$GLAB_AUTH" \
    --argjson pass "$PASS" --argjson fail "$FAIL" --argjson warn "$WARN" \
    '{dependencies:$deps, gh_authenticated:$gh_auth, glab_authenticated:$glab_auth, summary:{passed:$pass, required_failed:$fail, optional_missing:$warn, ready:($fail==0)}}'
fi

[[ "$FAIL" -gt 0 ]] && exit 1 || exit 0
