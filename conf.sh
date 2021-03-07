############### SETTINGS & DEFAULTS #########
# system variables
declare SITE_USER="$USER"
declare SITE_GROUP="$USER"
declare LISTEN_OWNER='www-data'
declare LISTEN_GROUP='www-data'
declare LOCALHOST='127.0.0.1'
declare CFG_EXT='.conf'
# paths
declare DOC_ROOT="www"
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
############### OTHER GLOBALS #############
# optarg
declare SHORT LONG PARSED NAME ROOT="$DOC_ROOT"
declare -i EXTEND FORCE PRESERVE
declare -a POSARG
