#!/bin/sh

# Extract the lower bound flutter version from pubspec.yaml
# This is used to pin the version of the flutter sdk for reproducible builds.
# The version is expected to be somewhere in the pubspec.yaml file, in the
# "environment:" section, under the "flutter:" key.
# The version may be a range or a single version.
FLUTTER_VERSION=""

# Fetch the "environment:" section from pubspec.yaml
environment_keys=$(awk "/^environment:\\r?$/,/^\\r?$/" ./pubspec.yaml)

# Fetch the "flutter:" line from the "environment:" section
grep_result=$(echo "$environment_keys" | grep "^  flutter:")

# Check if we found a valid flutter version
if [ -z "$grep_result" ]; then
  echo "No valid 'flutter:' entry found under 'environment:' in pubspec.yaml"
  exit 1
fi

# Extract the version string from the line
version_string=$(echo "$grep_result" | sed -E 's/.*flutter:[[:space:]]*["'\'']?([^"'\'' ]+)["'\'']?.*/\1/')

# Split by <, >, =, and space to find the version.
# We look for the lower bound, so the first non-empty string is the version.
# This should also work if the version is not a range.
FLUTTER_VERSION=$(echo "$version_string" | awk -F"[<>= ]" '{for(i=1;i<=NF;i++) if($i!="") {print $i; exit}}')

# Check if we found a version
if [ -z "$FLUTTER_VERSION" ]; then
  echo "No valid flutter version found in the 'flutter:' entry."
  exit 1
fi

# Return the version
echo $FLUTTER_VERSION
