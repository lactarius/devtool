############### ENVIRONMENT ###############

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

# prepare envi
_envi_add() {
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

# remove envi
_envi_rm() {
  [[ -d $DEV_PATH ]] && rm -r "$DEV_PATH" && addmsg "The development path removed."
  [[ -d $HTTP_PATH/$HTTP_EXT_PATH ]] && sudo rm -r "$HTTP_PATH/$HTTP_EXT_PATH" &&
    addmsg "NginX extended settings removed."
}

# manage environment
envi() {
  declare title

  SHORT=-f
  LONG=force
  _optarg "$@"
  (($? > 1)) && return 2

  msgclr
  case $CMD in
    $CMD_ADD)
      title="Preparing environment"
      ((FORCE)) && _envi_rm
      _envi_add
      ;;
    $CMD_RM)
      title="Removing environment"
      _envi_rm
      ;;
    *)
      title="Error"
      addmsg "Command not recognized: $CMD" MSG_TYPE_ERR
      ;;
  esac
  msgout "$title"
}
