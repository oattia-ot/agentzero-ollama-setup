#!/bin/bash
# Simple backup script for volumes

BACKUP_DIR="./backups/$(date +%Y-%m-%d_%H-%M)"
mkdir -p "$BACKUP_DIR"

echo "Backing up Ollama models..."
docker run --rm -v ollama_data:/data -v "$(pwd)/$BACKUP_DIR:/backup" alpine tar czf /backup/ollama_data.tar.gz -C /data .

echo "Backing up Agent Zero data..."
docker run --rm -v agent_zero_data:/data -v "$(pwd)/$BACKUP_DIR:/backup" alpine tar czf /backup/agent_zero_data.tar.gz -C /data .

echo "Backup complete: $BACKUP_DIR"
