#!/bin/bash

set -euxo pipefail

cargo install --debug --locked --path $HOME/src/cargo-quick/cargo-quickbuild

rm -rf ~/tmp/depends-on-curl-sys
rm -rf ~/tmp/quick/
cd ~/tmp
cargo new depends-on-curl-sys

cat << EOF > ~/tmp/depends-on-curl-sys/Cargo.toml
# curl-sys 0.4.59+curl-7.86.0
[package]
name = "cargo-quickbuild-scratchpad"
version = "0.1.0"
edition = "2021"

resolver = "2"

[dependencies]
curl-sys_0_4_59_curl_7_86_0 = { package = "curl-sys", version = "=0.4.59+curl-7.86.0", features = ["default", "http2", "libnghttp2-sys", "openssl-sys", "ssl"], default-features = false }
libc_0_2_132 = { package = "libc", version = "=0.2.132", features = ["default", "std"], default-features = false }
libnghttp2-sys_0_1_7_1_45_0 = { package = "libnghttp2-sys", version = "=0.1.7+1.45.0", features = [], default-features = false }
libz-sys_1_1_6 = { package = "libz-sys", version = "=1.1.6", features = ["libc"], default-features = false }

EOF

cd ~/tmp/depends-on-curl-sys

cargo tree --edges=all

cargo quickbuild build
