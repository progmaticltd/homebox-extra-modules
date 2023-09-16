
This role allows you to use a dedicated block storage for current emails.

Example of a storage definition for `/home/users`:

```yml

storage_live:
  device: /dev/vdb
  fstype: btrfs
  mkfs_opts:
    - -R quota
    - --checksum xxhash
    - -L home-users
  mount_opts:
    - noatime
    - compress=lzo

```
