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

# search value in array
# $1 - needle
# $2 - array haystack name
# $3 - return - 0 - print found index, 1 - -//- value
# $4 - compare - 0 - string ==, 1 - regular =~, 2 - numeric ==
# $5 - first or all 0 - first match 1 - all matches
# $6 - matches array name
# returns 0 when found
searcharray() {
    declare value="$1" item result
    declare -n haystack=$2 retarr=$6
    declare -i retval=${3:-0} comp=${4:-0} all=${5:-0} i cnt=${#haystack[@]} found=0

    for ((i = 0; i < cnt; i++)); do
        item="${haystack[$i]}"
        if [[ $comp -eq 0 && $item == $value ]] ||
            [[ $comp -eq 1 && $item =~ $value ]] ||
            ((comp == 2 && item == value)); then
            ((!retval)) && item=$i
            if ((all)); then
                retarr+=("$item")
            else
                found=1
                break
            fi
        fi
    done
    ((!found)) && return 1
    echo "$item"
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

# PHP current version number
# PHP 8.0.3 (cli) => 8.0
phpver() {
    php -v | sed -e '/^PHP/!d' -e 's/.* \([0-9]\+\.[0-9]\+\).*$/\1/'
}

# PHP version without period
# $1 - PHP version
# 7.4 => 74
phpversim() {
    echo "${1//./}"
}

# extract PHP version from extended name
# $1 - extended site name
# site74 => 7.4
phpextver() {
    declare sim="${1:(-2)}"
    echo "${sim:0:1}.${sim:1}"
}
