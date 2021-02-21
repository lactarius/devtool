############### VARIABLES ##############

# system variables
declare SITE_USER="$USER"
declare SITE_GROUP="$USER"
declare LISTEN_OWNER='www-data'
declare LISTEN_GROUP='www-data'
declare LOCALHOST='127.0.0.1'
declare CFG_EXT='.conf'
# paths
declare HOME_PATH="/home/$USER"
declare DEV_PATH="$HOME_PATH/virt"
declare CONF_PATH="/etc"
declare LOG_PATH="/var/log/nginx"
declare HTTP_PATH="$CONF_PATH/nginx"
declare HTTP_AVAILABLE="$HTTP_PATH/sites-available"
declare HTTP_ENABLED="$HTTP_PATH/sites-enabled"
declare HTTP_EXT_PATH="common"
declare PHP_PATH="$CONF_PATH/php"
declare PHP_LIST=($(ls $PHP_PATH))
declare DNS_PATH="$CONF_PATH/hosts"
declare DEF_ROOT="www"
# optargs
declare PARSED CMD SHORT LONG NAME PHPV ROOT="$DEF_ROOT"
declare -i NPOSARG FORCE KEEP SOURCE
declare -a POSARG
# UI
declare -a MSG MSG_TYPE SVC_LIST SVC_STATUS SITE_LIST SITE_ENABLED SITE_POOL SITE_SEL
declare -i CLI=1 NAME_MAX_LENGTH MSG_MAX_LENGTH ERR_CNT=0
declare MSG_TYPE_COM=0
declare MSG_TYPE_WRN=1
declare MSG_TYPE_ERR=2
# CLI
declare MSG_TITLE_COLOR=yellow
declare -a MSG_COLOR=(green yellow red) ITEM_COLOR=(red green)
# commands
declare CMD_ADD='add'
declare CMD_RM='rm'
declare CMD_ENA='ena'
declare CMD_DIS='dis'
declare CMD_LIST='ls'
declare CMD_HELP='help'
