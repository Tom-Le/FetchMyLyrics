/*******************************************************************************
 * LGRHook.xm
 * L'Fetcher
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMediaItem.h>
#import <iPodUI/IUMediaQueryNowPlayingItem.h>
//#import <iPodUI/IUNowPlayingAlbumFrontViewController.h> // not really needed
//#import <iPodUI/IUNowPlayingPortraitViewController.h>

#import "LGRController.h"
#import "LGRCommon.h"

%config(generator=internal)

%hook MediaApplication

/*
 * Hook: - [MediaApplication application:didFinishLaunchingWithOptions:]
 * Goal: Initialize an instance of LGRController to be used later.
 *       Will delegate most of the initialization to another thread
 *       to avoid locking the UI up.
 */
- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2
{
    // I don't even know why this method's return type is BOOL,
    // what a load of BOOLcrap.

    [[LGRController sharedController] setup];

    return %orig;
}

%end

%hook IUMediaQueryNowPlayingItem

/*
 * Hook   : - [IUMediaQueryNowPlayingItem initWithMediaItem:]
 * Goal   : Report to shared LGRController instance every time a song is going
 *          to be played, so the instance can have a chance to prepare lyrics.
 * Caveats: Not sure if this is the right place to hook to.
 */
- (id)initWithMediaItem:(id)mediaItem
{
    id ret = %orig;
    if (mediaItem && ret)
        if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(ret)]])
        {
            IUMediaQueryNowPlayingItem *item = (IUMediaQueryNowPlayingItem *)ret;
            [[LGRController sharedController] handleSongWithNowPlayingItem:item]; 
        }

    return ret;
}

/*
 * Hook: - [IUMediaQueryNowPlayingItem displayableText]
 * Goal: Provide our own version of the lyrics if the song has none. 
 * Note: This method is triggered whenever a notification with name
 *       "MPAVItemDisplayableTextAvailableNotification" is posted (through
 *       NSNotificationCenter). Thus, whenever a lyrics-fetching task is complete,
 *       it will post a notification with this name to update the UI.
 *       Took me a few days to find out about this.
 */
- (id)displayableText
{
    NSString *lyrics = (NSString *)%orig;
    if (lyrics == nil)
    {
        NSString *title = [[self mediaItem] valueForProperty:@"title"];
        NSString *artist = [[self mediaItem] valueForProperty:@"artist"];
        return [[LGRController sharedController] lyricsForSongWithTitle:title artist:artist];
    }

    return lyrics;
}

%end

%hook MPPortraitInfoOverlay

- (id)initWithFrame:(CGRect)frame
{
    id view = %orig;
    if (view)
        [[LGRController sharedController] setCurrentInfoOverlay:self];

    return view;
}

- (void)dealloc
{
    [[LGRController sharedController] ridCurrentInfoOverlay];
    %orig;
}

%end
