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

# clean msg stack
msgclr() {
    MSG=()
    MSG_TYPE=()
    ERR_CNT=0
}

# printout messages
# $1 - title (notification)
# $2 - line length (max msg length)
msgout() {
    declare title="${1:-'Notification'}" hight text
    declare -i i cnt=${#MSG[@]} linelength=${2:-$MSG_MAX_LENGTH} err

    ((cnt == 0)) && return 0
    if ((CLI)); then

        prepareline $linelength
        col $MSG_TITLE_COLOR "$title"
        drawline
        for ((i = 0; i < cnt; i++)); do
            col ${MSG_COLOR[${MSG_TYPE[$i]}]} "${MSG[$i]}"
        done
        drawline

    else

        for ((i = 0; i < cnt; i++)); do

            ((i > 0)) && text+="\n"
            text+="${MSG[$i]}"
            ((${MSG_TYPE[i]} == MSG_TYPE_ERR)) && ((err++))

        done

        ((err)) && title+=" ERRORS !"
        whiptail --title "$title" --msgbox "$text" $((cnt + 6)) 100

    fi

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

# print site list
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