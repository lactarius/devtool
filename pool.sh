############### POOL ################

# fpm pool
# $1 - site name
# $2 - user
# $3 - group
# #4 - listen owner
# #5 - listen group
pool_tpl() {
    cat <<EOT
[$1]
user = $2
group = $3
listen = /run/php/$1.sock
listen.owner = $4
listen.group = $5

pm = dynamic
pm.start_servers = 3
pm.max_children = 5
pm.min_spare_servers = 2
pm.max_spare_servers = 4
chdir = /
EOT
}

# check site pool
# $1 - name ($NAME)
_pool_check() {
    declare phpv name="${1:-$NAME}"

    for phpv in "${PHP_LIST[@]}"; do
        if [[ -f $PHP_PATH/$phpv/fpm/pool.d/$name$CFG_EXT ]]; then
            echo "$phpv"
            return 0
        fi
    done
    return 1
}

# remove FPM pool
_pool_rm() {
    declare phpv path

    phpv="$(_pool_check)"
    [[ -z $phpv ]] && return 1
    path="$PHP_PATH/$phpv/fpm/pool.d/$NAME$CFG_EXT"
    [[ -f $path ]] && sudo rm "$path" && addmsg "Pool '$NAME' PHP $phpv FPM definition removed."
}

# add FPM pool
_pool_add() {
    declare pooldef phpv path="$PHP_PATH/$PHPV/fpm/pool.d"

    # PHP version isn't installed
    [[ ! -d $path ]] && addmsg "PHP version '$PHPV' isn't installed or is awkward." $MSG_TYPE_ERR
    # pool definition already exists
    [[ -f $path/$NAME$CFG_EXT ]] && addmsg "Pool '$NAME' PHP $PHPV FPM definition already exists." $MSG_TYPE_ERR

    ((ERR_CNT > 0)) && return 1

    _pool_rm

    pooldef="$(pool_tpl "$NAME" "$SITE_USER" "$SITE_GROUP" "$LISTEN_OWNER" "$LISTEN_GROUP")"
    write "$pooldef" "$path/$NAME$CFG_EXT" &&
        addmsg "Pool '$NAME' PHP $PHPV FPM definition created."
    return 0
}

# FPM pools management
pool() {
    SHORT=-fn:p:
    LONG=force,name:,php:
    _optarg "$@"
    msgclr
    case $CMD in
        $CMD_ADD) _pool_add ;;
        $CMD_RM) _pool_rm ;;
        *) addmsg "Command not recognized: $CMD" $MSG_TYPE_ERR ;;
    esac
    msgout
}
