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

  if $DRY_RUN; then
    echo "[DRY-RUN] Would back up files: $FILES" >> "$LOG_FILE"
  else
    if [[ -z "$FILES" ]]; then
      echo "[WARNING] No files found in $SRC_PATH with extension .$EXTENSION" >> "$LOG_FILE"
      continue
    fi
    tar -czf "$DEST_PATH" $FILES 2>>"$LOG_FILE"
    if [[ $? -ne 0 ]]; then
      echo "[ERROR] Failed to back up $SRC_PATH" | tee -a "$LOG_FILE" | mail -s "Backup Error" user@example.com
    fi
  fi
done < "$CONFIG_FILE"

echo "[INFO] Removing backups older than $RETENTION_DAYS days" >> "$LOG_FILE"
if ! $DRY_RUN; then
  find "$DEST_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \; >> "$LOG_FILE"
fi

echo "=== Backup Finished at $(date) ===" >> "$LOG_FILE"
