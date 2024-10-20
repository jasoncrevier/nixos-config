# My NixOS config
This is where I store the config files and dotfiles for my NixOS setup. I'm new to Nix in general, so there's a lot of tinkering and experimentation happening in this space.
A lot of it is still very noob-ish, so if you stumble on this repo and have any advice, I'd love to hear it!

## Folder structure
```console
nixos-config
├── home-manager
│   └── device-configs
├── misc
│   └── .config
│       └── presets
│   └── .local
│       └── share
│          ├── applications
│          ├── color-schemes
│          └── konsole
├── nixos
│   └── device-configs
└── pkgs
```
- `nixos-config`: Includes the main flake for all the NixOS devices in my fleet, my wallpaper, and all the sub-directories below.
- `nixos`: `configuration.nix` files for each device. They each import their relevant `hardware-configuration.nix` and any of the other config files from the folder that are relevant to that machine. Most machines will import `common.nix` which contains basic applications and configs like enabling `systemd-boot`, setting the time zone, installing `git`, etc.
- `home-manager`: Config files for `home-manager`. A main config file for each device that import any of the other config files from the folder that are relevant to that machine.
- `pkgs`: Derivations for packages that aren't available in the `nixpkgs` repos.
- `misc`: A handful of files to copy to the home directory after install. They're mostly for theming. I'll eventually add them to `home-manager` or use something like `stylix` to handling theming declaratively.

## Thinkpad
![Gnome menu](./screenshots/gnome-menu.png)
![Gnome in use](./screenshots/gnome-in-use.png)
![Gnome overview](./screenshots/gnome-overview.png)