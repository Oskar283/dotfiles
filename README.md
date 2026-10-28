# dotfiles

Home Manager modules, consumed by the [homelab](https://github.com/Oskar283/homelab) flake and buildable standalone.

## Usage with homelab (NixOS)

Import the module in your homelab flake:

```nix
inputs.dotfiles.url = "github:Oskar283/dotfiles";
# In home.nix:
imports = [ inputs.dotfiles.homeManagerModules.default ];
```

## usage (non-NixOS)

For machines without NixOS

### Prerequisites

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh

# Enable flakes
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Make nix available on login
echo '. /home/$USER/.nix-profile/etc/profile.d/nix.sh' | sudo tee /etc/profile.d/nix-user.sh

```

### Local config files

Create/use these files for machine specific things

- `home/bashrc.local` — company-specific shell settings (PATH, pyenv, tokens)
- `home/aliases.local` — company-specific shell aliases
- `home/gitconfig.local` — work email, name, and git aliases

### Apply / rebuild

```bash
cd /path/to/dotfiles
nix run .#homeConfigurations.default.activationPackage --impure
```

### Update flake inputs

```bash
nix flake update
nix run .#homeConfigurations.default.activationPackage --impure
```

