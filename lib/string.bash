# shellcheck shell=bash

string::trim() {
  local s="$*"
  # Remove leading/trailing spaces
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

string::lower() {
  local s="$*"
  printf '%s' "${s,,}"
}
