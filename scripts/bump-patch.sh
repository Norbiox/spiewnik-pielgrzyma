#!/bin/bash
set -e

LATEST=$(git tag --sort=-v:refname | head -1)
if [ -z "$LATEST" ]; then
  NEXT="v0.0.1"
else
  MAJOR=$(echo "$LATEST" | sed 's/v//' | cut -d. -f1)
  MINOR=$(echo "$LATEST" | sed 's/v//' | cut -d. -f2)
  PATCH=$(echo "$LATEST" | sed 's/v//' | cut -d. -f3)
  NEXT="v${MAJOR}.${MINOR}.$((PATCH + 1))"
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
