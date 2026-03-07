# NAS Mount Usage (Manual, On-Demand)

SMB share details:
- Server: `192.168.0.116`
- Share: `NAS`
- Backing path on server: `/mnt/nas`

## Mount
```bash
cd /home/r4wm/github/vpn_suite
./scripts/mount-nas-share.sh
```

Default mountpoint:
- `/mnt/nas-share`

Custom mountpoint example:
```bash
./scripts/mount-nas-share.sh 192.168.0.116 NAS /mnt/custom-nas
```

## Unmount
```bash
cd /home/r4wm/github/vpn_suite
./scripts/unmount-nas-share.sh
```

Custom unmountpoint:
```bash
./scripts/unmount-nas-share.sh /mnt/custom-nas
```
