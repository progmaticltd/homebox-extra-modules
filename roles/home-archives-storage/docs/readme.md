
This role allows you to use a dedicated block storage for email archives.

Example of a storage definition for `/home/archives`:

```yml

storage_archive:
  device: /dev/vdb
  fstype: btrfs
  mkfs_opts:
    - -R quota
    - --checksum xxhash
    - -L home-archives
  mount_opts:
    - noatime
    - compress=zstd

```
