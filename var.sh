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
declare DOC_ROOT="www"
# optargs
declare PARSED CMD SHORT LONG NAME URLNAME PHPV ROOT
declare -i NPOSARG EXTEND FORCE
declare -a POSARG
declare SVC_LIST SVC_OP SVC_STATUS SITE_LIST SITE_ENABLED SITE_POOL SITE_SEL
# commands
declare CMD_ADD='add'
declare CMD_RM='rm'
declare CMD_ENA='ena'
declare CMD_DIS='dis'
declare CMD_LIST='ls'
declare CMD_HELP='help'
