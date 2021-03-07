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
