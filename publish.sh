#!/bin/sh

# Uncomment for debugging
#set -x

# Set bash script to exit immediately if any commands fail
set -e

VERSION="5.1.4"
PACKAGE_NAME="ExpoFpCrowdConnected"

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "main" ]; then
    echo "❌ Current branch is not main (current branch is: $current_branch)"
    exit 1
fi

echo "🛃 Updating version."
sed -i '' "s/\(spec\.version[^)]*= *\"\)[^\"]*/\1$VERSION/" "$PACKAGE_NAME.podspec"
sed -i '' "s/\(\.package([^)]*from: *\"\)[^\"]*/\1$VERSION/" README.md
sed -i '' "s/\(pod '.*', *['\"]~> *\)[^'\"]*/\1$VERSION/" README.md

echo "🛜 Publishing $PACKAGE_NAME."
git add -A && git commit -m "Release v$VERSION"
git tag "$VERSION"
git push --tags
git push
pod repo update
pod lib lint
pod trunk push

echo "✅ Publishing complete."
