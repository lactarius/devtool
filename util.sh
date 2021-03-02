############### UTILITIES ################

# is string an IPv4 address?
# $1 - tested string
is_ip4() {
  [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# is string an IPv6 address?
# $1 - tested string
is_ip6() {
  [[ $1 =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]
}

# sort array alphabetically
# $1 - array name
sort_array() {
  local -n array=$1
  IFS=$'\n' array=($(sort <<<"${array[*]}"))
  unset IFS
}

# search array for a value
# $1 - needle
# $2 - visible array haystack name
# $3 - 0 - none 1 - print found index, 2 - -//- value
# $4 - 0 - string ==, 1 - regular =~, 2 - numeric ==
# returns 0 when found
contains() {
  declare value="$1" item
  declare -n array=$2
  declare -i retval=${3:-0} comp=${4:-0} i cnt=${#array[@]} found=0

  for ((i = 0; i < cnt; i++)); do
    item="${array[$i]}"
    if [[ $comp -eq 0 && $item == $value ]] ||
      [[ $comp -eq 1 && $item =~ $value ]] ||
      ((comp == 2 && item == value)); then
      found=1
      break
    fi
  done
  ((!found)) && return 1
  case $retval in
    1) echo $i ;;
    2) echo "$item" ;;
  esac
}

# write text to file
# $1 - content
# $2 - file
write() {
  declare text="$1" file="$2"
  if [[ -w $(dirname $file) ]]; then
    printf '%s\n' "$text" >"$file"
  else
    printf '%s\n' "$text" | sudo tee "$file" >/dev/null 2>&1
  fi
}

# create file backup copy
# $1 - file
# $2 - extension
backup() {
  ((BACKUP_OFF)) && return
  declare file="$1" ext="${2:-$BACKUP_EXT}"
  if [[ -w $file ]]; then
    cp "$file" "$file.$ext"
  else
    sudo cp "$file" "$file.$ext"
  fi
}

# PHP current version
phpver() {
  php -v | sed -e '/^PHP/!d' -e 's/.* \([0-9]\+\.[0-9]\+\).*$/\1/'
}

PHPV="$(phpver)"
