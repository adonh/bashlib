# shellcheck shell=bash
# Logging utilities with levels and optional color

# Defaults can be overridden by caller before sourcing bootstrap
: "${BASHLIB_LOG_LEVEL:=info}"   # debug, info, warn, error
: "${BASHLIB_NO_COLOR:=0}"

_log::_level_to_num() {
  case "$1" in
    debug) echo 10 ;;
    info)  echo 20 ;;
    warn)  echo 30 ;;
    error) echo 40 ;;
    *)     echo 20 ;;
  esac
}

_log::_should_log() {
  local want lvl
  want="$(_log::_level_to_num "$BASHLIB_LOG_LEVEL")"
  lvl="$(_log::_level_to_num "$1")"
  (( lvl >= want ))
}

_log::_color() {
  [[ "$BASHLIB_NO_COLOR" == "1" ]] && return 0
  case "$1" in
    debug) printf '\e[36m' ;; # cyan
    info)  printf '\e[32m' ;; # green
    warn)  printf '\e[33m' ;; # yellow
    error) printf '\e[31m' ;; # red
  esac
}

_log::_reset() { [[ "$BASHLIB_NO_COLOR" == "1" ]] || printf '\e[0m'; }

###

log::debug() {
  _log::_should_log debug \
    && printf '%s[DEBUG]%s %s\n' "$(_log::_color debug)" "$(_log::_reset)" "$*" >&2
}

log::info() {
  _log::_should_log info \
    && printf '%s[INFO ]%s %s\n' "$(_log::_color info)"  "$(_log::_reset)" "$*" >&2
}

log::warn() {
  _log::_should_log warn \
    && printf '%s[WARN ]%s %s\n' "$(_log::_color warn)"  "$(_log::_reset)" "$*" >&2
}
