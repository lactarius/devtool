############### HOSTS ##################

# host management
_host() {
    declare listpath="$CONF_PATH/hosts" line newline ip site msg
    declare -a list newlist words sites ip6 cache
    declare -i found=0

    mapfile -t list <"$listpath"

    for line in "${list[@]}"; do
        read -ra words <<<"$line"
        ip="${words[0]}"
        # IP address
        if is_ip4 "$ip" || is_ip6 "$ip"; then
            sites=()
            for site in "${words[@]:1}"; do
                [[ $site == $NAME ]] && found=1 || sites+=("$site")
            done

            if ((${#sites[@]} > 0)); then

                printf -v newline '%s\t%s' "$ip" "${sites[*]}"
                cache+=("$newline")

                if is_ip6 "$ip" && ((!$KEEP)); then
                    ip6+=("${cache[@]}")
                else
                    newlist+=("${cache[@]}")
                fi
                cache=()

            fi

        elif [[ $ip == '#'* ]]; then
            cache+=("$line")
        fi
    done

    # add new host
    if [[ $CMD == $CMD_ADD ]]; then
        printf -v newline '%s\t%s' "$LOCALHOST" "$NAME"
        newlist+=("$newline")
    fi

    # any IP6 items?
    ((${#ip6[@]})) && newlist+=($'\n' "${ip6[@]}")

    if [[ $CMD == $CMD_ADD && $found -eq 0 || $CMD == $CMD_RM && $found -eq 1 ]]; then
        backup "$listpath"
        printf -v line '%s\n' "${newlist[@]}"
        msg="Host '$NAME' "
        [[ $CMD == $CMD_ADD ]] && msg+='added.' || msg+='removed.'
        write "$line" "$listpath" && addmsg "$msg"
    fi

    return 0
}

# IP hosts management
host() {
    declare title='Hosts'

    SHORT=-hn:
    LONG=host,name:
    _optarg "$@"
    msgclr
    _host
    msgout
}
