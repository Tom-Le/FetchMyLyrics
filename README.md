MobileSubstrate tweak that helps Music.app/iPod.app grabs lyrics from the
Internet. Compatible with iOS 5. (Working on compatibility with iOS 4.)
Roughly tested on a third generation iPod touch (my iPod). Downloaded
lyrics are saved to `/private/var/mobile/Library/FetchMyLyrics/storage`.

Compilation notes
------------------
- Need `MediaPlayer.framework` (public) and `iPodUI.framework` (private).
Included with Xcode 4.2, but if you're not on a Mac, you can get it from
your iDevice.
- Need a class dump from the above frameworks. Drop the headers in
`./headers`. Note that compilation errors might result from headers
that need editing; check the error log when compiling.


Todo
-----
1. Show a button in Now Playing view that indicates the tweak's
status (disabled, fetching lyrics, enabled).
2. Non-static preferences, and preferences in Music/iPod.app.
3. Make a proper website for this because no one likes to be greeted
by a bunch of source code.

License
-------
MIT license, included with this repo.

Attribution
-----------
This tweak makes use of the following works:
- [theos][theos-link] by Dustin Howett. Awesome framework.
- [class-dump][class-dump-link] by Steve Nygard.
- MobileSubstrate by saurik. (I suppose you'd have known this by now)

[theos-link]:[https://github.com/DHowett/theos]
[class-dump-link]:[http://www.codethecode.com/projects/class-dump/]

So, yeah, thanks! Hugs and kisses! :3

About
-----
Made by a cute cat who calls himself Tom. :3
