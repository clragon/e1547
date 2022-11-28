# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [15.0.0] - 2022-11-28
niche specialisation

### Added

- multi-select for follows
- pool thumbnails
- cancelling requests

### Fixed

- saving logins
- parsing comments and replies with warnings

### Changed

- dtext spoiler design
- dtext parsing
- pool tile design
- topic tile design

### Removed

- follows migration

## [14.0.1] - 2022-11-08

hosting restored

### Fixed

- host switch in settings

## [14.0.0] - 2022-11-07

keeping up to date

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

## [13.0.1] - 2022-10-23

pools open

### Fixed

- pool parsing
- auto-vote on favoriting
- comment upvoting

## [13.0.0] - 2022-10-09

tweet

### Added

- follow timeline screen

### Fixed

- performance issues with favoriting
- video mute button

## [12.2.0] - 2022-09-06

comics in the library

### Added

- pool reader mode

### Fixed

- history mass-deleting

## [12.1.1] - 2022-09-06

new receptionist

### Fixed

- deleting history entries

## [12.1.0] - 2022-09-05

furnished library

### Added

- better tablet layouts

### Changed

- history filter drawer
- login screen design

### Fixed

- history performance
- large image grid performance
- mass-favoriting
- pool search switches
- blacklist sync on login

### [12.0.0] - 2022-07-31

The library of alexandria

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

## [11.0.0] - 2022-06-21

portal to the outside

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

## [10.1.3] - 2022-04-15

compress the library

### Changed

- history limit to 3'000

## [10.1.2] - 2022-04-15

stop the library from exploding

### Changed

- history screen is no longer a root view

### Fixed

- lag when deleting history entries
- deleting history entries over limit

## [10.1.1] - 2022-04-06

borrow a book

### Added

- history link in drawer

### Changed

- dtext parsing

### Fixed

- unable to read follows while refreshing

### Removed

- fullscreen UI setting

## [10.1.0] - 2022-03-19

bookkeeping

### Added

- filter for history
- history limit of 5'000 entries or older than 30 days
- better tablet layouts

### Changed

- follow and history tile sizes

## [10.0.1] - 2022-03-14

writing history

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

## [10.0.0] - 2022-03-14 [YANKED]
Lost to time

## [1.9.10] - 2021-12-15

android juice

### Fixed

- support for android 12
- videos not muting immediately
- post reports always failing

## [1.9.9] - 2021-11-25

release me but for real this time

### Fixed

- gallery desynchronisation issue

## [1.9.8] - 2021-11-25 [YANKED]

release me

### Fixed

- gallery desynchronisation issue

### Fixed

- gallery desynchronisation issue

## [1.9.7] - 2021-11-24

You must be logged in to do that!

### Changed

- logged in user only actions are now always visible

### Fixed

- detail view swiping requesting pages

## [1.9.6] - 2021-11-23

its getting personal

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

## [1.9.5] - 2021-11-16

hear no bugs, see no bugs.

### Added

- context (right side) drawer buttons in appbars
- jump to last page button for topics

### Changed

- appbar design
- grid stagger settings name

### Fixed

- logging in
- dtext links

## [1.9.4] - 2021-11-14

like shiny diamond

### Added

- reporting posts
- flagging posts

### Changed

- blue color theme
- default home screen search
- default video mute

### Fixed

- editing post tags

## [1.9.3] - 2021-11-07

like shiny marble

### Fixed

- android apk being invalid
- sending comments
- mass-favoriting

## [1.9.2] - 2021-11-01

PlayStore preparation 2

### Fixed

- blacklisting follows
- download indicators
- downloads failing

## [1.9.1] - 2021-10-30

float like a butterfly

### Added

- video mute button
- mute video settings

### Changed

- video skip animation

### Fixed

- login update
- blacklist editor

## [1.9.0] - 2021-10-27

sting like a bee

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

## [1.8.1] - 2021-07-07

loading indicators and contextual drawers

### Added

- loading indicator for new pages
- double tapping videos to skip

### Changed

- follow appbar action location to drawer
- system ui visibility in fullscreen to visible

### Fixed

- post editing issues

## [1.8.0] - 2021-06-19

follow tags, but for real this time

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

## [1.7.4] - 2021-05-27

the i in iOS

### Added

- video support on iOS
- image downloads for iOS
- blacklisting with ~

### Changed

- dtext parsing
- error message design
- light theme design

### Fixed

- image zoom reset
- wiki dialog tag subtraction

## [1.7.3] - 2021-04-15

maximum control

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

## [1.7.2] - 2020-11-16

recycling

### Added

- better tag search

### Fixed

- performance issues
- webm issues
- favorite / blacklist issues

## [1.7.1] - 2020-11-16

multipost drifting

### Added

- post tile size configuration
- post tile staggering
- multiselecting post tiles with longpress

### Changed

- tag input design
- comments to be sorted oldest first

### Fixed

- tag input issues

## [1.7.0] - 2020-10-23

motion pictures

### Added

- video support
- ui animations

## [1.6.2] - 2020-09-26

4 elements

### Added

- user avatar in drawer
- opening webms

### Changed

- detail view design

## [1.6.1] - 2020-09-15

Now this is swiping!

### Added

- image preloading

### Changed

- appbar design to floating

### Fixed

- lag when swiping
- keyboard closing when choosing autocomplete

## [1.6.0] - 2020-08-10

Making your voice heard

### Added

- writing comments
- editing comments
- replying to comments
- swichting host without page resets

### Fixed

- blacklist ignoring rating
- pool duplicate pages

## [1.5.2] - 2020-07-26

Quality of Life II

### Changed

- following screen design

## [1.5.1] - 2020-07-21

Edit Hotpatch

### Fixed

- post editing

## [1.5.0] - 2020-07-21

Post Editing

### Added

- editing posts
- infinite fullscreen swiping
- dtext spoilers

### Changed

- package name
- blacklist page design

### Fixed

- tag autocomplete

## [1.4.3] - 2020-07-11

PlayStore preparation

### Added

- warning about host switching
- replacing underscores with spaces in tags

### Fixed

- multiple artists bug
- alignment of large images

## [1.4.2] - 2020-06-23

Update hotpatch

### Changed

- changelog to display all new versions

### Fixed

- update notification

## [1.4.1] - 2020-06-23

UI color hotpatch

### Fixed

- system ui color changing

## [1.4.0] - 2020-06-23

I'm blue

### Added

- themes
- showing blacklisted images

### Fixed

- blacklist issues

## [1.3.5] - 2020-06-09

swiper, no swiping

### Added

- iOS support
- colors for tags
- centering small images in detail view
- swiping between images in fullscreen
- search tab in drawer

## [1.3.4] - 2020-05-17

Landscape mode+

### Added

- better landscape design

### Fixed

- blacklist removing favorites
- nested nested dtext parsing

## [1.3.3] - 2020-05-02

Date hotpatch

### Fixed

- parsing updated_at json

## [1.3.2] - 2020-05-01

Download hotpatch

### Fixed

- downloads on android 10
- nested dtext parsing

## [1.3.1] - 2020-04-24

Toolbar rework

### Added

- wiki dialog in search appbar
- following pools

## [1.3.0] - 2020-04-23

Following tags

### Added

- followed tags page
- following tags in wiki dialog
- multiline editor for blacklist

## [1.2.8] - 2020-04-22

Better better DText

### Changed

- dtext parsing

## [1.2.7] - 2020-04-21

Better DText

### Added

- blocking tags in wiki dialog
- dtext parsing

### Fixed

- wiki dialog overflow

## [1.2.6] - 2020-04-20

Login hotpatch

### Added

- tag autocomplete for search
- hiding blacklisted post detail images

### Fixed

- logging in

## [1.2.5] - 2020-04-19

Blacklists

### Added

- local blacklist
- comment age and edited status

### Changed

- refreshing is now pull to refresh

## [1.2.4] - 2020-04-17

Voting

### Added

- voting on posts
- viewing post comments

### Fixed

- displaying quotes

## [1.2.3] - 2020-04-16

Pool hotpatch

### Added

- opening deleted post children

### Fixed

- pool pages loading
- displaying onsite links

## [1.2.2] - 2020-04-14

More patches (we're getting there)

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

## [1.2.1] - 2020-04-13

Patches

### Added

- post parent links
- post children links
- clickable links in post descriptions

### Fixed

- pool page lag
- post blackscreens
- favorite button while logged out
- settings changes refreshing the app

## [1.2.0] - 2020-04-13

Posts should now look fancy

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

## [1.1.5] - 2020-04-11

Quality of Life

### Added

- more dtext support for pool descriptions
- version check on about screen

### Changed

- settings design
- app reloading after settings change

### Fixed

- network interupts causing infinite loading

## [1.1.4] - 2020-04-11

New API keys supported

### Added

- support for newer API keys

## [1.1.3] - 2020-04-11

Regex made me do this

### Added

- pool descriptions
- links in pool descriptions

### Changed

- app theme to be darker
- empty post pages now indicate emptyness

### Fixed

- clicking multiple artists

## [1.1.2] - 2020-04-10

This one line ruined it all

### Fixed

- Fixed hiding webms

## [1.1.1] - 2020-04-10

The water was leaking so we used flex tape

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

## [1.1.0] - 2020-04-10

Now with water.

### Added

- pool search
- clicking on artist names to launch a search

## [1.0.1] - 2020-03-16

No more pages

### Changed

- pagination to infinite scroll

## [1.0.0] - 2020-03-08

Soft reboot

### Added

- favorites and hot screens in drawer

### Changed

- post detail design
- favorite button to be floating

### Fixed

- API client bindings

[unreleased]: https://github.com/clragon/e1547/compare/15.0.0...HEAD

[15.0.0]: https://github.com/clragon/e1547/compare/14.0.1...15.0.0

[14.0.1]: https://github.com/clragon/e1547/compare/14.0.0...14.0.1

[14.0.0]: https://github.com/clragon/e1547/compare/13.0.1...14.0.0

[13.0.1]: https://github.com/clragon/e1547/compare/13.0.0...13.0.1

[13.0.0]: https://github.com/clragon/e1547/compare/12.2.0...13.0.0

[12.2.0]: https://github.com/clragon/e1547/compare/12.1.1...12.2.0

[12.1.1]: https://github.com/clragon/e1547/compare/12.1.0...12.1.1

[12.1.0]: https://github.com/clragon/e1547/compare/12.0.0...12.1.0

[12.0.0]: https://github.com/clragon/e1547/compare/11.0.0...12.0.0

[11.0.0]: https://github.com/clragon/e1547/compare/10.1.3...11.0.0

[10.1.3]: https://github.com/clragon/e1547/compare/10.1.2...10.1.3

[10.1.2]: https://github.com/clragon/e1547/compare/10.1.1...10.1.2

[10.1.1]: https://github.com/clragon/e1547/compare/10.1.0...10.1.1

[10.1.0]: https://github.com/clragon/e1547/compare/10.0.1...10.1.0

[10.0.1]: https://github.com/clragon/e1547/compare/1.9.10...10.0.1

[1.9.10]: https://github.com/clragon/e1547/compare/1.9.9...1.9.10

[1.9.9]: https://github.com/clragon/e1547/compare/1.9.8...1.9.9

[1.9.8]: https://github.com/clragon/e1547/compare/1.9.7...1.9.8

[1.9.7]: https://github.com/clragon/e1547/compare/1.9.6...1.9.7

[1.9.6]: https://github.com/clragon/e1547/compare/1.9.5...1.9.6

[1.9.5]: https://github.com/clragon/e1547/compare/1.9.4...1.9.5

[1.9.4]: https://github.com/clragon/e1547/compare/1.9.3...1.9.4

[1.9.3]: https://github.com/clragon/e1547/compare/1.9.2...1.9.3

[1.9.2]: https://github.com/clragon/e1547/compare/1.9.1...1.9.2

[1.9.1]: https://github.com/clragon/e1547/compare/1.9.0...1.9.1

[1.9.0]: https://github.com/clragon/e1547/compare/1.8.1...1.9.0

[1.8.1]: https://github.com/clragon/e1547/compare/1.8.0...1.8.1

[1.8.0]: https://github.com/clragon/e1547/compare/1.7.4...1.8.0

[1.7.4]: https://github.com/clragon/e1547/compare/1.7.3...1.7.4

[1.7.3]: https://github.com/clragon/e1547/compare/1.7.2...1.7.3

[1.7.2]: https://github.com/clragon/e1547/compare/1.7.1...1.7.2

[1.7.1]: https://github.com/clragon/e1547/compare/1.7.0...1.7.1

[1.7.0]: https://github.com/clragon/e1547/compare/1.6.1...1.7.0

[1.6.1]: https://github.com/clragon/e1547/compare/1.6.0...1.6.1

[1.6.0]: https://github.com/clragon/e1547/compare/1.5.2...1.6.0

[1.5.2]: https://github.com/clragon/e1547/compare/1.5.1...1.5.2

[1.5.1]: https://github.com/clragon/e1547/compare/1.5.0...1.5.1

[1.5.0]: https://github.com/clragon/e1547/compare/1.4.3...1.5.0

[1.4.3]: https://github.com/clragon/e1547/compare/1.4.2...1.4.3

[1.4.2]: https://github.com/clragon/e1547/compare/1.4.1...1.4.2

[1.4.1]: https://github.com/clragon/e1547/compare/1.4.0...1.4.1

[1.4.0]: https://github.com/clragon/e1547/compare/1.3.5...1.4.0

[1.3.5]: https://github.com/clragon/e1547/compare/1.3.4...1.3.5

[1.3.4]: https://github.com/clragon/e1547/compare/1.3.3...1.3.4

[1.3.3]: https://github.com/clragon/e1547/compare/1.3.2...1.3.3

[1.3.2]: https://github.com/clragon/e1547/compare/1.3.1...1.3.2

[1.3.1]: https://github.com/clragon/e1547/compare/1.3.0...1.3.1

[1.3.0]: https://github.com/clragon/e1547/compare/1.2.8...1.3.0

[1.2.8]: https://github.com/clragon/e1547/compare/1.2.7...1.2.8

[1.2.7]: https://github.com/clragon/e1547/compare/1.2.6...1.2.7

[1.2.6]: https://github.com/clragon/e1547/compare/1.2.5...1.2.6

[1.2.5]: https://github.com/clragon/e1547/compare/1.2.4...1.2.5

[1.2.4]: https://github.com/clragon/e1547/compare/1.2.3...1.2.4

[1.2.3]: https://github.com/clragon/e1547/compare/1.2.2...1.2.3

[1.2.2]: https://github.com/clragon/e1547/compare/1.2.1...1.2.2

[1.2.1]: https://github.com/clragon/e1547/compare/1.2.0...1.2.1

[1.2.0]: https://github.com/clragon/e1547/compare/1.1.5...1.2.0

[1.1.5]: https://github.com/clragon/e1547/compare/1.1.4...1.1.5

[1.1.4]: https://github.com/clragon/e1547/compare/1.1.3...1.1.4

[1.1.3]: https://github.com/clragon/e1547/compare/1.1.2...1.1.3

[1.1.2]: https://github.com/clragon/e1547/compare/1.1.1...1.1.2

[1.1.1]: https://github.com/clragon/e1547/compare/1.1.0...1.1.1

[1.1.0]: https://github.com/clragon/e1547/compare/1.0.1...1.1.0

[1.0.1]: https://github.com/clragon/e1547/compare/1.0.0...1.0.1

[1.0.0]: https://github.com/clragon/e1547/releases/tag/1.0.0