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

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[ERROR] Config file $CONFIG_FILE not found!" | tee -a "$LOG_FILE"
  exit 1
fi

mkdir -p "$DEST_DIR"


DATE=$(date +"%Y-%m-%d_%H-%M-%S")

echo "=== Backup Started at $(date) ===" >> "$LOG_FILE"

while read -r LINE; do

  [[ -z "$LINE" || "$LINE" == \#* ]] && continue

  SRC_PATH=$(echo "$LINE" | awk '{print $1}')
  EXTENSION=$(echo "$LINE" | awk '{print $2}')

  NAME=$(basename "$SRC_PATH")
  ARCHIVE_NAME="${NAME}_${DATE}.tar.gz"
  DEST_PATH="${DEST_DIR}/${ARCHIVE_NAME}"

  if [[ "$EXTENSION" == "*" ]]; then
    FILES=$(find "$SRC_PATH" -type f)
  else
    FILES=$(find "$SRC_PATH" -type f -name "*.${EXTENSION}")
  fi


