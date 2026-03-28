#!/bin/bash
set -e

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
