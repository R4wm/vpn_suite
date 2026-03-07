# ER605 Router Backups

This directory stores exported router backup files from the ER605 web UI.

## Current Backup
- `backup-ER605-2026-03-07.bin`
  - Source path: `/tmp/backup-ER605-2026-03-07.bin`
  - Copied into repo on: 2026-03-07

## Restore Notes
1. Log in to ER605 web UI (`http://192.168.0.1` or `https://192.168.0.1`).
2. Navigate to backup/restore settings.
3. Upload the desired `.bin` backup file.
4. Confirm restore and allow router to reboot if prompted.

## Safety
- Keep at least one known-good backup before making WAN/firewall/VPN changes.
- Create a new dated backup after any successful network change window.
