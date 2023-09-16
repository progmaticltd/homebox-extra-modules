# HomeBox extra modules

Extra roles for homebox, not included in the core distribution.

To use these roles, make sure the path, relative or absolute, is included in the _role\_path_ variable, for instance:

```ini
roles_path = .:{{ playbook_dir }}/../../common/roles/:/home/andre/git/homebox-extra-modules
```

## Current roles

### Separate home storage roles

HomeBox uses two storages location for user files: /home/users and /home/archives. The first one is used for current
emails, while the second for email archives. This allows to use a cheaper - albeit slower - storage for email
archives. This can be used both for a home physical server or a virtual cloud server.

#### home-live-storage

This role allows to store live emails (`/home/users`) on a separate dedicated disk.
See the [dedicated documentation](home-live-storage/doc/readme.md) in the role, for more details.

#### home-archives-storage

This role allows to store archive emails (`/home/archives`) on a separate dedicated disk.
See the [dedicated documentation](home-archives-storage/doc/readme.md) in the role, for more details.


#### home-dual-storage

This role allows to store _both_ live (`/home/users`) and archive emails (`/home/archives`) on a separate dedicated
disk.
See the [dedicated documentation](home-dual-storage/doc/readme.md) in the role, for more details.
