#!/bin/bash
set -euo pipefail

# Paths
## Home Assistant
APP_PATH="/home/tyler-hill/home-assistant"
HOME_ASSISTANT_BACKUP_PATH="$APP_PATH/config/backups"

## Script environment variables
ENV_FILE="$APP_PATH/.env.backup"

## Local backup
DRIVE_PATH="/mnt/Backup"
BACKUP_PATH="$DRIVE_PATH/home-assistant-backup"

## Remote backup
REMOTE_HOST="tyler-hill@tyler-hill-mimi-laptop.reedfish-triceratops.ts.net"
REMOTE_BACKUP_PATH="/home/tyler-hill/home-assistant-backup"

# Load script environment variables if file exists
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

# Local backup
## Check drive mount, trigger automount if configured
if ! mountpoint -q "$DRIVE_PATH"; then
    echo "Local: Backup drive not mounted, aborting" >&2
    exit 1
fi

## Copy to backup path
cp -a "$HOME_ASSISTANT_BACKUP_PATH/." "$BACKUP_PATH"

## Send heartbeat
if [ -n "${KUMA_PUSH_URL_LOCAL:-}" ]; then
  curl -fsS -m 10 --retry 3 -G "$KUMA_PUSH_URL_LOCAL" --data-urlencode "status=${KUMA_STATUS_LOCAL:-up}" --data-urlencode "msg=${KUMA_MSG_LOCAL:-OK}" > /dev/null
fi

# Remote backup
## Make directory if it does not exist
ssh "$REMOTE_HOST" "mkdir -p '$REMOTE_BACKUP_PATH'"

## Copy to backup path
scp -r -q "$HOME_ASSISTANT_BACKUP_PATH/." "$REMOTE_HOST:$REMOTE_BACKUP_PATH/"

## Send heartbeat
if [ -n "${KUMA_PUSH_URL_REMOTE:-}" ]; then
  curl -fsS -m 10 --retry 3 -G "$KUMA_PUSH_URL_REMOTE" --data-urlencode "status=${KUMA_STATUS_REMOTE:-up}" --data-urlencode "msg=${KUMA_MSG_REMOTE:-OK}" > /dev/null
fi
