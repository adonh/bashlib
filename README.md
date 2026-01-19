## quick start

## supported bash versions

## module index

## configuration knobs

### BASHLIB_LOG_LEVEL

### BASHLIB_NO_COLOR

## examples

```
#!/usr/bin/env bash
set -euo pipefail

# Adjust path as needed
# shellcheck source=init.bash
source "/path/to/bashlib/init.bash"

bashlib::use log fs string

log::info "Starting"
fs::mkdir_p "./out"
log::debug "Realpath: $(fs::realpath ./out)"
echo "Trimmed: '$(string::trim "  hello  ")'"
```

### using strict mode

```
mymod::fn() {
  local -a shopt_prev
  shopt_prev=($(shopt))  # capture
  shopt -s nullglob
  # … do work …
  # restore
  while read -r state opt; do
    [[ "$state" == "shopt" ]] || continue
    if [[ "$opt" =~ on ]]; then shopt -s "${opt##* }"; else shopt -u "${opt##* }"; fi
  done < <(printf '%s\n' "${shopt_prev[@]}")
}
```

## installation
