############### OPTIONS & ARGUMENTS #########

# compatibility TEST
getopt --test 2>/dev/null

if (($? != 4)); then
    echo "GNU's enhanced getopt is required to run this script."
    return 1
fi

# VARIABLES
declare CMD NAME ROOT="$DEF_ROOT" PHPV="$(phpver)"
declare -i HOST_ORIG SOURCE
declare PARSED
declare -a POSARG
declare -i NPOSARG
declare SHORT LONG

# OPTIONS & ARGUMENTS
_optarg() {
    CMD=''
    HOST_ORIG=0
    NAME=''
    SOURCE=0
    POSARG=()

    PARSED=$(getopt --options "${SHORT}" --longoptions "${LONG}" --name "$0" -- "$@")
    # options - arguments error
    (($? != 0)) && return 9

    eval set -- "${PARSED}"

    while (($# > 0)); do
        case $1 in
            -h | --host) HOST_ORIG=1 ;;
            -n | --name)
                shift
                NAME="$1"
                ;;
            -p | --php)
                shift
                PHPV="$1"
                ;;
            -r | --root)
                shift
                ROOT="$1"
                ;;
            -s | --source) SOURCE=1 ;;
            --) break ;;
            *) POSARG+=("$1") ;;
        esac
        shift
    done

    NPOSARG=${#POSARG[@]}
    ((NPOSARG < 1)) && return 1

    CMD="${POSARG[0]}"
    [[ $NPOSARG -gt 1 && -z $NAME ]] && NAME="${POSARG[1]}"
}
