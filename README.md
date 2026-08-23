# leo's niri + noctalia NixOS config

A minimal, flake-parts-based NixOS configuration that boots straight into
[niri](https://github.com/YaLTeR/niri) (a scrollable-tiling Wayland
compositor) with [noctalia](https://github.com/noctalia-dev/noctalia-shell)
(bar, launcher, notifications, wallpaper, lock screen, etc.) running on top.
It's deliberately small so you have a clean, working desktop you can start
customizing right away.

It follows the flake-parts + `import-tree` + `wrapper-modules` pattern from
[vimjoyer's "parts wrapped" guide](https://www.vimjoyer.com/vid79-parts-wrapped):
every file under `modules/` is auto-discovered, and niri's config is
generated declaratively from Nix instead of a hand-written `config.kdl`.

```
.
├── flake.nix
└── modules
    ├── systems.nix                          # which systems to build for
    ├── nixpkgs.nix                          # wires up `pkgs` for perSystem
    ├── features
    │   └── niri.nix                         # niri, declaratively configured
    └── hosts
        └── leo-niri
            ├── default.nix                  # registers the nixosConfiguration
            ├── configuration.nix             # boot/user/login/packages
            └── hardware-configuration.nix    # PLACEHOLDER — you replace this
```

**What you get on first boot:** a login-free boot straight into niri, with
noctalia's bar running. `Mod+Return` opens a terminal (Alacritty),
`Mod+Space` opens noctalia's app launcher, `Mod+Q` closes the focused
window, `Mod+Shift+E` quits niri (drops you back to the login manager).

## Before you start

- **This will erase the entire target disk.** Triple-check the device name
  in the partitioning step.
- Assumes a **UEFI** machine (the vast majority of anything from the last
  ~10 years). If you're on legacy BIOS, the partitioning/bootloader steps
  need to change.
- You need a working **internet connection** in the live environment —
  installing pulls in nixpkgs, flake-parts, niri, and noctalia over the
  network. Ethernet works out of the box; for Wi-Fi run `nmtui` first.
- Boot the **NixOS minimal installer ISO** and get to a shell prompt.

## Install

Run these as the commands you actually type, in this order.

### 1. Become root

```console
sudo -i
```

### 2. Find your target disk

```console
lsblk
```

Note the device name of the disk you're installing to, e.g. `/dev/sda` or
`/dev/nvme0n1`. Everything below uses `/dev/sdX` as a placeholder — replace
it with your real device every time you see it (for NVMe drives, partitions
are `/dev/nvme0n1p1`, `/dev/nvme0n1p2`, etc. instead of `/dev/sdX1`).

### 3. Partition, format, and mount the disk

```console
parted /dev/sdX -- mklabel gpt
parted /dev/sdX -- mkpart ESP fat32 1MiB 513MiB
parted /dev/sdX -- set 1 esp on
parted /dev/sdX -- mkpart primary ext4 513MiB 100%

mkfs.fat -F 32 -n BOOT /dev/sdX1
mkfs.ext4 -L nixos /dev/sdX2

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot
```

### 4. Generate the hardware config

```console
nixos-generate-config --root /mnt
```

This writes `/mnt/etc/nixos/configuration.nix` (which we won't use — ours
replaces it) and, importantly, `/mnt/etc/nixos/hardware-configuration.nix`
(which we do need — it has your disk labels, filesystem, and kernel module
info).

### 5. Get this config onto the machine

Extract this zip onto a USB stick on another computer, then plug that stick
into the target machine. Back in the live environment as root:

```console
lsblk
```

Find your USB stick's partition (e.g. `/dev/sdb1`), then:

```console
mkdir -p /mnt2
mount /dev/sdb1 /mnt2
cp -r /mnt2/nixos-niri-noctalia/. /mnt/etc/nixos/
umount /mnt2
```

This copies `flake.nix` and `modules/` into `/mnt/etc/nixos`, alongside the
`configuration.nix` and `hardware-configuration.nix` that
`nixos-generate-config` already put there. Now clean that up:

```console
rm /mnt/etc/nixos/configuration.nix
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/modules/hosts/leo-niri/hardware-configuration.nix
```

That `mv` is the important part: it overwrites this config's placeholder
hardware file with the real one generated for your machine.

At this point, feel free to open
`/mnt/etc/nixos/modules/hosts/leo-niri/configuration.nix` and adjust the
timezone, hostname, or keyboard layout if the defaults (`Europe/Berlin`,
`leo-niri`, `us`) aren't right for you — e.g. `nano
/mnt/etc/nixos/modules/hosts/leo-niri/configuration.nix`.

### 6. Install

```console
nixos-install --extra-experimental-features "nix-command flakes" --no-root-passwd --flake /mnt/etc/nixos#leo-niri
```

`--no-root-passwd` skips the interactive root password prompt — you'll set
your own password for `leo` after first boot instead (step 8).

This step downloads and builds/substitutes niri, noctalia, and everything
else, so it can take a while depending on your connection.

### 7. Reboot

```console
reboot
```

Remove the installation media when prompted. The machine should boot
straight into niri with noctalia's bar running — no login prompt.

### 8. Set your real password

Open a terminal with `Mod+Return`, then:

```console
passwd
```

and set a real password for `leo` (it currently has the temporary password
`changeme`, set via `initialPassword` in `configuration.nix`).

## Customizing further

- **niri's config** (keybinds, layout, outputs, keyboard layout, etc.)
  lives in `modules/features/niri.nix` as a Nix attribute set — see the
  [wrapper-modules niri reference](https://birdeehub.github.io/nix-wrapper-modules/niri.html)
  for all available options, or the
  [niri wiki](https://wiki.nixos.org/wiki/Niri) for what's possible in
  general.
- **noctalia's settings** (bar layout, widgets, colors, wallpaper, etc.)
  are *not* managed by this flake — open noctalia's own settings panel, or
  edit `~/.config/noctalia` directly, and they'll persist normally.
- **System settings** (users, packages, services) live in
  `modules/hosts/leo-niri/configuration.nix`.
- After editing anything, rebuild with:

  ```console
  sudo nixos-rebuild switch --flake /etc/nixos#leo-niri
  ```

- If you later put `/etc/nixos` under git, remember that Nix flakes only
  see files tracked by git once a `.git` folder exists — run `git add` on
  any new file before rebuilding, or it'll silently be ignored.



{inputs, ...}: {
  flake.nixosModules.firefox = {
    home-manager.users.leo = {pkgs, ...}: {
      programs.firefox = {
        enable = true;

        /*
        profiles.default = {
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "extensions.autoDisableScopes" = 0;

          "browser.toolbars.bookmarks.visibility" = "never";

          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "always";
          "sidebar.revamp" = true;

          "browser.tabs.groups.enabled" = false;
          "ui.systemUsesDarkTheme" = 1;

          "browser.tabs.inTitlebar" = 1;
          "browser.uiCustomization.state" = builtins.toJSON {
            placements = {
              widget-overflow-fixed-list = [];
              nav-bar = ["back-button" "forward-button" "urlbar-container"];
              toolbar-menubar = ["menubar-items"];
              TabsToolbar = [];
              PersonalToolbar = [];
            };
            seen = [];
            dirtyAreaCache = ["nav-bar" "TabsToolbar" "PersonalToolbar"];
            currentVersion = 20;
            newElementCount = 0;
          };
        };
        */

        /*
           search = {
          force = true;
          default = "ddg";

          engines = {
            "ddg" = {
              urls = [
                {
                  template = "https://duckduckgo.com";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                    {
                      name = "type";
                      value = "disableaibro";
                    }
                  ];
                }
              ];
              definedAliases = ["@ddg"];
            };
          };
        };
        */

        /*
          extensions = let
          addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
        in {
          force = true;
          packages = [
            addons.bitwarden
            addons.ublock-origin
            addons.sponsorblock
            addons.youtube-shorts-block
            addons.darkreader
            addons.vimium-c
          ];
          settings = {
            # Grants vimium-c's optional "bookmarks" permission at
            # install time so Firefox never has to prompt for it and
            # the "index bookmarks" feature just works. addonId is read
            # straight off the built package rather than hardcoded, so
            # this stays correct if the extension's id ever changes.
            # If evaluation fails because addonId isn't exposed on this
            # package, open about:debugging#/runtime/this-firefox,
            # find Vimium C's "Extension ID" (NOT the moz-extension://
            # UUID in the popup URL - that's a per-install runtime id,
            # not the manifest id) and hardcode that string here instead.
            "${addons.vimium-c.addonId}" = {
              permissions = [
                "bookmarks"
                "clipboardRead"
                "clipboardWrite"
                "history"
                "notifications"
                "search"
                "sessions"
                "storage"
                "tabs"
                "webNavigation"
                "<all_urls>"
              ];
            };
          };
        };
        */

        
      };
    };
  };
}
