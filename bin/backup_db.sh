#!/bin/bash

# Directory to store backups
BACKUP_DIR="/mnt/usb_backup/invest_backups"
mkdir -p "$BACKUP_DIR"

# Create filename with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="$BACKUP_DIR/invest_backup_$TIMESTAMP.sql"

# Dump the database from inside the container
# Note: Using the password from your docker-compose.yml
docker exec invest_db /usr/bin/mysqldump -u root --password=Ivanchuk_1969 invest > "$FILENAME"

# Optional: Delete backups older than 30 days to save space
find "$BACKUP_DIR" -type f -name "*.sql" -mtime +30 -delete