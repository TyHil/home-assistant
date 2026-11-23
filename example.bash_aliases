# Add to ~/.bash_aliases
function home-assistant-backup() {
	if [ "$1" = "start" ]; then
		shift
		sudo systemctl start home-assistant-backup.timer "$@"
	elif [ "$1" = "backup" ]; then
		shift
		sudo systemctl start home-assistant-backup.service "$@"
	elif [ "$1" = "stop" ]; then
		shift
		sudo systemctl stop home-assistant-backup.timer "$@"
	elif [ "$1" = "status" ]; then
		shift
		systemctl status home-assistant-backup.timer "$@"
	elif [ "$1" = "logs" ]; then
		shift
		systemctl status home-assistant-backup.service "$@"
	elif [ "$1" = "list" ]; then
		shift
		ls /mnt/Backup/home-assistant-backup "$@"
	elif [ "$1" = "list-remote" ]; then
		shift
		ssh tyler-hill@tyler-hill-mimi-laptop.reedfish-triceratops.ts.net "ls /home/tyler-hill/home-assistant-backup" "$@"
	else
		systemctl status home-assistant-backup.service "$@"
	fi
}
