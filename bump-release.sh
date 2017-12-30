#!/bin/bash

if [[ -z "$*" ]]; then
	>&2 echo "usage: bump-release.sh <oldversion> <newversion>"
	exit
fi

old="$1"
new="$2"

flutter clean
flutter build apk --release

name="e1547_v${old}"

cp build/app/outputs/apk/release/app-release.apk "${name}.apk"

files=(
	"android/app/src/main/AndroidManifest.xml"
	"lib/consts.dart"
)

# Substitute old version number for new one everywhere
sed -i -e "s:${old}:${new}:g" "${files[@]}"

# Bump version code. see: http://stackoverflow.com/a/14348899/7929790
sed -i -r 's/(.*)(versionCode=")([0-9]+)(".*)/echo "\1\2\\"$((\3+1))\\"\4"/ge' \
	"android/app/src/main/AndroidManifest.xml"

git commit -m "Bump version to $new" "${files[@]}"
