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

_pool_add() {
	declare pooldef path="$PHP_PATH/$PHPV/fpm/pool.d"

	# PHP version isn't installed
	[[ ! -d $path ]] && addmsg "PHP version '$PHPV' isn't installed or is awkward." $MSG_TYPE_ERR

	# pool definition already exists
	[[ -f $path/$NAME.conf ]] && addmsg "Pool '$NAME' PHP $PHPV FPM definition already exists." $MSG_TYPE_ERR

	((ERR_CNT > 0)) && return 1

	pooldef="$(pool_tpl "$NAME" "$SITE_USER" "$SITE_GROUP" "$LISTEN_OWNER" "$LISTEN_GROUP")"
	write "$pooldef" "$path/$NAME.conf" &&
		addmsg "Pool '$NAME' PHP $PHPV FPM definition created."

	return 0
}

_pool_rm() {
	declare phpv path

	if (($FORCE)); then
		for phpv in "${PHP_LIST[@]}"; do
			path="$PHP_PATH/$phpv/fpm/pool.d/$NAME.conf"
			[[ -f $path ]] && sudo rm "$path" && addmsg "Pool '$NAME' PHP $phpv FPM definition removed."
		done
	else
		path="$PHP_PATH/$PHPV/fpm/pool.d/$NAME.conf"
		[[ -f $path ]] && sudo rm "$path" && addmsg "Pool '$NAME' PHP $PHPV FPM definition removed."
	fi
}

# FMT pools management
pool() {
	SHORT=-fn:p:
	LONG=force,name:,php:

	_optarg "$@"
	msgclr

	if [[ $CMD == $CMD_ADD ]]; then
		_pool_add
	elif [[ $CMD == $CMD_RM ]]; then
		_pool_rm
	else
		addmsg "Command not recognized: $CMD" $MSG_TYPE_ERR
	fi

	msgout
}
