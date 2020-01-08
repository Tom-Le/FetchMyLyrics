⚠️ This tweak is now obselete since the Music app can download and
display lyrics itself. RIP.

MobileSubstrate tweak to download lyrics from the Internet for
Music/iPod.app. Compatible with iOS 5; might be compatible with iOS 4
in the future, but no guarantees.

**Compilation note**: Links to MediaPlayer.framework and
iPodUI.framework (private). Obtain these from the iOS SDK or your
iDevice.

♪

# Todo
1. Proper GUI. Right now, the tweak obtains lyrics in silence which is
creepy. Proper settings page would be nice.
2. Write back to iPod's library. Right now lyrics is stored under
`/var/mobile/Library/FetchMyLyrics/storage` (archived NSMutableArray).
Ultimate goal is to have the lyrics synced back to iTunes.

♪

# Attribution
- [theos][theos-link] by Dustin Howett. Awesome framework.
- [class-dump][class-dump-link] by Steve Nygard.
- MobileSubstrate by saurik.

[theos-link]:[https://github.com/DHowett/theos]
[class-dump-link]:[http://www.codethecode.com/projects/class-dump/]

♫
