#!/bin/bash
# Please remember to run `shellcheck` after editing!

set -e -x -o noclobber

mkdir -p _build

# TODO: add a --clean flag!
# rm -fr _build/htdocs
mkdir -p _build/htdocs

rsync \
    --exclude=".nojekyll" \
    --delete-after -c -v -r static/ src/ _build/htdocs/
touch _build/htdocs/.nojekyll

echo "<!-- build.sh $(date) -->" >>_build/htdocs/index.html

echo "finished"
