############### SITE ##################

# site definition
# $1 - site name
# $2 - document root path
# $3 - log path
site_tpl() {
    cat <<EOT
server {
	listen 80;
	server_name $1;
	charset     utf-8;

	root $2;

	error_log   $3/$1.error.log;
	access_log  $3/$1.access.log;

    include common/common.conf;
    include common/php.conf;
    include common/nette.conf;
}
EOT
}

# testing index.php file
index_tpl() {
    cat <<EOT
<?php phpinfo();
EOT
}

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

# host records management
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
                [[ $site == $URLNAME ]] && found=1 || sites+=("$site")
            done

            if ((${#sites[@]} > 0)); then

                printf -v newline '%s\t%s' "$ip" "${sites[*]}"
                cache+=("$newline")

                if is_ip6 "$ip"; then
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
        printf -v newline '%s\t%s' "$LOCALHOST" "$URLNAME"
        newlist+=("$newline")
    fi

    # any IP6 items?
    ((${#ip6[@]})) && newlist+=($'\n' "${ip6[@]}")

    if [[ $CMD == $CMD_ADD && $found -eq 0 || $CMD == $CMD_RM && $found -eq 1 ]]; then
        printf -v line '%s\n' "${newlist[@]}"
        msg="Host '$URLNAME' "
        [[ $CMD == $CMD_ADD ]] && msg+='added.' || msg+='removed.'
        write "$line" "$listpath" && addmsg "$msg"
    fi

    return 0
}

# enable site
# $1 - name ($NAME)
_site_ena() {
    declare name="${1:-$URLNAME}"

    [[ -f $HTTP_AVAILABLE/$name$CFG_EXT && ! -L $HTTP_ENABLED/$name$CFG_EXT ]] &&
        sudo ln -s "$HTTP_AVAILABLE/$name$CFG_EXT" "$HTTP_ENABLED/" &&
        addmsg "Site '$name' enabled."
}

# disable site
# $1 - name ($NAME)
_site_dis() {
    declare name="${1:-$URLNAME}"

    [[ -L $HTTP_ENABLED/$name$CFG_EXT ]] &&
        sudo rm "$HTTP_ENABLED/$name$CFG_EXT" &&
        addmsg "Site '$name' disabled."
}

# add site
_site_add() {
    declare docroot="$(readlink -m "$DEV_PATH/$NAME/$ROOT")"
    declare sitedef pooldef poolpath="$PHP_PATH/$PHPV/fpm/pool.d"
    declare sitepath="$HTTP_AVAILABLE/$URLNAME$CFG_EXT"

    # site name empty
    [[ -z $NAME ]] && addmsg "Site name empty." $MSG_TYPE_ERR
    # environment doesn't exist
    [[ ! -d $DEV_PATH ]] && addmsg "The development path doesn't exist. Run 'envi set' first." $MSG_TYPE_ERR
    # HTTP definition already exists
    [[ -f $sitepath ]] && addmsg "Site '$URLNAME' HTTP definition already exists." $MSG_TYPE_ERR
    # PHP version isn't installed
    [[ ! -d $poolpath ]] && addmsg "PHP version '$PHPV' isn't installed or is awkward." $MSG_TYPE_ERR
    # pool definition already exists
    [[ -f $poolpath/$NAME$CFG_EXT ]] && addmsg "Pool '$NAME' FPM definition for PHP$PHPV already exists." $MSG_TYPE_ERR

    ((ERR_CNT > 0)) && return 1

    # project path exists
    if [[ -d $DEV_PATH/$NAME ]]; then
        # index.php existence
        indexpath=$(find "$DEV_PATH/$NAME" -name 'index.php')
        # use original docroot if exist
        [[ -n $indexpath && $FORCE -ne 1 ]] && docroot="$(dirname $indexpath)"
    else
        mkdir "$DEV_PATH/$NAME" && addmsg "Site '$NAME' project path added."
    fi
    # document root doesn't exist
    [[ ! -d $docroot ]] && mkdir -p "$docroot" && addmsg "Site '$NAME' document root path added"
    # index.php file doesn't exist or force
    [[ -z $indexpath || $FORCE -eq 1 ]] &&
        write "$(index_tpl)" "$docroot/index.php" &&
        addmsg "Site '$NAME' testing index.php file added."
    # site HTTP definition
    sitedef="$(site_tpl "$URLNAME" "$docroot" "$LOG_PATH")"
    write "$sitedef" "$sitepath" &&
        addmsg "Site '$URLNAME' HTTP definition added."
    # POOL
    pooldef="$(pool_tpl "$URLNAME" "$SITE_USER" "$SITE_GROUP" "$LISTEN_OWNER" "$LISTEN_GROUP")"
    write "$pooldef" "$poolpath/$NAME$CFG_EXT" &&
        addmsg "Pool '$NAME' FPM definition for PHP$PHPV created."

    return 0
}

# remove site
_site_rm() {
    declare poolpath="$PHP_PATH/$PHPV/fpm/pool.d/$NAME$CFG_EXT"
    declare sitepath="$HTTP_AVAILABLE/$URLNAME$CFG_EXT"
    declare devpath="$DEV_PATH/$NAME"

    # fpm definition
    [[ -f $poolpath ]] && sudo rm "$poolpath" && addmsg "Pool '$NAME' FPM definition for PHP$PHPV removed."
    # http definition
    [[ -f $sitepath ]] && sudo rm "$sitepath" && addmsg "Site '$URLNAME' HTTP definition removed."
    # remove sorces only with --force
    [[ -d $devpath && $FORCE -eq 1 ]] && rm -r "$devpath" && addmsg "Site '$NAME' development path removed."
}

# remove all extensions
_site_rm_ext() {
    for PHPV in "${PHP_LIST[@]}"; do
        URLNAME="$NAME$(phpversim $PHPV)"
        _site_dis
        _host
        _site_rm
    done
}

# list sites
_site_list() {
    declare site curdir
    declare -i enabled len

    SITE_ENABLED=()
    SITE_POOL=()
    NAME_MAX_LENGTH=0

    curdir="$PWD"
    cd "$HTTP_AVAILABLE"
    SITE_LIST=($(ls *$CFG_EXT | sed "s/$CFG_EXT$//"))
    cd "$curdir"

    for site in "${SITE_LIST[@]}"; do
        len=${#site}
        ((len > NAME_MAX_LENGTH)) && NAME_MAX_LENGTH=$len
        [[ -L $HTTP_ENABLED/$site$CFG_EXT ]] && enabled=1 || enabled=0
        SITE_ENABLED+=($enabled)
        SITE_POOL+=($(_pool_check "$site"))
    done
}

# toggle selected sites status
_site_change_list() {
    declare name

    for name in "${SITE_LIST[@]}"; do
        if contains $name SITE_SEL; then
            _site_ena $name
        else
            _site_dis $name
        fi
    done
}

# site management
site() {
    declare title

    # with no arguments call TUI
    [[ -z ${1} ]] && _gui_site

    SHORT=-fn:p:r:
    LONG=force,name:,php:,root:
    _optarg "$@" || return 5
    msgclr

    ((EXTEND)) && URLNAME="$NAME$(phpversim $PHPV)" || URLNAME=$NAME

    case $CMD in
        $CMD_ADD)
            title="Adding site $URLNAME"
            _site_add && _host && _site_ena
            ;;
        $CMD_RM)
            title="Removing site $URLNAME"
            _site_dis
            _host
            _site_rm
            ((!EXTEND)) && _site_rm_ext
            ;;
        $CMD_ENA) title="Enabling site $URLNAME" && _site_ena ;;
        $CMD_DIS) title="Disabling site $URLNAME" && _site_dis ;;
        $CMD_LIST)
            _site_list
            lstout
            ;;
        $CMD_HELP) _site_help ;;
        *) addmsg "Command not recognized: $CMD" $MSG_TYPE_ERR ;;
    esac
    msgout "$title"
}
