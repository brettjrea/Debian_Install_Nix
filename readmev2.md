##### Android Userland Ubuntu

*The following is for Ubuntu on Android userland I have to recheck it on WSL2. These instructions might be simpler and supercede the above. As well the Wasmcloud binary we are installing has a known out of memory issue on low ram devices. If you get the error it means you did it right. The fix might already be patched need to check releases but it would mean I need to rewrite the tutorial with the new binary hash which I don't have time to backtrack just yet.*  

### Dependencies

```
sudo apt update && sudo apt upgrade && sudo apt autoremove
```

```
cat /etc/ssl/certs/ca-certificates.crt
```

```
sudo apt install ca-certificates xz-utils git curl build-essential cmake unzip
```

```
sudo update-ca-certificates
```

### Rust

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

```
. "$HOME/.cargo/env"
```

```
rustup target add wasm32-wasi
```

### NIX

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

### External Nats-Server

*This might be unneccessary, one seems to be in the cli already. Need to verify.*

```
curl -L https://github.com/nats-io/nats-server/releases/download/v2.10.14/nats-server-v2.10.14-linux-arm64.zip -o nats-server.zip
```

```
unzip nats-server.zip -d nats-server
```

```
sudo cp nats-server/nats-server-v2.10.14-linux-arm64/nats-server /usr/bin
```

```
/usr/bin/nats-server -a 127.0.0.1 &
```

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

### Another way to test if binary works outside of the Nix store for sanity checks.

```
sudo chown 755 /nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl
```

```
cp /nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl ~/wash
```

```
chmod 755 ~/wash
```

```
./wash
```

### Create Rust Project
```
/nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl new component hello --template-name hello-world-rust
```

```
cd hello
```

```
/nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl app deploy wadm.yaml
```

```
/nix/store/3l74hcgd2x9ialxj1fb0yy8afkcqwi4z-wash-aarch64-unknown-linux-musl app list
```

### Test project

```
curl localhost:8080
```
