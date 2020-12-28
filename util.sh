# is string an IPv4 address?
# $1 tested string
is_ip4() {
	[[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# is string an IPv6 address?
# $1 tested string
is_ip6() {
	[[ $1 =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]
}

# sort array alphabetically
# $1 array name
sort_array() {
	local -n array=$1
	IFS=$'\n' array=($(sort <<<"${array[*]}"))
	unset IFS
}

# search for value in array
# $1 - needle
# $2 - haystack
# $3 - comparison type (0)
#      0 == string, 1 =~ string, 2 == integer
# $4 - return (0)
#      0 index, 1 value
in_array() {
	declare value="$1"
	declare -n array=$2
	declare -i i type=${3:-0} ret=${4:-0}

	for ((i = 0; i < ${#array[@]}; i++)); do

		if [[ $type -eq 0 && ${array[$i]} == "$value" ]] ||
			[[ $type -eq 1 && ${array[$i]} =~ $value ]] ||
			[[ $type -eq 2 && ${array[$i]} -eq $value ]]; then

			((ret == 0)) && echo $i || echo "${array[$i]}"
			return 0

		fi

	done
	return 1
}

# write text to file
write() {
	declare text="$1" path="$2"
	if [[ -w $path ]]; then
		printf '%s\n' "$text" >"$path"
	else
		printf '%s\n' "$text" | sudo tee "$path" >/dev/null 2>&1
	fi
}

# create file backup copy
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
