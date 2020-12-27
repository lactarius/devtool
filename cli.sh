. var.sh
. color.sh
. util.sh
. ui.sh
. optarg.sh

# draw prepared line
# $1 - color (yellow)
drawline() {
	declare color=${1:-lgray}

	col $color "$UI_LINE"
}

msgclr() {
	MSG=()
	MSG_TYPE=()
	ERR_CNT=0
}

msgout() {
	declare title="$1"
	declare -i i cnt=${#MSG[@]}

	((cnt == 0)) && return 0

	prepareline $MSG_MAX_LENGTH

	col $MSG_TITLE_COLOR "$title"

	drawline
	for ((i = 0; i < cnt; i++)); do
		col ${MSG_COLOR[${MSG_TYPE[$i]}]} "${MSG[$i]}"
	done
	drawline

	msgclr
}

# print service list
svcout() {
	declare color
	declare -i i

	prepareline 14
	col yellow "Service status"
	drawline

	for ((i = 0; i < ${#SVC_LIST[@]}; i++)); do
		col ${ITEM_COLOR[${SVC_STATUS[$i]}]} "${SVC_LIST[$i]}"
	done

	drawline
}

lstout() {
	declare -i i

	prepareline 20
	col yellow "Site list"
	drawline

	for ((i = 0; i < ${#SITE_LIST[@]}; i++)); do
		col ${ITEM_COLOR[${SITE_ENABLED[$i]}]} "${SITE_LIST[$i]}"
	done

	drawline
}

. sys.sh
. envi.sh
. site.sh
. pool.sh
. host.sh
