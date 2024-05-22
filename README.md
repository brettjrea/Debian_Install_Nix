# Debian_Install_Nix
Install Nix package manager on Debian

```
bash <(curl -L https://nixos.org/nix/install) --no-daemon
```

*Replace userland with your current user.*

```
mkdir -m 0755 /nix && chown userland /nix
```

*If you had to manually create nix folder (likely) rerun bash script then move to the next command to make the Nix command usable.*

```
. /home/userland/.nix-profile/etc/profile.d/nix.sh
```

```
mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes
' >> ~/.config/nix/nix.conf
```
