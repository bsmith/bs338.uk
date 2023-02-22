#!/bin/bash

set -e -x -o noclobber

mkdir -p _build

rm -fr _build/htdocs
mkdir -p _build/htdocs

rsync -v -r src/ _build/htdocs/

touch _build/htdocs/.nojekyll

echo "<!-- build.sh $(date) -->" >>_build/htdocs/index.html

echo "finished"
