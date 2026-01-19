# shellcheck shell=bash

fs::mkdir_p() {
  local dir="$1"
  [[ -z "$dir" ]] && { log::error "fs::mkdir_p: missing dir"; return 2; }
  mkdir -p -- "$dir"
}

fs::exists() {
  [[ -e "$1" ]]
}
