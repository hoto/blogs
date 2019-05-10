#!/usr/bin/env bash
set -eu

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo -e "\n[Deleting old publication...]"
rm -rf public
mkdir public

echo -e "\n[Deleting old worktree...]"
git worktree prune
rm -rf .git/worktrees/public/

echo -e "\n[Checking out gh-pages branch into 'public' directory...]"
git worktree add -B gh-pages public origin/gh-pages

echo -e "\n[Removing existing files...]"
rm -rf public/*

echo -e "\n[Generating site...]"
make gh-pages-generate

echo -e "\n[Commiting gh-pages branch...]"
cd public && git add --all && git commit -m "Publishing to gh-pages (publish.sh)" && cd ..

echo -e "\n[Pushing gh-pages branch...]"
git push origin gh-pages
