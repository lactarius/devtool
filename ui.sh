############### UI ###################

declare UI_LINE

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

# add message to stack
# 1 - message
# 2 - type (0)
#     0 - general, 1 - warning, 2 - error
addmsg() {
    declare text="$1"
    declare -i type=${2:-$MSG_TYPE_COM} length

    length=${#text}
    ((length > MSG_MAX_LENGTH)) && MSG_MAX_LENGTH=$length
    MSG+=("$text")
    MSG_TYPE+=($type)
    ((type == 2)) && ERR_CNT+=1
}

# fill variable with pattern
# $1 - line length (20)
# $2 - pattern character(s) (-)
prepareline() {
    declare -i length=${1:-20}
    declare char=${2:-'-'}

    printf -v UI_LINE "%0.s${char}" $(seq 1 $length)
}

############### GUI ################

# site checklist
_gi_site_checklist() {
    declare arglist status sel
    declare -i i cnt=${#SITE_LIST[@]} maxlen

    ((cnt == 0)) && return 0
    for ((i = 0; i < cnt; i++)); do
        arglist+=" $((i + 1)) ${SITE_LIST[$i]}"
        ((${SITE_ENABLED[i]})) && status=ON || status=OFF
        arglist+=" $status"
    done
    sel=$(whiptail --title "Site status" --separate-output --checklist "" \
        $((cnt + 6)) $((NAME_MAX_LENGTH + 20)) $cnt \
        $arglist 3>&1 1>&2 2>&3)
    (($?)) && return 1
    mapfile -t SITE_SEL <<<"$sel"
}

# site add GI
_gi_site_add() {
    NAME=$(whiptail --inputbox "Site name" 8 80 "$NAME" 3>&1 1>&2 2>&3)
    [[ -z $NAME ]] && return 1

    ROOT=$(whiptail --inputbox "Site '$NAME' document root" 8 80 "$ROOT" 3>&1 1>&2 2>&3)
    [[ -z $ROOT ]] && return 1

    PHPV=$(whiptail --inputbox "Site '$NAME' --root=$ROOT PHP version" 8 80 "$PHPV" 3>&1 1>&2 2>&3)
    [[ -z $PHPV ]] && return 1

    echo "$NAME --root=$ROOT --php=$PHPV"
}

# site management GI
_gi_site() {
    declare choice def

    CLI=0
    while ((1)); do

        choice=$(whiptail --title "Site" --menu "" 18 100 10 \
            "list" "List existing projects & set mode" \
            "add" "Add new site" \
            "remove" "Remove existing site" 3>&1 1>&2 2>&3)

        case $choice in
            list)
                _site_list && _gi_site_checklist && _site_change_list
                ;;
            add)
                def="$(_gi_site_add)"
                [[ -n $def ]] && site add $def
                ;;
            *) break ;;
        esac

    done
    CLI=1
}
