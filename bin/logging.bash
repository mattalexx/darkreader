# shellcheck shell=bash disable=2059
#
# Construction trailer for Matt

if [[ -v __log_mutex ]]; then return; fi

# Log levels
LEVEL_ERROR=40
LEVEL_WARN=30
LEVEL_INFO=20
LEVEL_DEBUG=10

declare -A colors=(
    [$LEVEL_ERROR]=1
    [$LEVEL_WARN]=3
    [$LEVEL_INFO]=6
    [$LEVEL_DEBUG]=7
)

# Defaults
LOG_LEVEL=${LOG_LEVEL:-$LEVEL_INFO}
LOG_COLOR=${LOG_COLOR:-1}

__log_mutex=/run/user/"$(id -u)"/"$(basename "$0")".pid

# Runtime logging

logok() { _log "$LEVEL_INFO" '' "$@"; }
loginfo() { _log "$LEVEL_INFO" '' "$@"; }
logwarn() { _log "$LEVEL_WARN" 'WARNING: ' "$@"; }
logerr() { _log "$LEVEL_ERROR" 'ERROR: ' "$@"; }
logdie() { _log "$LEVEL_ERROR" 'ERROR: ' "$@" && return 1; }

logrun() {
    local exe=$1 msg=$1
    shift
    msg+=$(printf ' %s' "${@@Q}")
    _log "$LEVEL_INFO" 'Running: ' "$msg"

    # Execute
    "$exe" "$@"
}

# Testing

logpass() { _log "$LEVEL_INFO" 'PASS: ' "$@"; }
logfail() { _log "$LEVEL_ERROR" 'FAIL: ' "$@"; }

# Debugging

# Log a command, then run it. A more surgical
# and less wordy version of `(set -x; cmd string doll)`.
#
# Usage:
#     LOG_LEVEL=$LEVEL_DEBUG
#
#     % show echo "string doll"
#     Running: echo string\ doll
#     string doll
#
#     % show echo string | show tr i o
#     # Running: echo string
#
#     % show sh -c 'echo string | tr i o'
#     # Running: echo string

dumprun() {
    local exe=$1 msg=$1
    shift
    msg+=$(printf ' %s' "${@@Q}")
    _log "$LEVEL_DEBUG" '# Running: ' "$msg"

    # Execute
    "$exe" "$@"
}

dumpargs() {
    _log "$LEVEL_DEBUG" '#' "$(printf ' [%s]' "$@")"
}

dumpvars() {
    if (($# > 1)); then
        while [[ ${1:-} ]]; do
            dumpvars "$1"
            shift
        done
        return
    fi

    local name=$1 decl
    decl=$(declare -p "$name")

    if ! grep -q '^[^ ] -[Aa]' <<<"$decl" || ((${#decl} < 80)); then
        dump "$decl"
        return
    fi

    dump '%s' "$(sed -E 's/=\(.*/=(\n/' <<<"$decl")"
    local -n ref=$1
    for k in "${!ref[@]}"; do
        dump '  [%q]=%s' "$k" "${ref[$k]@Q}"
    done
    dump ')'
}

dump() {
    _log "$LEVEL_DEBUG" '# ' "$@"
}

_log() (
    local level=$1 prefix=$2 color
    shift 2
    if [[ $1 ]] && [[ ${1//[^0-9]/} == "$1" ]]; then
        color=$1
        shift
    else
    color=${colors[$level]}
    fi
    #flock 9
    ((LOG_LEVEL <= level)) || return 0
    if [[ $LOG_COLOR == 1 ]]; then
        tput setaf "$color"
    fi
    printf '%s' "$prefix"
    printf -- "$@"
    if [[ $LOG_COLOR == 1 ]]; then tput sgr0; fi
    printf '\n'
) 1>&2 #9>"$__log_mutex"
