# dotfiles

Home Manager modules, consumed by the [homelab](https://github.com/Oskar283/homelab) flake and buildable standalone.

## Prerequisites

```bash
# Install Nix (if not present)
curl -L https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh

# Enable flakes
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# Make nix available on login (non-NixOS only)
# Or add to bashrc, but not through below command
echo '. /home/$USER/.nix-profile/etc/profile.d/nix.sh' | sudo tee /etc/profile.d/nix-user.sh
```

## Apply

```bash
nix run home-manager/release-25.11 -- switch --flake .#default --impure
```

## Update

```bash
nix flake update
nix run home-manager/release-25.11 -- switch --flake .#default --impure
```