_envi_set() {
  declare common_path="$HTTP_PATH/$HTTP_EXT_PATH"

  # NginX is not installed
  [[ ! -x /usr/sbin/nginx ]] && addmsg "NginX server is not installed." $MSG_TYPE_ERR
  # extended settings directory already exists
  [[ -d $common_path ]] && addmsg "Extended settings directory already exists." $MSG_TYPE_ERR
  # virtual sites path already exists
  [[ -d $DEV_PATH ]] && addmsg "Virtual sites path already exists." $MSG_TYPE_ERR

  ((ERR_CNT > 0)) && return 1

  sudo mkdir "$common_path" &&
    write "$(common_tpl)" "$common_path/common.conf" &&
    write "$(nette_tpl)" "$common_path/nette.conf" &&
    write "$(php_tpl)" "$common_path/php.conf" &&
    addmsg "NginX extended settings added."

  mkdir "$DEV_PATH" && addmsg "Virtual sites path added."
}

_envi_unset() {
  [[ -d $DEV_PATH ]] && rm -r "$DEV_PATH" && addmsg "The development path removed."
  [[ -d $HTTP_PATH/$HTTP_EXT_PATH ]] && sudo rm -r "$HTTP_PATH/$HTTP_EXT_PATH" &&
    addmsg "NginX extended settings removed."
}
