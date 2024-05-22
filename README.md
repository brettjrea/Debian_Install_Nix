*First runs with anything nix can take a good while as it finds the cached packages and downloads them or builds from source! Subsequent runs will be faster as they are now loaded into your store and it just looks to add or remove any changes to an existing derivation. Nix uses Hashes to compare files and by default will try to find an existing binaries hash in the store before it rebuilds or downloads it.*

# Single User Installation

To explicitly select a single-user installation on your system:

```console
$ bash <(curl -L https://nixos.org/nix/install) --no-daemon
```

In a single-user installation, `/nix` is owned by the invoking user.
The script will invoke `sudo` to create `/nix` if it doesn’t already exist.

---

# If you don’t have `sudo`, manually create `/nix` as `root` and run the bash script again. 

*swap user for your user*

```console
$ su root
# mkdir /nix
# chown user /nix
```

*or like this....*

```
mkdir -m 0755 /nix && chown user /nix
```

---

# Restart terminal or use the following to start using it right away.

```
. /home/userland/.nix-profile/etc/profile.d/nix.sh`
```

---

# I thought below was for the flakes only, but its also for the nix-command error so I just run it.

*Might not be neccesary if you used determinate systems installer need to verify.*

---

```
mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes
' >> ~/.config/nix/nix.conf
```

---

## Single User uninstall

To remove a single-user installation of Nix, run:

```console
$ rm -rf /nix ~/.nix-channels ~/.nix-defexpr ~/.nix-profile
```

You might also want to manually remove references to Nix from your `~/.profile`.

---


### wasmCloud Binary

```
nix store prefetch-file https://github.com/wasmCloud/wasmCloud/releases/download/wash-cli-v0.28.1/wash-aarch64-unknown-linux-musl
```

```
/nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl
```

```
chmod +x /nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl
```

*I am using the full path for now which is good because it shows the unique hash and how versioning and reproducibility work.*

```
/nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl up
```

---

