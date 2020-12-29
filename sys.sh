_loadsvc() {
	declare selection line name
	declare -a table

	selection=$(sudo systemctl list-units --type service --all | grep -E 'mariadb|nginx|fpm')
	mapfile -t table <<<"$selection"
	SVC_LIST=()
	SVC_STATUS=()
	for line in "${table[@]}"; do
		name="${line%%.service*}"
		SVC_LIST+=("${name:2}")
		[[ $line =~ 'running' ]] && SVC_STATUS+=(1) || SVC_STATUS+=(0)
	done
}

# service controller
# $1 - command
# $2-X - service(s)
svc() {
	declare cmd=${1:-l} service name
	declare -a sel=("${@:2}") svcact

	case $cmd in
		p) cmd=stop ;;
		r) cmd=restart ;;
		s) cmd=start ;;
		*) cmd=list ;;
	esac
	_loadsvc
	if [[ $cmd != list ]]; then
		for name in "${sel[@]}"; do
			service=$(in_array $name SVC_LIST 1 1)
			in_array $service svcact 1 && continue
			svcact+=("$service")
		done
		for service in "${svcact[@]}"; do
			sudo systemctl $cmd $service
		done
		_loadsvc
	fi
	svcout
}

# version switcher
# $1 - new default version
phpsw() {
	sudo update-alternatives --set php /usr/bin/php$1
	php -v
}
