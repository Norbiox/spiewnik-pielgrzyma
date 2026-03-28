#!/bin/bash
set -e

# Ensure we're on master and up to date
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "master" ]; then
  echo "Error: must be on master branch (currently on $BRANCH)"
  exit 1
fi

git fetch origin master --quiet
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master)
if [ "$LOCAL" != "$REMOTE" ]; then
  echo "Error: local master is not up to date with origin/master"
  exit 1
fi

# Check CI status on current commit
echo "Checking CI status..."
STATUS=$(gh run list --branch master --commit "$LOCAL" --status completed --json conclusion --jq '.[].conclusion' 2>/dev/null | head -1)
if [ "$STATUS" != "success" ]; then
  echo "Error: CI has not passed on this commit"
  echo "Push to master and wait for CI to pass before releasing."
  exit 1
fi

LATEST=$(git tag --sort=-v:refname | head -1)
if [ -z "$LATEST" ]; then
  NEXT="v0.1.0"
else
  MAJOR=$(echo "$LATEST" | sed 's/v//' | cut -d. -f1)
  MINOR=$(echo "$LATEST" | sed 's/v//' | cut -d. -f2)
  NEXT="v${MAJOR}.$((MINOR + 1)).0"
fi

echo "Current: ${LATEST:-none}"
echo "Next:    $NEXT"
read -p "Tag and push $NEXT? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git tag "$NEXT"
  git push origin "$NEXT"
  echo "Released $NEXT"
fi
