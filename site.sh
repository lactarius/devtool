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
_site_ena() {
	sudo ln -s "$HTTP_AVAILABLE/$NAME.conf" "$HTTP_ENABLED/" &&
		addmsg "Site '$NAME' enabled."
}

# disable site
_site_dis() {
	[[ -f $HTTP_ENABLED/$NAME.conf ]] &&
		sudo rm "$HTTP_ENABLED/$NAME.conf" &&
		addmsg "Site '$NAME' disabled."
}

_site_add() {
	declare sitedef docroot

	# environment doesn't exist
	[[ ! -d $DEV_PATH ]] && addmsg "The development path doesn't exist. Run 'envi prep' first." $MSG_TYPE_ERR
	# site path already exists
	[[ -d $DEV_PATH/$NAME ]] && addmsg "Site '$NAME' development path already exists." $MSG_TYPE_ERR
	# site definition already exists
	[[ -f $HTTP_AVAILABLE/$NAME.conf ]] && addmsg "Site '$NAME' definition already exists." $MSG_TYPE_ERR

	((ERR_CNT > 0)) && return 1

	# site definition
	docroot="$(readlink -m "$DEV_PATH/$NAME/$ROOT")"
	sitedef="$(site_tpl "$NAME" "$docroot" "$LOG_PATH")"
	write "$sitedef" "$HTTP_AVAILABLE/$NAME.conf" &&
		addmsg "Site '$NAME' definition added."

	# index file
	if mkdir "$DEV_PATH/$NAME"; then
		#MSG+=("Site '$NAME' development path added.")
		addmsg "Site '$NAME' development path added."
		[[ ! -d $docroot ]] && mkdir -p "$docroot"
		write "$(index_tpl)" "$docroot/index.php" &&
			addmsg "Testing index.php file added."
	fi

	return 0
}

_site_rm() {
	[[ -d $DEV_PATH/$NAME ]] && rm -rf "$DEV_PATH/$NAME" &&
		addmsg "Site '$NAME' development path removed."
	[[ -f $HTTP_AVAILABLE/$NAME.conf ]] && sudo rm "$HTTP_AVAILABLE/$NAME.conf" &&
		addmsg "Site '$NAME' definition removed."
}

_site_list() {
	declare site curdir
	declare -i enabled

	SITE_ENABLED=()
	curdir=$PWD
	cd "$DEV_PATH"
	SITE_LIST=($(ls -d */ | sed 's#/##'))
	cd "$curdir"
	for site in "${SITE_LIST[@]}"; do
		[[ -f $HTTP_ENABLED/$site.conf ]] && enabled=1 || enabled=0
		SITE_ENABLED+=($enabled)
	done
	lstout
}

# site management
site() {
	declare title

	SHORT=-fn:r:p:
	LONG=force,name:,root:,php:
	_optarg "$@"
	msgclr

	case $CMD in
		$CMD_ADD)
			title='Adding site'
			_site_add && _pool_add && _host && _site_ena
			;;
		$CMD_RM)
			title='Removing site'
			_site_dis
			_host
			_pool_rm
			_site_rm
			;;
		$CMD_ENA) title='Enabling site' && _site_ena ;;
		$CMD_DIS) title='Disabling site' && _site_dis ;;
		$CMD_LIST) _site_list ;;
		*) addmsg "Command not recognized: $CMD" $MSG_TYPE_ERR ;;
	esac
	msgout "$title"
}
