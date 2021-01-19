# system variables
SITE_USER="$USER"
SITE_GROUP="$USER"
LISTEN_OWNER="www-data"
LISTEN_GROUP="www-data"
LOCALHOST='127.0.0.1'

# paths
HOME_PATH="/home/$USER"
DEV_PATH="$HOME_PATH/virt"
CONF_PATH="/etc"
LOG_PATH="/var/log/nginx"
HTTP_PATH="$CONF_PATH/nginx"
HTTP_AVAILABLE="$HTTP_PATH/sites-available"
HTTP_ENABLED="$HTTP_PATH/sites-enabled"
HTTP_EXT_PATH="common"
PHP_PATH="$CONF_PATH/php"
PHP_LIST=($(ls $PHP_PATH))
DNS_PATH="$CONF_PATH/hosts"
DEF_ROOT="www"

# UI
declare -a MSG MSG_TYPE SVC_LIST SVC_STATUS SITE_LIST SITE_ENABLED SITE_SEL
declare -i CLI=1 NAME_MAX_LENGTH MSG_MAX_LENGTH ERR_CNT=0
MSG_TYPE_COM=0
MSG_TYPE_WRN=1
MSG_TYPE_ERR=2

# CLI
MSG_TITLE_COLOR=yellow
declare -a MSG_COLOR=(green yellow red) ITEM_COLOR=(red green)

# commands
CMD_ADD='add'
CMD_RM='rm'
CMD_ENA='ena'
CMD_DIS='dis'
CMD_LIST='ls'
declare -i BACKUP_OFF=0
BACKUP_EXT='bak'
