MobileSubstrate tweak that helps Music.app/iPod.app grabs lyrics from the
Internet. Compatible with iOS 5. (Working on compatibility with iOS 4.)
Roughly tested on a third generation iPod touch (my iPod). Downloaded
lyrics are saved to `/private/var/mobile/Library/lfetcher/storage`.

Note: "L'Fetcher" is not its official name. (I am aware that this name
sucks, but I'm not an English major. Halp?) :-(

Compilation notes
------------------
- Need `MediaPlayer.framework` (public) and `iPodUI.framework` (private).
Included with Xcode.
- Make use of Dustin Howett's excellent [theos][theos-link].

[theos-link]:[https://github.com/DHowett/theos]

Todo
-----
1. Show a button in Now Playing view that indicates the tweak's
status (disabled, fetching lyrics, enabled).
2. Preferences (preferably in Settings.app, like Activator).
3. Make a proper website for this because no one likes to be greeted
by a bunch of files.

License
-------
WTFPL. Attribution would be really nice, but not necessary. Would be
really, really, really nice though... :3

About
-----
Made by a cute cat who calls himself Tom. :3
