#!/usr/bin/env bash
############### OPTARG ######################
declare ROOT='www'
declare PHPV='8.0'
############### OTHER VARIABLES #############
declare SHORT LONG PARSED
declare -i EXTEND FORCE PRESERVE
declare -a POSARG

# test if sourced or executed
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

############### TEMPLATES ###################
# NginX
# common
common_tpl() {
  cat <<'EOT'
index index.html index.htm;

error_page   500 502 503 504  /50x.html;
location = /50x.html {
	root   html;
}

#location ~ \.(js|ico|gif|jpg|png|css|rar|zip|tar\.gz)$ { }

location ~ /\.(ht|gitignore) { # deny access to .htaccess files, if Apache's document root concurs with nginx's one
    deny all;
}

location ~ \.(neon|ini|log|yml)$ { # deny access to configuration files
    deny all;
}

location = /robots.txt  { access_log off; log_not_found off; }
location = /humans.txt  { access_log off; log_not_found off; }
location = /favicon.ico { access_log off; log_not_found off; }

proxy_buffer_size   128k;
proxy_buffers   4 256k;
proxy_busy_buffers_size   256k;

fastcgi_buffers 8 16k; fastcgi_buffer_size 32k;

client_max_body_size 45M;
client_body_buffer_size 128k;
EOT
}

# nette
nette_tpl() {
  cat <<'EOT'
try_files $uri $uri/ /index.php?$args;
EOT
}

# php
php_tpl() {
  cat <<'EOT'
index index.php index.html index.htm;

location ~ \.php$ {
	fastcgi_send_timeout 1800;
	fastcgi_read_timeout 1800;
	fastcgi_connect_timeout 1800;
	#fastcgi_pass	127.0.0.1:9000;
	fastcgi_pass	unix:/run/php/$server_name.sock;
	fastcgi_index	index.php;
	fastcgi_param	SCRIPT_FILENAME $document_root$fastcgi_script_name;
	include		fastcgi_params;
}
EOT
}

# compatibility TEST
getopt --test 2>/dev/null

if (($? != 4)); then
  echo "GNU's enhanced getopt is required to run this script."
  exit 1
fi

SHORT=-efn:p:r:s
LONG=extend,force,name:,php:,root:,preserve

PARSED=$(getopt --options "${SHORT}" --longoptions "${LONG}" --name "$0" -- "$@")
# options - arguments error
(($? != 0)) && exit 9
# execute
eval set -- "${PARSED}"

while (($# > 0)); do
  case $1 in
    -e | --extend) EXTEND=1 ;;
    -f | --force) FORCE=1 ;;
    -s | --preserve) PRESERVE=1 ;;
    -n | --name)
      shift
      NAME="$1"
      ;;
    -p | --php)
      shift
      PHPV="$1"
      ;;
    -r | --root)
      shift
      ROOT="$1"
      ;;
    --) break ;;
    *) POSARG+=("$1") ;;
  esac
  shift
done

# positional arguments
NPOSARG=${#POSARG[@]}
((NPOSARG < 1)) && exit 2

# command word - 1. positional
CMD="${POSARG[0]}"
[[ $NPOSARG -gt 1 && -z $NAME ]] && NAME="${POSARG[1]}"

echo "$CMD $NAME $ROOT $PHPV"
echo -e "flags: -e $EXTEND -f $FORCE -s $PRESERVE \n"
