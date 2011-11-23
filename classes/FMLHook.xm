/*******************************************************************************
 * FMLHook.xm
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMediaItem.h>
#import <iPodUI/IUMediaQueryNowPlayingItem.h>
//#import <iPodUI/IUNowPlayingAlbumFrontViewController.h> // not really needed
//#import <iPodUI/IUNowPlayingPortraitViewController.h>

#import "FMLController.h"
#import "FMLCommon.h"

%config(generator=internal)

%hook MediaApplication

/*
 * Hook: - [MediaApplication application:didFinishLaunchingWithOptions:]
 * Goal: Initialize an instance of FMLController to be used later.
 *       Will delegate most of the initialization to another thread
 *       to avoid locking the UI up.
 */
- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2
{
    // I don't even know why this method's return type is BOOL,
    // what a load of BOOLcrap.

    [[FMLController sharedController] setup];

    return %orig;
}

%end

%hook IUMediaQueryNowPlayingItem

/*
 * Hook   : - [IUMediaQueryNowPlayingItem initWithMediaItem:]
 * Goal   : Report to shared FMLController instance every time a song is going
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
            [[FMLController sharedController] handleSongWithNowPlayingItem:item]; 
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
        return [[FMLController sharedController] lyricsForSongWithTitle:title artist:artist];
    }

    return lyrics;
}

%end

%hook MPPortraitInfoOverlay

/*
 * Hooks: - [MPPortraitInfoOverlay initWithFrame:]
 *        - [MPPortraitInfoOverlay dealloc]
 * Goal : Retain a reference to the portrait view, so that we can refresh the
 *        lyrics text view when our operations return with new lyrics.
 */
- (id)initWithFrame:(CGRect)frame
{
    id view = %orig;
    if (view)
        [[FMLController sharedController] setCurrentInfoOverlay:self];

    return view;
}

- (void)dealloc
{
    [[FMLController sharedController] ridCurrentInfoOverlay];
    %orig;
}

%end

// MIT admit me pl0x kthx love u too
