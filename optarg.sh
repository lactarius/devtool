############### OPTIONS & ARGUMENTS #########

# compatibility TEST
getopt --test 2>/dev/null

if (($? != 4)); then
  echo "GNU's enhanced getopt is required to run this script."
  return 1
fi

# OPTIONS & ARGUMENTS
_optarg() {
  # init
  EXTEND=0
  FORCE=0
  PRESERVE=0
  CMD=
  NAME=
  POSARG=()
  # generate command
  PARSED=$(getopt --options "${SHORT}" --longoptions "${LONG}" --name "$0" -- "$@")
  # options - arguments error
  (($? != 0)) && return 9
  # execute
  eval set -- "${PARSED}"

  while (($# > 0)); do
    case $1 in
      -e | --extend) EXTEND=1 ;;
      -f | --force) FORCE=1 ;;
      -s | --preserve) PRESERVE=1 ;;
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

  # positional arguments
  NPOSARG=${#POSARG[@]}
  ((NPOSARG < 1)) && return 2

  # command word - 1. positional
  CMD="${POSARG[0]}"
  [[ $NPOSARG -gt 1 && -z $NAME ]] && NAME="${POSARG[1]}"
}
