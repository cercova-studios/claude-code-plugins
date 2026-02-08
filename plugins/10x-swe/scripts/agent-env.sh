#!/usr/bin/env bash
set -euo pipefail

# Resolve AGENT_ROOT to a per-working-directory folder for agent state/assets.
export AGENT_ROOT="${PWD}/.agents"
mkdir -p "${AGENT_ROOT}"

link_if_present() {
  local name="$1"
  local link_path="${AGENT_ROOT}/${name}"
  local target_path="../${name}"

  if [[ -L "${link_path}" ]]; then
    return 0
  fi

  # Respect any real directory/file the user already placed in .agents.
  if [[ -e "${link_path}" ]]; then
    return 0
  fi

  if [[ -d "${PWD}/${name}" ]]; then
    ln -s "${target_path}" "${link_path}"
  fi
}

# Keep legacy ${AGENT_ROOT}/... skill paths working in this repository layout.
link_if_present "skills"
link_if_present "commands"
link_if_present "scripts"
link_if_present "agents"

# Helpful when run directly for diagnostics:
#   bash scripts/agent-env.sh
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'AGENT_ROOT=%s\n' "${AGENT_ROOT}"
fi
