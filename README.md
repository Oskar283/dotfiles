# dotfiles

Home Manager modules, consumed by the [homelab](https://github.com/Oskar283/homelab) flake and buildable standalone.

## Usage with homelab (NixOS)

Import the module in your homelab flake:

```nix
inputs.dotfiles.url = "github:Oskar283/dotfiles";
# In home.nix:
imports = [ inputs.dotfiles.homeManagerModules.default ];
```

No manual activation needed — NixOS rebuild handles it.

## Standalone usage (non-NixOS)

For machines without NixOS (e.g. Ubuntu workstations).

### Prerequisites

```bash
# Install Nix (if not present)
curl -L https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh

# Enable flakes
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Make nix available on login
echo '. /home/$USER/.nix-profile/etc/profile.d/nix.sh' | sudo tee /etc/profile.d/nix-user.sh

# Ensure the Nix daemon starts on boot and is accessible, (maybe not needed on a normal install. This might be needed only when the user is not able to modify its groups)
sudo systemctl enable --now nix-daemon
sudo bash -c 'echo "d /nix/var/nix/daemon-socket 0755 root root -" > /etc/tmpfiles.d/nix-daemon-socket.conf'
sudo chmod o+rx /nix/var/nix/daemon-socket
```

### Local config files

Create these files before applying (they are gitignored):

- `home/bashrc.local` — company-specific shell settings (PATH, pyenv, tokens)
- `home/aliases.local` — company-specific shell aliases
- `home/gitconfig.local` — work email, name, and git aliases

These are deployed to `~` via `mkOutOfStoreSymlink` (see `home-manager/local.nix`).

### Apply / rebuild

```bash
cd /path/to/dotfiles
nix run .#homeConfigurations.default.activationPackage
```

Symlinks persist across reboots. Only re-run when you change files under
`home-manager/` or `home/`.

### Update flake inputs

```bash
nix flake update
nix run .#homeConfigurations.default.activationPackage
```

## Troubleshooting

### `error: cannot connect to socket at '/nix/var/nix/daemon-socket/socket'`

Some systems set `NIX_REMOTE=daemon` globally, which forces Nix to look for a daemon even on a single-user install.

`bash.nix` already runs `unset NIX_REMOTE` on every shell start to fix this automatically once the dotfiles are applied.

Before the first apply, fix it manually for your current session:

```bash
unset NIX_REMOTE
```

If you later switch to a **multi-user / daemon install**, remove the `unset NIX_REMOTE` line from `home-manager/bash.nix` — you'll want that variable set so Nix talks to the daemon.