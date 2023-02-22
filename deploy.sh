#!/bin/bash
# Please remember to run `shellcheck` after editing!

set -e -x -o noclobber

if ! git diff-index --quiet HEAD --; then
    echo "There are local changes"
    exit 1
fi

# Require a fresh build to be run
./build.sh

mkdir -p _build/_deploy

GIT_INDEX_FILE="$(pwd)/_build/_deploy_index"
GIT_WORK_TREE="$(pwd)/_build/_deploy"
export GIT_INDEX_FILE GIT_WORK_TREE

# Start with the currently deployed state
# XXX: Should we do a fetch first?  Or just wait for the error at the end when we can't fast forward?
# git fetch origin
git read-tree 'origin/gh-pages^{tree}'
git checkout-index -u -a -f

# Sync the built files into it
# Deliberately doesn't delete files to not break links (maybe)
rsync -v -r _build/htdocs/ _build/_deploy/

# Sync the index
# git update-index --add --verbose
git add -A "$GIT_WORK_TREE"
deploy_tree="$(git write-tree)"

echo "Made tree $deploy_tree"

head_commit="$(git rev-parse HEAD)"

# TODO: better commit message (eg detect local changes)
# TODO: how to detect and avoid empty commits?
deploy_commit="$( \
        (echo "🚀 built by deploy.sh from $head_commit") | \
        git commit-tree "$deploy_tree" -p origin/gh-pages \
    )"

echo "Made commit $deploy_commit"

# Update the local branch
# XXX: make this safer!  use the 3-arg form of update-ref
# git push . "$deploy_commit:gh-pages"
git update-ref 'refs/heads/gh-pages_PROPOSED' "$deploy_commit"
git fetch . "$deploy_commit:gh-pages"
git push origin "gh-pages:gh-pages"

# cleanup step
git update-ref -d 'refs/heads/gh-pages_PROPOSED' "$deploy_commit"

# TO FIX PROBLEMS: git update-ref 'refs/heads/gh-pages' 'origin/gh-pages'