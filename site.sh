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

# enable site
# $1 - name ($NAME)
_site_ena() {
    declare name="${1:-$NAME}"

    [[ -f $HTTP_AVAILABLE/$name$CFG_EXT && ! -L $HTTP_ENABLED/$name$CFG_EXT ]] &&
        sudo ln -s "$HTTP_AVAILABLE/$name$CFG_EXT" "$HTTP_ENABLED/" &&
        addmsg "Site '$name' enabled."
}

# disable site
# $1 - name ($NAME)
_site_dis() {
    declare name="${1:-$NAME}"

    [[ -L $HTTP_ENABLED/$name$CFG_EXT ]] &&
        sudo rm "$HTTP_ENABLED/$name$CFG_EXT" &&
        addmsg "Site '$name' disabled."
}

# add site
_site_add() {
    declare sitedef docroot="$(readlink -m "$DEV_PATH/$NAME/$ROOT")"

    # site name empty
    [[ -z $NAME ]] && addmsg "Site name empty." $MSG_TYPE_ERR && return 1

    # environment doesn't exist
    [[ ! -d $DEV_PATH ]] &&
        addmsg "The development path doesn't exist. Run 'envi prep' first." $MSG_TYPE_ERR &&
        return 1

    # HTTP definition already exists
    [[ -f $HTTP_AVAILABLE/$NAME$CFG_EXT ]] &&
        addmsg "Site '$NAME' definition already exists." $MSG_TYPE_ERR &&
        return 1

    # project path exists
    if [[ -d $DEV_PATH/$NAME ]]; then
        # index.php existence
        indexpath=$(find "$DEV_PATH/$NAME" -name 'index.php')
        # use original docroot if exist
        [[ -n $indexpath ]] && docroot="$(dirname $indexpath)"
    else
        mkdir "$DEV_PATH/$NAME" && addmsg "Site '$NAME' project path added."
    fi

    # document root doesn't exist
    [[ ! -d $docroot ]] && mkdir -p "$docroot" && addmsg "Site '$NAME' document root path added"

    # index.php file doesn't exist or force
    [[ -z $indexpath || $FORCE -eq 1 ]] &&
        write "$(index_tpl)" "$docroot/index.php" &&
        addmsg "Site '$NAME' testing index.php file added."

    # site definition
    sitedef="$(site_tpl "$NAME" "$docroot" "$LOG_PATH")"
    write "$sitedef" "$HTTP_AVAILABLE/$NAME$CFG_EXT" &&
        addmsg "Site '$NAME' definition added."

    return 0
}

# remove site
_site_rm() {
    [[ $SOURCE -eq 0 && -d $DEV_PATH/$NAME ]] && rm -rf "$DEV_PATH/$NAME" &&
        addmsg "Site '$NAME' development path removed."
    [[ -f $HTTP_AVAILABLE/$NAME$CFG_EXT ]] && sudo rm "$HTTP_AVAILABLE/$NAME$CFG_EXT" &&
        addmsg "Site '$NAME' definition removed."
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

    SHORT=-hn:p:r:s
    LONG=host,name:,php:,root:,source
    _optarg "$@"
    msgclr

    case $CMD in
        $CMD_ADD)
            title="Adding site $NAME"
            _site_add && _pool_add && _host && _site_ena
            ;;
        $CMD_RM)
            title="Removing site $NAME"
            _site_dis
            _host
            _pool_rm
            _site_rm
            ;;
        $CMD_ENA) title="Enabling site $NAME" && _site_ena ;;
        $CMD_DIS) title="Disabling site $NAME" && _site_dis ;;
        $CMD_LIST)
            _site_list
            lstout
            ;;
        $CMD_HELP) _site_help ;;
        *) _gui_site ;;
    esac
    msgout "$title"
}
