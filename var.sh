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
DEF_ROOT="/www"

# UI
declare -a MSG MSG_TYPE SITE_LIST SITE_ENABLED SVC_LIST SVC_STATUS
declare -i CLI=1 MSG_MAX_LENGTH ERR_CNT=0
# messages
MSG_TYPE_COM=0
MSG_TYPE_WRN=1
MSG_TYPE_ERR=2
declare -a MSG_COLOR=(green yellow red)
MSG_TITLE_COLOR=yellow
ITEM_COLOR=(red green)
# commands
CMD_ADD='add'
CMD_RM='rm'
CMD_ENA='ena'
CMD_DIS='dis'
CMD_LIST='list'
CMD_START='start'
CMD_STOP='stop'
CMD_RESTART='restart'
declare -i BACKUP_OFF=0
BACKUP_EXT='bak'
