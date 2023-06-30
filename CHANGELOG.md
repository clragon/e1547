# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [16.2.2+82] - 2023-06-30
### Fixed
- bookmarks showing incorrect data
- notifications failing to send

## [16.2.1+81] - 2023-06-10
### Fixed
- bookmarks showing incorrect data
- notifications failing to send

## [16.2.0+80] - 2023-06-06
### Added
- mark as read option for follow tiles
- opening posts from notifications

### Fixed
- wiki dialogs
- bookmarks appearing in timeline

## [16.1.0+79] - 2023-05-28
### Added
- Grouping notifications
- Notifications in foreground

### Changed
- Split notifications per tag
- Split Follows into Subscriptions and Bookmarks

### Fixed
- Pool order switch

## [16.0.0+78] - 2023-05-07
### Added
- notifications for follows
- log files
- more log entries
- log entry multi-select
- better server status catching

### Changed
- split timeline and follows
- hide blacklisted pool thumbnails

### Fixed
- editing follows
- app layout when opening virtual keyboards

## [15.4.2+77] - 2023-03-23
### Fixed
- performance
- settings ui jumping

## [15.4.1+76] - 2023-03-22
### Fixed
- duplicate download folders
- history sharing
- favorites displaying unavailable posts

## [15.4.0+75] - 2023-03-16
### Added
- blocking users

### Fixed
- tapping tag suggestions

## [15.3.1+74] - 2023-03-03
### Fixed
- wiki sheet actions overflowing
- removing unseen filter when marking all as read
- autocomplete breaking tags when using negatives
- autocomplete tapping on certain devices

## [15.3.0+73] - 2023-02-24
### Changed
- about screen design
- order of follows in folders and timeline

### Fixed
- cloudflare check when logged out
- adding posts to wrong host history

## [15.2.0+72] - 2023-02-16
### Added
- sheet handles
- windows installer build files
- new custom host screen
- pageview buttons for desktops

### Fixed
- search race condition
- pool history
- link ending parsing
- refreshing favorites
- follow timeline with multitag searches
- blacklist sync
- replying to comments with quotes
- history adding blacklisted posts
- layout in flag post screen

## [15.1.0+71] - 2022-12-28
### Added
- cloudflare cookie resolving
- favorite counts on user page

### Changed
- user page layouts for wide screens
- appbar design

### Fixed
- favorites for users without login
- comment upvoting
- loading parent/child posts

## [15.0.1+70] - 2022-12-11
### Changed
- pool reader mode now enabled by default

### Fixed
- error displays for when the site is down
- retrying loading items
- favorite and upvote setting

## [15.0.0+69] - 2022-11-28
### Added
- multi-select for follows
- pool thumbnails
- cancelling requests

### Changed
- dtext spoiler design
- dtext parsing
- pool tile design
- topic tile design

### Fixed
- saving logins
- parsing comments and replies with warnings

### Removed
- follows migration

## [14.0.1+68] - 2022-11-08
### Fixed
- host switch in settings

## [14.0.0+67] - 2022-11-07
### Added
- android download location
- fast follow updating algorithm

### Changed
- follows are now host dependant

### Fixed
- history entries on wrong host
- no history entry on host switch
- history link sharing
- downloads on certain android devices

## [13.0.1+66] - 2022-10-23
### Fixed
- pool parsing
- auto-vote on favoriting
- comment upvoting

## [13.0.0+65] - 2022-10-09
### Added
- follow timeline screen

### Fixed
- performance issues with favoriting
- video mute button

## [12.2.0+64] - 2022-09-06
### Added
- pool reader mode

### Fixed
- history mass-deleting

## [12.1.1+63] - 2022-09-06
### Fixed
- deleting history entries

## [12.1.0+62] - 2022-09-05
### Added
- better tablet layouts
- infinite history
- more history entry types
- pool search suggestions
- better link parsing

### Changed
- history filter drawer
- login screen design
- search button is no longer behind autocomplete

### Fixed
- history performance
- large image grid performance
- mass-favoriting
- pool search switches
- blacklist sync on login
- detail gallery swiping requesting new pages
- duplicate posts
- log file exports
- editing posts
- blacklisting avatars

### Removed
- "tiles adapt their size" grid option
- tap comment to reply

## [12.0.0+61] - 2022-07-31
### Added
- infinite history
- more history entry types
- pool search suggestions
- better link parsing

### Changed
- search button is no longer behind autocomplete

### Fixed
- detail gallery swiping requesting new pages
- duplicate posts
- log file exports
- editing posts
- blacklisting avatars

### Removed
- "tiles adapt their size" grid option
- tap comment to reply

## [11.0.0+60] - 2022-06-21
### Added
- deep link support
- app lockscreen
- logging for errors
- website link in about
- more tablet layouts

### Changed
- dtext parsing
- snackbars to material banners

### Removed
- combined follow screen

## [10.1.3+59] - 2022-04-15
### Changed
- history limit to 3'000

## [10.1.2+58] - 2022-04-15
### Changed
- history screen is no longer a root view

### Fixed
- lag when deleting history entries
- deleting history entries over limit

## [10.1.1+57] - 2022-04-06
### Added
- history link in drawer

### Changed
- dtext parsing

### Fixed
- unable to read follows while refreshing

### Removed
- fullscreen UI setting

## [10.1.0+56] - 2022-03-19
### Added
- filter for history
- history limit of 5'000 entries or older than 30 days
- better tablet layouts

### Changed
- follow and history tile sizes

## [10.0.1+55] - 2022-03-14
### Added
- history for posts, pools and tags
- http request caching
- double tap appbar to scroll to top

### Changed
- switched version number format to more closely resemble semantic versioning (1.9.10 -> 9.10.0)
- hiding post children if all are deleted

### Fixed
- downloaded posts not showing in gallery (android)
- blacklist syncrhonisation
- comment parsing
- follow tiles not updating during refresh

### Removed
- scroll to top button

## [1.9.10+53] - 2021-12-15
### Fixed
- support for android 12
- videos not muting immediately
- post reports always failing

## [1.9.9+52] - 2021-11-25
### Fixed
- gallery desynchronisation issue

## [1.9.7+50] - 2021-11-24
### Changed
- logged in user only actions are now always visible

### Fixed
- detail view swiping requesting pages

## [1.9.6+49] - 2021-11-23
### Added
- user profiles
- voting on comments
- reporting comments
- scroll to top button

### Changed
- target sdk to 30

### Fixed
- post duplication
- video ui
- forum usernames

### Removed
- double tapping appbar to scroll to top

## [1.9.5+48] - 2021-11-16
### Added
- context (right side) drawer buttons in appbars
- jump to last page button for topics

### Changed
- appbar design
- grid stagger settings name

### Fixed
- logging in
- dtext links

## [1.9.4+47] - 2021-11-14
### Added
- reporting posts
- flagging posts

### Changed
- blue color theme
- default home screen search
- default video mute

### Fixed
- editing post tags

## [1.9.3+46] - 2021-11-07
### Fixed
- android apk being invalid
- sending comments
- mass-favoriting

## [1.9.2+45] - 2021-11-01
### Fixed
- blacklisting follows
- download indicators
- downloads failing

## [1.9.1+44] - 2021-10-30
### Added
- video mute button
- mute video settings

### Changed
- video skip animation

### Fixed
- login update
- blacklist editor

## [1.9.0+43] - 2021-10-27
### Added
- blacklist sync with server (please backup your blacklist)
- advanced settings menu
- auto-upvote when favoriting
- post tile info bar
- hiding system ui in fullscreen
- experimental forum access
- right side drawer actions for pool order
- right side drawer actions for comment order
- loading screens for dtext links

### Changed
- settings options order
- app icon
- app theme colors
- dtext link parsing

### Fixed
- swiping on videos
- posts not refreshing on login/logout
- post tile size not updating
- hero animations in landscape
- updating user avatar

## [1.8.1+42] - 2021-07-07
### Added
- loading indicator for new pages
- double tapping videos to skip

### Changed
- follow appbar action location to drawer
- system ui visibility in fullscreen to visible

### Fixed
- post editing issues

## [1.8.0+41] - 2021-06-19
### Added
- following screen

### Changed
- pool ordering
- progress indicators
- landscape mode
- performance

### Fixed
- iOS video playing
- editing posts

## [1.7.4+40] - 2021-05-27
### Added
- video support on iOS
- image downloads for iOS
- blacklisting with \~

### Changed
- dtext parsing
- error message design
- light theme design

### Fixed
- image zoom reset
- wiki dialog tag subtraction

## [1.7.3+39] - 2021-04-15
### Added
- blacklist drawer
- multi-tag following
- adding tags to the current search
- more post tile grid options

### Changed
- wiki dialog design
- video player UI design
- dtext parsing
- themes

## [1.7.2+38] - 2020-11-16
### Added
- better tag search

### Fixed
- performance issues
- webm issues
- favorite / blacklist issues

## [1.7.1+37] - 2020-11-16
### Added
- post tile size configuration
- post tile staggering
- multiselecting post tiles with longpress

### Changed
- tag input design
- comments to be sorted oldest first

### Fixed
- tag input issues

## [1.7.0+36] - 2020-10-23
### Added
- video support
- ui animations
- user avatar in drawer
- opening webms

### Changed
- detail view design

## [1.6.2+35] - 2020-09-26
### Added
- user avatar in drawer
- opening webms

### Changed
- detail view design

## [1.6.1+34] - 2020-09-15
### Added
- image preloading

### Changed
- appbar design to floating

### Fixed
- lag when swiping
- keyboard closing when choosing autocomplete

## [1.6.0+33] - 2020-08-10
### Added
- writing comments
- editing comments
- replying to comments
- swichting host without page resets

### Fixed
- blacklist ignoring rating
- pool duplicate pages

## [1.5.2+32] - 2020-07-26
### Changed
- following screen design

## [1.5.1+31] - 2020-07-21
### Fixed
- post editing

## [1.5.0+30] - 2020-07-21
### Added
- editing posts
- infinite fullscreen swiping
- dtext spoilers

### Changed
- package name
- blacklist page design

### Fixed
- tag autocomplete

## [1.4.3+29] - 2020-07-11
### Added
- warning about host switching
- replacing underscores with spaces in tags

### Fixed
- multiple artists bug
- alignment of large images

## [1.4.2+27] - 2020-06-23
### Changed
- changelog to display all new versions

### Fixed
- update notification

## [1.4.1+26] - 2020-06-23
### Fixed
- system ui color changing

## [1.4.0+25] - 2020-06-23
### Added
- themes
- showing blacklisted images

### Fixed
- blacklist issues

## [1.3.5+24] - 2020-06-09
### Added
- iOS support
- colors for tags
- centering small images in detail view
- swiping between images in fullscreen
- search tab in drawer

## [1.3.4+23] - 2020-05-17
### Added
- better landscape design

### Fixed
- blacklist removing favorites
- nested nested dtext parsing

## [1.3.3+22] - 2020-05-02
### Fixed
- parsing updated\_at json

## [1.3.2+21] - 2020-05-01
### Fixed
- downloads on android 10
- nested dtext parsing

## [1.3.1+20] - 2020-04-24
### Added
- wiki dialog in search appbar
- following pools

## [1.3.0+19] - 2020-04-23
### Added
- followed tags page
- following tags in wiki dialog
- multiline editor for blacklist

## [1.2.8+18] - 2020-04-22
### Changed
- dtext parsing

## [1.2.7+17] - 2020-04-21
### Added
- blocking tags in wiki dialog
- dtext parsing

### Fixed
- wiki dialog overflow

## [1.2.6+16] - 2020-04-20
### Added
- tag autocomplete for search
- hiding blacklisted post detail images

### Fixed
- logging in

## [1.2.5+15] - 2020-04-19
### Added
- local blacklist
- comment age and edited status

### Changed
- refreshing is now pull to refresh

## [1.2.4+14] - 2020-04-17
### Added
- voting on posts
- viewing post comments

### Fixed
- displaying quotes

## [1.2.3+13] - 2020-04-16
### Added
- opening deleted post children

### Fixed
- pool pages loading
- displaying onsite links

## [1.2.2+12] - 2020-04-14
### Added
- sharing post links
- sharing pool links
- long press tags to view wiki
- viewing deleted posts
- more dtext support
- addvanced pool information

### Fixed
- settings refreshing the correct page
- downloading posts
- dtext parsing links
- opening posts from a different post causing infinite load
- post duplicates in pools

## [1.2.1+11] - 2020-04-13
### Added
- post parent links
- post children links
- clickable links in post descriptions

### Fixed
- pool page lag
- post blackscreens
- favorite button while logged out
- settings changes refreshing the app

## [1.2.0+10] - 2020-04-13
### Added
- post descriptions
- more post information
- clicking on tags to launch search
- pool links on posts
- changelogs in about screen
- update hint in drawer
- pool descriptions in pool screen
- login button in settings

### Fixed
- repeating posts

## [1.1.5+9] - 2020-04-11
### Added
- more dtext support for pool descriptions
- version check on about screen

### Changed
- settings design
- app reloading after settings change

### Fixed
- network interupts causing infinite loading

## [1.1.4+8] - 2020-04-11
### Added
- support for newer API keys

## [1.1.3+7] - 2020-04-11
### Added
- pool descriptions
- links in pool descriptions

### Changed
- app theme to be darker
- empty post pages now indicate emptyness

### Fixed
- clicking multiple artists

## [1.1.2+6] - 2020-04-10
### Fixed
- Fixed hiding webms

## [1.1.1+5] - 2020-04-10
### Added
- logout button in drawer
- setting to hide webms
- support for landscape

### Changed
- login screen design
- about screen design
- favorites screen to prompt login

### Fixed
- pool order

## [1.1.0+4] - 2020-04-10
### Added
- pool search
- clicking on artist names to launch a search

## [1.0.1+2] - 2020-03-16
### Changed
- pagination to infinite scroll

## [1.0.0+1] - 2020-03-08
### Added
- favorites and hot screens in drawer

### Changed
- post detail design
- favorite button to be floating

### Fixed
- API client bindings

[16.2.2+82]: https://github.com/clragon/e1547/compare/16.2.1+81...16.2.2+82
[16.2.1+81]: https://github.com/clragon/e1547/compare/16.2.0+80...16.2.1+81
[16.2.0+80]: https://github.com/clragon/e1547/compare/16.1.0...16.2.0
[16.1.0+79]: https://github.com/clragon/e1547/compare/16.0.0...16.1.0
[16.0.0+78]: https://github.com/clragon/e1547/compare/15.4.2...16.0.0
[15.4.2+77]: https://github.com/clragon/e1547/compare/15.4.1...15.4.2
[15.4.1+76]: https://github.com/clragon/e1547/compare/15.4.0...15.4.1
[15.4.0+75]: https://github.com/clragon/e1547/compare/15.3.1...15.4.0
[15.3.1+74]: https://github.com/clragon/e1547/compare/15.3.0...15.3.1
[15.3.0+73]: https://github.com/clragon/e1547/compare/15.2.0...15.3.0
[15.2.0+72]: https://github.com/clragon/e1547/compare/15.1.0...15.2.0
[15.1.0+71]: https://github.com/clragon/e1547/compare/15.0.1...15.1.0
[15.0.1+70]: https://github.com/clragon/e1547/compare/15.0.0...15.0.1
[15.0.0+69]: https://github.com/clragon/e1547/compare/14.0.1...15.0.0
[14.0.1+68]: https://github.com/clragon/e1547/compare/14.0.0...14.0.1
[14.0.0+67]: https://github.com/clragon/e1547/compare/13.0.1...14.0.0
[13.0.1+66]: https://github.com/clragon/e1547/compare/13.0.0...13.0.1
[13.0.0+65]: https://github.com/clragon/e1547/compare/12.2.0...13.0.0
[12.2.0+64]: https://github.com/clragon/e1547/compare/12.1.1...12.2.0
[12.1.1+63]: https://github.com/clragon/e1547/compare/12.1.0...12.1.1
[12.1.0+62]: https://github.com/clragon/e1547/compare/12.0.0...12.1.0
[12.0.0+61]: https://github.com/clragon/e1547/compare/11.0.0...12.0.0
[11.0.0+60]: https://github.com/clragon/e1547/compare/10.1.3...11.0.0
[10.1.3+59]: https://github.com/clragon/e1547/compare/10.1.2...10.1.3
[10.1.2+58]: https://github.com/clragon/e1547/compare/10.1.1...10.1.2
[10.1.1+57]: https://github.com/clragon/e1547/compare/10.1.0...10.1.1
[10.1.0+56]: https://github.com/clragon/e1547/compare/10.0.1...10.1.0
[10.0.1+55]: https://github.com/clragon/e1547/compare/1.9.10...10.0.1
[1.9.10+53]: https://github.com/clragon/e1547/compare/1.9.9...1.9.10
[1.9.9+52]: https://github.com/clragon/e1547/compare/1.9.7...1.9.9
[1.9.7+50]: https://github.com/clragon/e1547/compare/1.9.6...1.9.7
[1.9.6+49]: https://github.com/clragon/e1547/compare/1.9.5...1.9.6
[1.9.5+48]: https://github.com/clragon/e1547/compare/1.9.4...1.9.5
[1.9.4+47]: https://github.com/clragon/e1547/compare/1.9.3...1.9.4
[1.9.3+46]: https://github.com/clragon/e1547/compare/1.9.2...1.9.3
[1.9.2+45]: https://github.com/clragon/e1547/compare/1.9.1...1.9.2
[1.9.1+44]: https://github.com/clragon/e1547/compare/1.9.0...1.9.1
[1.9.0+43]: https://github.com/clragon/e1547/compare/1.8.1...1.9.0
[1.8.1+42]: https://github.com/clragon/e1547/compare/1.8.0...1.8.1
[1.8.0+41]: https://github.com/clragon/e1547/compare/1.7.4...1.8.0
[1.7.4+40]: https://github.com/clragon/e1547/compare/1.7.3...1.7.4
[1.7.3+39]: https://github.com/clragon/e1547/compare/1.7.2...1.7.3
[1.7.2+38]: https://github.com/clragon/e1547/compare/1.7.1...1.7.2
[1.7.1+37]: https://github.com/clragon/e1547/compare/1.7.0...1.7.1
[1.7.0+36]: https://github.com/clragon/e1547/compare/1.6.2...1.7.0
[1.6.2+35]: https://github.com/clragon/e1547/compare/1.6.1...1.6.2
[1.6.1+34]: https://github.com/clragon/e1547/compare/1.6.0...1.6.1
[1.6.0+33]: https://github.com/clragon/e1547/compare/1.5.2...1.6.0
[1.5.2+32]: https://github.com/clragon/e1547/compare/1.5.1...1.5.2
[1.5.1+31]: https://github.com/clragon/e1547/compare/1.5.0...1.5.1
[1.5.0+30]: https://github.com/clragon/e1547/compare/1.4.3...1.5.0
[1.4.3+29]: https://github.com/clragon/e1547/compare/1.4.2...1.4.3
[1.4.2+27]: https://github.com/clragon/e1547/compare/1.4.1...1.4.2
[1.4.1+26]: https://github.com/clragon/e1547/compare/1.4.0...1.4.1
[1.4.0+25]: https://github.com/clragon/e1547/compare/1.3.5...1.4.0
[1.3.5+24]: https://github.com/clragon/e1547/compare/1.3.4...1.3.5
[1.3.4+23]: https://github.com/clragon/e1547/compare/1.3.3...1.3.4
[1.3.3+22]: https://github.com/clragon/e1547/compare/1.3.2...1.3.3
[1.3.2+21]: https://github.com/clragon/e1547/compare/1.3.1...1.3.2
[1.3.1+20]: https://github.com/clragon/e1547/compare/1.3.0...1.3.1
[1.3.0+19]: https://github.com/clragon/e1547/compare/1.2.8...1.3.0
[1.2.8+18]: https://github.com/clragon/e1547/compare/1.2.7...1.2.8
[1.2.7+17]: https://github.com/clragon/e1547/compare/1.2.6...1.2.7
[1.2.6+16]: https://github.com/clragon/e1547/compare/1.2.5...1.2.6
[1.2.5+15]: https://github.com/clragon/e1547/compare/1.2.4...1.2.5
[1.2.4+14]: https://github.com/clragon/e1547/compare/1.2.3...1.2.4
[1.2.3+13]: https://github.com/clragon/e1547/compare/1.2.2...1.2.3
[1.2.2+12]: https://github.com/clragon/e1547/compare/1.2.1...1.2.2
[1.2.1+11]: https://github.com/clragon/e1547/compare/1.2.0...1.2.1
[1.2.0+10]: https://github.com/clragon/e1547/compare/1.1.5...1.2.0
[1.1.5+9]: https://github.com/clragon/e1547/compare/1.1.4...1.1.5
[1.1.4+8]: https://github.com/clragon/e1547/compare/1.1.3...1.1.4
[1.1.3+7]: https://github.com/clragon/e1547/compare/1.1.2...1.1.3
[1.1.2+6]: https://github.com/clragon/e1547/compare/1.1.1...1.1.2
[1.1.1+5]: https://github.com/clragon/e1547/compare/1.1.0...1.1.1
[1.1.0+4]: https://github.com/clragon/e1547/compare/1.0.1...1.1.0
[1.0.1+2]: https://github.com/clragon/e1547/compare/1.0.0...1.0.1
[1.0.0+1]: https://github.com/clragon/e1547/releases/tag/1.0.0
