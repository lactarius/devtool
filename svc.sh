############### SERVICES ################
# version switcher
# $1 - new default version
_phpsw() {
    sudo update-alternatives --set php /usr/bin/php$1
    php -v
}

_svc_load() {
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
        h | help)
            _svc_help
            return 0
            ;;
        v)
            _phpsw "${sel[0]}"
            return 0
            ;;
        p) cmd=stop ;;
        r) cmd=restart ;;
        s) cmd=start ;;
        *) cmd=list ;;
    esac
    _svc_load
    if [[ $cmd != list ]]; then
        for name in "${sel[@]}"; do
            service=$(contains $name SVC_LIST 2 1)
            contains $service svcact && continue
            svcact+=("$service")
        done
        SVC_OP=()
        for service in "${svcact[@]}"; do
            SVC_OP+=("$cmd $service")
            sudo systemctl $cmd $service
        done
        _svc_load
    fi
    svcout
}
