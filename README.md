# cargo-quickbuild sketch design

## minimal version of the client:

- assume Cargo.lock is up to date
- explode immediately if it's not a debug build, or there are already release assets, or there is a .cargo/config that we should be honouring
- parse dependency tree using https://crates.io/crates/cargo-lock or similar
- for each root of the tree, serialise and compute a hash
  - fetch /cratename-HASH_OF_DEPENDENCY_TREE-rustc_version-arch from github releases of `cargo-quickbuild-releases` repo, and unpack
  - stretch goal: keep a download cache and/or unpack in a common place and hardlink them into target/
- if any cache miss happens, POST the full Cargo.lock somewhere.

## minimal version of the analyser:

- hoover up Cargo.lock files from rust-repos
- for each Cargo.lock file:
  - parse dependency tree
  - for each root:
    - caclulate cratename-HASH_OF_DEPENDENCY_TREE-rustc_version-arch
    - estimate the size of the dependency tree (unit = crate count?)
    - stats.count("cratename-HASH_OF_DEPENDENCY_TREE-rustc_version-arch", 1)
    - stats.count("cratename-HASH_OF_DEPENDENCY_TREE-rustc_version-arch-size", size)
    - store the serialised dependency tree in a `cargo-quickbuild-trees` git repo if it doesn't already exist

## minimal version of the service:

- receive Cargo.lock and store somewhere
- parse dependency tree
- for each root:
  - calculate the hash etc
  - store the
  - if the count for that hash exceeds $THRESHOLD and a build isn't started, trigger a build

## minimal version of the builder:

- When trigger comes in to build a package:
- fetch cratename-HASH_OF_DEPENDENCY_TREE serialised tree from the `cargo-quickbuild-trees` git repo
- unpack it into `Cargo.lock` and create a fake src/main.rs like how `cargo-chef` does
- create a fake Cargo.toml as well
- `cargo build --package=cratename`
- make a tarball of target/
- release it as `cratename-HASH_OF_DEPENDENCY_TREE-rustc_version-arch` on `cargo-quickbuild-releases` repo (should be fine to have a single commit in that repo and tag it will infinity git tags).
