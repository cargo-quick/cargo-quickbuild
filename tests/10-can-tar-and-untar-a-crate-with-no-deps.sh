#!/bin/bash

set -euxo pipefail

echo '
This is to check the behaviour of `cargo build` when you tar/untar the target directory.

Run the script, and view the git log that it creates. You probably want to throw away the branch when you'\''re done.

It turns out that `tar` defaults to only recording timestamps to the nearest second, which breaks cargo'\''s fingerprints and triggers a full rebuild.
'

print_timestamps() {
    # gls is gnu ls (bsd ls on macos doesn't understand these flags)
    # I have no idea why the timestamp of target/debug/ changes, but I don't think it matters.
    gls --full-time -Rl target | (grep -v '^drwxr-xr-x .* [+][0-9][0-9]00 debug$' || true)
}

mkdir -p tmp

rm -rf target
cargo build -p regex-automata

echo "saving clean cargo build timestamps"
# gnu ls (bsd ls on macos can't do this)
print_timestamps > tmp/timestamps.txt

sleep 2
cargo build -p regex-automata

echo "checking timestamps after noop cargo build"
print_timestamps > tmp/timestamps-after.txt
diff -u tmp/timestamps.txt tmp/timestamps-after.txt


# `pax` format seems to provide nanosecond accuracy, and is portable to bsd+gnu.
# No idea why that's not the default.
tar --format=pax -c target > /tmp/target.tar
rm -rf target
tar -x -f /tmp/target.tar

echo "checking timestamps after tar round-trip"
print_timestamps > tmp/timestamps-after.txt
diff -u tmp/timestamps.txt tmp/timestamps-after.txt

sleep 2
cargo build -p regex-automata

echo "checking timestamps again after final noop cargo build"
print_timestamps > tmp/timestamps-after.txt
diff -u tmp/timestamps.txt tmp/timestamps-after.txt
