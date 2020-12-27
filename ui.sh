declare UI_LINE

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

	printf -v UI_LINE "%0.s-" $(seq 1 $length)
}
