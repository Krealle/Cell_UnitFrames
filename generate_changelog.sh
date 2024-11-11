#!/bin/bash

version=$( git describe --tags --always )
tag=$( git describe --tags --always --abbrev=0 )

if [ "$version" = "$tag" ]; then # on a tag
  current="$tag"
  previous=$( git describe --tags --abbrev=0 HEAD~ )
  if [[ $previous == *beta* ]]; then
    if [[ $tag == *beta* ]]; then
      previous=$( git describe --tags --abbrev=0 HEAD~ )
    else
      previous=$( git describe --tags --abbrev=0 --exclude="*beta*" HEAD~ )
    fi
  else
    previous=$( git describe --tags --abbrev=0 HEAD~ )
  fi
else
  current=$( git log -1 --format="%H" )
  previous="$tag"
fi

date=$( git log -1 --date=short --format="%ad" )
url=$( git remote get-url origin | sed -e 's/^git@\(.*\):/https:\/\/\1\//' -e 's/\.git$//' )

echo -ne "# [${version}](${url}/tree/${current}) ($date)\n\n[Full Changelog](${url}/compare/${previous}...${current})\n\n" > "CHANGELOG.md"

if [ "$version" = "$tag" ]; then # on a tag
  # Fetch release notes using GitHub CLI
  releaseNotes=$(gh release view "$tag" --json body -q ".body")
  echo -ne "## Release Notes\n${releaseNotes}\n" >> "CHANGELOG.md"
fi

# Create temporary file to store shortlog output
tempFile=$(mktemp)

# Append commits to temporary file
git shortlog --no-merges --reverse "$previous..$current" > "$tempFile"

# Initialize arrays to hold categorized commits
featureCommits=()
bugfixCommits=()
misCommits=()

# Read the temporary file line by line
while IFS= read -r line; do
  # Strip leading whitespace and extract commit message
  commitMessage=$(echo "$line" | sed -e 's/^\s*[^ ]\+ //')

  # Check for commit suffixes
  if echo "$line" | grep -q "\[Feature\]"; then
    # Remove suffix and add to features array
    featureCommits+=("- ${commitMessage//\[Feature\]/}")
  elif echo "$line" | grep -q "\[Bugfix\]"; then
    # Remove suffix and add to bugfixes array
    bugfixCommits+=("- ${commitMessage//\[Bugfix\]/}")
  elif echo "$line" | grep -q "\[Misc\]"; then
    # Remove suffix and add to bugfixes array
    misCommits+=("- ${commitMessage//\[Misc\]/}")
  fi
done < "$tempFile"

# Clean up temporary file
rm "$tempFile"

# Write results to changelog
{
  if [ ${#featureCommits[@]} -ne 0 ]; then
    echo -ne "### Features\n"
    for commit in "${featureCommits[@]}"; do
      echo "$commit"
    done
  fi

  if [ ${#bugfixCommits[@]} -ne 0 ]; then
    echo -ne "### Bug Fixes\n"
    for commit in "${bugfixCommits[@]}"; do
      echo "$commit"
    done
  fi

  if [ ${#misCommits[@]} -ne 0 ]; then
    echo -ne "### Miscellaneous\n"
    for commit in "${misCommits[@]}"; do
      echo "$commit"
    done
  fi
} >> "CHANGELOG.md"