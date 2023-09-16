
This role allows to store _both_ live (`/home/users`) and archive emails (`/home/archives`) on a separate dedicated
disk.

Example of a storage definition:

```yml

storage:
  device: /dev/vdb
  live:
    fstype: btrfs
    mkfs_opts:
      - -R quota
      - --checksum xxhash
      - -L home-users
    mount_opts:
      - noatime
      - compress=lzo
  archives:
    fstype: btrfs
    mkfs_opts:
      - -R quota
      - --checksum xxhash
      - -L home-archives
    mount_opts:
      - noatime
      - compress=lzo

```

By default, the first partition (current emails) is using 20% of the block storage, and the second one (email archives),
is using the rest of the disk (80%).
