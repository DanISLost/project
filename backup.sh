#!/bin/bash

CONFIG_FILE="backup.conf"
DEST_DIR="/home/user/backups"
LOG_FILE="backup.log"
RETENTION_DAYS=7
DRY_RUN=false

if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[INFO] Running in dry-run mode." >> "$LOG_FILE"
fi
