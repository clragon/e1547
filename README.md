
<table>
    <tr>
    <td width="20%">
    <img src="assets/icon/app/paw.png"/>
    </td>
    <td width="80%">
    <h1>e1547</h1>
    <h4>A mobile app to browse e621 and e926.</h4>
    <a href="https://github.com/clragon/e1547/commits/master"><img src="https://badgen.net/github/commits/clragon/e1547"></a>
    <a href="https://github.com/clragon/e1547/commits/master"><img src="https://badgen.net/github/last-commit/clragon/e1547"></a>
    <a href="blob/master/LICENSE"><img src="https://img.shields.io/github/license/clragon/e1547"><a>
    </td>
    </tr>
</table>


## Features  

- Browse and search posts
- Browse and search pools
- Edit posts
- Comment on posts
- Download Images
- Upvote and downvote posts
- Access to Hot and your favourites
- Follow tags (notifications planned)
- Display post info, launch searches from tags
- View tag wiki entries by long-pressing 
- Local blacklist
- DText parsing
- Hide Webm posts (playing webm planned)
- Automatic update check
- Multiple Themes to choose from
 

## Screenshots  
  
<p align="center">
  <img src="assets/screenshots/1547.gif">
</p>

v1.5.2 GIF by [Kritanta](https://github.com/KritantaDev) on iOS


## Download  
  
APK and IPA files can be found over at the [releases](https://github.com/clragon/e1547/releases/latest).  

## Installation

### Installing on Android

1. Download the latest APK
2. Open it on your Android device
3. ???
4. Profit

### Installing on iOS

#### Without Jailbreak:
- Follow the instructions on [AltStore](https://altstore.io/)

or 

#### With Jailbreak:
1. Grab [Cydia Impactor](http://www.cydiaimpactor.com/)
2. Drag the downloaded .ipa file onto Cydia Impactor after opening it. 
3. Enter your Apple ID and password. If the password fails, [use an App Specific 2fa Password](https://support.apple.com/en-us/HT204397#sections)

#### Installing on iOS 14

1. Follow the instructions in [Compiling for iOS](#iOS)
2. Run `flutter run --release` to install the App.

## Compilation

Compiling the app for yourself should be possible for both platforms, iOS and Android.

### Getting started

1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Clone the e1547 GitHub Repository

### Android

- Build with [Android Studio](https://developer.android.com/studio)

### iOS

**Compiling for iOS requires running macOS.**

- Run `ios/build.sh`

This will create a release build IPA file for you, as well as reduce the file size by removing unecessary Flutter artifacts.

## Contact
The app is currently under development.  
If you have questions/comments/suggestions, you can open a github Issue.  
You can also post in the [e926 forum thread](https://e926.net/forum_topics/25854).  

## Credit
- iOS build script is provided by [Kritanta](https://github.com/KritantaDev).

- iOS releases for this app are compiled by [CamperGuy](https://github.com/camperguy).

- This app is a continuation of a project by [Perlatus](https://github.com/perlatus).

- The e1547 logo and banner uses a [Paw Icon](https://fontawesome.com/icons/paw?style=solid) licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
