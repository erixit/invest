# SSD Usage Strategy for Raspberry Pi Development

This document outlines the strategy for managing storage on the Raspberry Pi 5 to ensure performance and longevity of the SD card.

## The Challenge
Developing directly on the Raspberry Pi's SD card presents two main risks:
1.  **Wear and Tear**: Database writes and Docker image builds generate high I/O, which can wear out an SD card quickly.
2.  **Performance**: SD cards are significantly slower than SSDs for random read/write operations (like databases).

## Storage Types & Strategy

We distinguish between two different use cases for external storage: **Passive Backups** and **Active Development**.

### 1. Passive Storage (Backups)
*   **Hardware**: Existing USB Hard Drive / SSD used for Windows backups.
*   **Filesystem**: `NTFS` (Windows format).
*   **Usage**:
    *   Used solely as a destination for the nightly `backup_db.sh` script.
    *   **Why**: Linux can write files to NTFS, but cannot run complex permissions required for active software.
    *   **Benefit**: You can plug this drive into a Windows machine to retrieve or verify backups easily.

### 2. Active Development (Docker & Database)
*   **Hardware**: A dedicated, separate USB SSD (e.g., 500GB or 1TB).
    *   *Note*: Smaller drives are rare now. Larger drives work perfectly fine on the Pi 5.
*   **Filesystem**: `ext4` (Linux native format).
*   **Usage**:
    *   Used to host the Docker daemon data (`/var/lib/docker`).
    *   **Why**: Docker requires a Linux-native filesystem to handle ownership, permissions, and overlay drivers. NTFS drives will cause "Permission Denied" errors if used for active containers.

## Setup Guide: Dedicated Development SSD

If acquiring a dedicated SSD for development, follow these steps to offload the SD card.

### 1. Format the Drive
*Warning: This erases all data on the drive.*
```bash
# Find the drive (usually /dev/sda)
lsblk
# Format to ext4
sudo mkfs.ext4 /dev/sda1
```

### 2. Mount Permanently
1.  Create mount point: `sudo mkdir -p /mnt/ssd_storage`
2.  Get UUID: `sudo blkid /dev/sda1`
3.  Add to `/etc/fstab`:
    ```text
    UUID=YOUR_UUID  /mnt/ssd_storage  ext4  defaults  0  0
    ```
4.  Mount: `sudo mount -a`

### 3. Move Docker to SSD
1.  Stop Docker: `sudo systemctl stop docker`
2.  Create docker directory: `sudo mkdir -p /mnt/ssd_storage/docker`
3.  Copy existing data: `sudo rsync -aqxP /var/lib/docker/ /mnt/ssd_storage/docker/`
4.  Configure Docker (`/etc/docker/daemon.json`):
    ```json
    {
      "data-root": "/mnt/ssd_storage/docker"
    }
    ```
5.  Start Docker: `sudo systemctl start docker`

*Result: The SD card is now only used for the OS boot, while all heavy database and container work happens on the fast SSD.*

### 4. Eclipse IDE Setup
If you run Eclipse IDE on the Pi:
1.  **Install**: Extract Eclipse to `/opt/eclipse` (on the SD card is fine, it is read-only).
2.  **Workspace**: Create a directory on the SSD: `mkdir -p /mnt/ssd_storage/workspace`.
3.  **Usage**: When starting Eclipse, select `/mnt/ssd_storage/workspace` as your workspace. This ensures your source code and build artifacts are on the fast drive.
