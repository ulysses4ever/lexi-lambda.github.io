#!/bin/bash
set -ev -o pipefail # exit with nonzero exit code if anything fails

# clear the output directory
rm -rf out

# build the blog files
yarn run build
raco frog --build

# only deploy on non-PR pushes to source
if [[ "$TRAVIS_PULL_REQUEST" != 'false' || "$TRAVIS_BRANCH" != 'source' ]]; then
  exit 0;
fi

# go to the out directory and create a *new* Git repo
cd out
git init

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI"
git config user.email "lexi.lambda@gmail.com"

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages"

# Force push from the current repo's master branch to the remote
# repo. (All previous history on the branch will be lost, since we are
# overwriting it.) We redirect any output to /dev/null to hide any sensitive
# credential data that might otherwise be exposed.
git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master > /dev/null 2>&1
