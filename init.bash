# boot.bash
# shellcheck shell=bash

# guard against multiple sourcing
if [[ -n "${BASHLIB_BOOTSTRAPPED:-}" ]]; then
  return 0
fi
declare -gr BASHLIB_BOOTSTRAPPED=1

# require bash and a minimum version:
if [[ -z "${BASH_VERSION:-}" ]]; then
  printf 'error: baslib requires bash\n' >&2
  return 1
fi
if (( BASH_VERSINFO[0] < 4 )); then
  printf 'error: requires bash >= 4.x (you have %s)\n' "$BASH_VERSION" >&2
  return 1
fi

# resolve library root relative to this file
# works even when called via symlink
_bashlib_dir() {
  local src="${BASH_SOURCE[0]}" dir
  while [[ -h "$src" ]]; do
    dir="$(cd -P -- "$(dirname -- "$src")" && pwd)"
    src="$(readlink -- "$src")"
    [[ "$src" != /* ]] && src="$dir/$src"
  done
  dir="$(cd -P -- "$(dirname -- "$src")" && pwd)"
  printf '%s/lib\n' "$dir"
}

_bashlib_root="$(_bashlib_dir)" || {
  printf 'error: _bashlib_dir failed to resolve root.\n' >&2
  return 1
}
declare -gr BASHLIB_ROOT="${_bashlib_root}"
unset _bashlib_root

declare -grx BASHLIB_VERSION="0.1.0"


# strict-mode helper (optional)
bashlib::enable_strict_mode() {
  # Use with care; document the impact in README
  set -euo pipefail
  shopt -s nullglob dotglob
}

# keep track of loaded modules to avoid duplicate imports
declare -A BASHLIB_LOADED

# fallback error helper (works before log.sh is loaded)
_bashlib::_err() {
  if declare -F log::error >/dev/null 2>&1; then
    log::error "$*"
  else
    printf '%s\n' "$*" >&2
  fi
}

# import one or more modules by name.
# usage:
#   bashlib::use fs log string
#   bashlib::use fs/path   # submodule: lib/fs/path.sh
bashlib::use() {
  local mod path
  if (( $# == 0 )); then
    _bashlib::_err "bashlib::use: need least one module name"
    return 2
  fi

  for mod in "$@"; do
    # Validate module name to avoid path traversal or weird chars
    if [[ "$mod" == /* || "$mod" == *..* || "$mod" =~ [^A-Za-z0-9_/-] ]]; then
      _bashlib::_err "bashlib::use: invalid module '$mod'"
      return 2
    fi

    # Already loaded? Skip
    if [[ -n "${BASHLIB_LOADED[$mod]:-}" ]]; then
      continue
    fi

    path="${BASHLIB_ROOT}/${mod}.bash"
    if [[ -r "$path" ]]; then
      # dynamic source is intentional
      # shellcheck disable=SC1090
      source "$path"
      BASHLIB_LOADED[$mod]=1
    else
      _bashlib::_err "bashlib::use: no such module: '$mod'"
      return 1
    fi
  done
}

bashlib::loaded() {
  local k
  for k in "${!BASHLIB_LOADED[@]}"; do
    printf '%s\n' "$k"
  done
}
