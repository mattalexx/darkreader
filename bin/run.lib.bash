# shellcheck shell=bash
#
# Construction trailer for Matt

# shellcheck source=./logging.bash
#source "$HOME"/.dotfiles/lib/logging.bash

# Find public functions in script
_find_local_functions() {
    declare -F | cut -d' ' -f3 | grep -v ^_
}

# Find local command based on script args
# If function "one:two" existed and script was called this way:
# "./run one two three -four 'five six'", then this function would print
# "one:two three -four five\ six"
_find_local_command() {
    if [[ ! -v function ]]; then functions=$(_find_local_functions); fi

    # If called like "./run one two three -four 'five six'",
    # "candidates" array is ("one", "two", "three") ..
    readarray -d '' candidates < <(
        printf "%s\0" "$@" | sed --null-data -e '/^-/,$d' -re '#[^a-z0-9-:]+#,$d'
    )
    #_debug "${candidates[@]}"

    for ((i = ${#candidates[@]} - 1; i >= 0; i--)); do
        # .. set "function" to "one:two:three", "one:two", then "one"
        function=$(
            IFS=':'
            printf '%s' "${candidates[*]:0:i+1}"
        )

        if grep -qx "$function" <<<"$functions"; then
            # ... if, say, function "one:two" existed, this would print
            #     "one:two three -four five\ six"
            shift "$((i + 1))"
            printf '%s' "$function"
            printf ' %q' "$@"
            return 0
        fi
    done

    return 1
}

# eval "$(run completion bash)"
# FIXME
completion:bash() {
    mapfile -t -- arr < <(_find_local_functions)
    IFS=$'\t'
    printf 'complete -W '\''%s'\'' %s\n' "${arr[*]}" "$(basename "$0")"
}

declare -a cmd
execute() {
    declare -n array_of_args=$1
    dumprun "${array_of_args[@]}"
}

ammend() {
    echo >>"$root"/README.md
    git add -A
    if git show --name-only | grep -q 'temporary dev commit'; then
        git commit -m 'temporary dev commit' --amend
    else
        git commit -m 'temporary dev commit'
    fi

    local remote branch
    if [[ ${1:-} ]]; then
        remote=$1
        branch=$2
        git push -f "$remote" HEAD:"$branch"
    fi
}
