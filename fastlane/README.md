fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android bootstrap

```sh
[bundle exec] fastlane android bootstrap
```

Ensures flutter is installed

### android build

```sh
[bundle exec] fastlane android build
```

Build apk file

### android build_aab

```sh
[bundle exec] fastlane android build_aab
```

Build aab file

### android changelog

```sh
[bundle exec] fastlane android changelog
```

Writes playstore changelogs from CHANGELOG.md

### android upload

```sh
[bundle exec] fastlane android upload
```

Uploads appbundle to playstore

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Build appbundle and upload to playstore

----


## iOS

### ios bootstrap

```sh
[bundle exec] fastlane ios bootstrap
```

Ensures flutter is installed

### ios build

```sh
[bundle exec] fastlane ios build
```

Build ios archive

### ios package_release

```sh
[bundle exec] fastlane ios package_release
```

Package ios archive into ipa

----


## windows

### windows bootstrap

```sh
[bundle exec] fastlane windows bootstrap
```

Ensures InnoSetup is installed

### windows build

```sh
[bundle exec] fastlane windows build
```

Builds an exe installer with fastforge and InnoSetup

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
