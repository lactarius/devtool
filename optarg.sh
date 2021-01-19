# compatibility TEST
getopt --test 2>/dev/null

if (($? != 4)); then
  echo "GNU's enhanced getopt is required to run this script."
  return 1
fi

# VARIABLES
declare CMD NAME ROOT="$DEF_ROOT" PHPV="$(phpver)"
declare -i FORCE QUIET SIMPLE
declare PARSED
declare -a POSARG
declare -i NPOSARG
declare SHORT LONG

# OPTIONS & ARGUMENTS
_optarg() {
  CMD=''
  FORCE=0
  QUIET=0
  SIMPLE=0
  NAME=''
  POSARG=()

  PARSED=$(getopt --options "${SHORT}" --longoptions "${LONG}" --name "$0" -- "$@")
  # options - arguments error
  (($? != 0)) && return 9

  eval set -- "${PARSED}"

  while (($# > 0)); do
    case $1 in
      -f | --force) FORCE=1 ;;
      -q | --quiet) QUIET=1 ;;
      -s | --simple) SIMPLE=1 ;;
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
