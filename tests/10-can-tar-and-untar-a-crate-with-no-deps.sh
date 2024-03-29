#!/bin/bash

set -euxo pipefail

echo '
This is to check the behaviour of `cargo build` when you tar/untar the target directory.

Run the script, and view the git log that it creates. You probably want to throw away the branch when you'\''re done.

It turns out that `tar` defaults to only recording timestamps to the nearest second, which breaks cargo'\''s fingerprints and triggers a full rebuild.
'

if ! git diff --exit-code ; then
    echo "please commit your work before running this test"
    exit 1
fi

INITIAL_COMMIT=`git rev-parse HEAD`

LAST_COMMIT_MESSAGE=""

commit() {
    # gnu ls (bsd ls on macos can't do this)
    gls --full-time -Rl target > timestamps.txt
    git add .
    git commit --allow-empty -am "$$1"

    LAST_COMMIT_MESSAGE="$1"
}


rm -rf target
cargo build -p regex-automata

commit "clean cargo build timestamps"

sleep 2
cargo build -p regex-automata

commit "noop cargo build timestamps"

# `pax` format seems to provide nanosecond accuracy, and is portable to bsd+gnu.
# No idea why that's not the default.
tar --format=pax -c target > /tmp/target.tar
rm -rf target
tar -x -f /tmp/target.tar

commit "tar round-trip timestamps"

sleep 2
cargo build -p regex-automata

commit "noop cargo build after tar timestamps"

git log --color=always -p --reverse | less  -R +?"$LAST_COMMIT_MESSAGE"

git reset $INITIAL_COMMIT
