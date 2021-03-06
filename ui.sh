############### USER INTERFACE ##############

############### COLORED OUTPUT ##############
declare -A COLORS=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [lgray]=37 [gray]=90 [lred]=91 [lgreen]=92 [lyellow]=93 [lblue]=94 [lmagenta]=95 [lcyan]=96 [white]=97)

# colored output
# $1 - -n - disable new line
# $1 - color
# $2 - text
col() {
    declare ctrl='-e'

    if [[ $1 == '-n' ]]; then
        ctrl='-en'
        shift
    fi
    echo ${ctrl} "\033[0;${COLORS[$1]}m"${@:2}"\033[0m"
}

############### MESSAGES ####################
# UI
declare -a MSG MSG_TYPE MSG_COLOR=(green red) ITEM_COLOR=(red green)
declare -i CLI=1 NAME_MAX_LENGTH MSG_MAX_LENGTH ERR_CNT=0
declare MSG_TYPE_COM=0 MSG_TYPE_ERR=1
declare MSG_TITLE_COLOR=yellow
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
        whiptail --title "$title" --msgbox "$text" $((cnt + 8)) 80

    fi

    msgclr
}

# print service list
svcout() {
    declare op color
    declare -i i

    prepareline 20
    col yellow "Service status"
    drawline
    if ((${#SVC_OP[@]})); then
        for op in "${SVC_OP[@]}"; do
            col ${ITEM_COLOR[1]} "$op"
        done
        drawline
        SVC_OP=()
    fi
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

# site help
_site_help() {
    prepareline 60
    col yellow "Site management"
    drawline
    col -n yellow "add\t"
    col green "Add new site"
    col -n yellow "rm\t"
    col green "Remove site"
    col -n yellow "dis\t"
    col green "Disable site"
    col -n yellow "ena\t"
    col green "Enable site"
    col -n yellow "ls\t"
    col green "List sites"
    col -n yellow "\n--root <path>\t"
    col green "Document root"
    col -n yellow "--php <x.y>\t"
    col green "PHP version"
    col -n yellow "--source\t"
    col green "Preserve sources"
    col -n yellow "--host\t\t"
    col green "Don't touch hosts order"
    col yellow "\nExamples:"
    col green "Add site 'blog', docroot: www, PHP current =>"
    col -n yellow "$ "
    col lgray 'site add blog'
    col green "Add site 'adminer', docroot: /, PHP7.4 =>"
    col -n yellow "$ "
    col lgray 'site add adminer -r / -p 8.0'
    col green "Remove site 'blog' and preserve sources =>"
    col -n yellow "$ "
    col lgray 'site rm blog -s'
    drawline
}

# services help
_svc_help() {
    prepareline 40
    col yellow "Services usage"
    drawline
    col -n yellow "p\t"
    col green "Stop"
    col -n yellow "r\t"
    col green "Restart"
    col -n yellow "s\t"
    col green "Start"
    col yellow "\nExamples:"
    col green "Stop NginX and PHP-FPM 8.0 =>"
    col -n yellow "$ "
    col lgray "svc p ng 8"
    col green "Switch default PHP version to 7.4 =>"
    col -n yellow "$ "
    col lgray "phpsw 7.4"
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

# choose site
# $1 - menu header
_gui_site_choose() {
    declare arglist choice header="$1"
    declare -i i cnt

    _site_list
    cnt=${#SITE_LIST[@]}
    ((cnt == 0)) && return 0

    for ((i = 0; i < cnt; i++)); do
        arglist+=" ${SITE_LIST[$i]} ${SITE_POOL[$i]}"
    done

    choice=$(whiptail --title "Choose site" --menu "$header" \
        $((cnt + 10)) $((NAME_MAX_LENGTH + 20)) $cnt $arglist 3>&1 1>&2 2>&3)
    (($?)) && return 1

    echo "$choice"
}

# PHP version choose
# $1 - menu header
# $2 - except item
_gui_php_choose() {
    declare phpv arglist header="$1" except="$2"
    declare -i cnt=${#PHP_LIST[@]}

    for phpv in "${PHP_LIST[@]}"; do
        [[ $phpv != $except ]] && arglist+=" $phpv PHP-FPM"
    done

    [[ -n $except ]] && cnt=$((cnt - 1))
    phpv=$(whiptail --title "Choose PHP version" --menu "$header" \
        --noitem --default-item "$PHPV" $((cnt + 8)) 30 $cnt $arglist 3>&1 1>&2 2>&3)
    (($?)) && return 1

    echo "$phpv"
}

# site switch PHP version
_gui_site_switch() {
    declare site phpv cur

    site=$(_gui_site_choose "Site to switch PHP version")
    [[ -z $site ]] && return 1

    cur="$(_pool_check "$site")"
    phpv=$(_gui_php_choose "Site '$site' new PHP version" "$cur")
    [[ -z $phpv ]] && return 1

    pool add $site --php=$phpv
}

# site checklist
_gui_site_checklist() {
    declare arglist status select
    declare -i i cnt

    _site_list
    cnt=${#SITE_LIST[@]}
    ((cnt == 0)) && return 0

    for ((i = 0; i < cnt; i++)); do
        arglist+=" ${SITE_LIST[$i]} ${SITE_POOL[$i]}"
        ((${SITE_ENABLED[i]})) && status=ON || status=OFF
        arglist+=" $status"
    done

    select=$(whiptail --title "Project status" --separate-output --checklist "Change site status" \
        $((cnt + 6)) $((NAME_MAX_LENGTH + 20)) $cnt \
        $arglist 3>&1 1>&2 2>&3)
    (($?)) && return 1
    mapfile -t SITE_SEL <<<"$select"

    _site_change_list
}

# site add GUI
_gui_site_add() {
    declare site root phpv

    site=$(whiptail --title "New project" --inputbox "Site name" 8 40 "$NAME" 3>&1 1>&2 2>&3)
    [[ -z $site ]] && return 1

    root=$(whiptail --title "New project" --inputbox "Site '$site' document root" 8 40 "$ROOT" 3>&1 1>&2 2>&3)
    [[ -z $root ]] && return 1

    phpv=$(_gui_php_choose "Site PHP version")
    [[ -z $phpv ]] && return 1

    site add $site --root=$root --php=$phpv
}

# site remove GUI
_gui_site_rm() {
    declare site arglist

    site=$(_gui_site_choose "Remove project")
    [[ -z $site ]] && return 1
    arglist="$site"

    if (whiptail --title "Remove project '$site'" --yesno "Preserve sources ?" 8 30); then
        arglist+=' --source'
    fi

    site rm $arglist
}

# site management GUI
_gui_site() {
    declare choice def name

    CLI=0
    while ((1)); do

        choice=$(
            whiptail --title "Project management" --menu "" 12 50 4 \
                "list" "List existing projects & set mode" \
                "switch" "Switch project PHP version" \
                "add" "Add new project" \
                "remove" "Remove existing project" 3>&1 1>&2 2>&3
        )

        case $choice in
            list) _gui_site_checklist ;;
            add) _gui_site_add ;;
            remove) _gui_site_rm ;;
            switch) _gui_site_switch ;;
            *) break ;;
        esac

    done
    CLI=1
}
