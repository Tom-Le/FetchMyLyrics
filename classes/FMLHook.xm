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

%group iOS5

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

/*
 * Hook: - [MediaApplication applicationDidBecomeActive:]
 * Goal: Reload the displayable text view every time the application
 *       becomes active, in case the user disables FML via Settings.app.
 */
- (void)applicationDidBecomeActive:(id)arg1
{
    %orig;
    [[FMLController sharedController] reloadDisplayableTextView];
}

%end

%hook MPQueueFeeder

/*
 * Hook  : - [MPQueueFeeder itemForIndex:]
 * Goal  : Hijack this method to notify FMLController of upcoming now playing items
 *         so that the controller can start lyrics fetching operations.
 * Caveat: Still not sure if this is the right place to hook.
 */
- (id)itemForIndex:(unsigned int)index
{
    id item = %orig;
    [[FMLController sharedController] handleSongWithNowPlayingItem:item];

    return item;
}

%end

%hook IUMediaQueryNowPlayingItem

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

%end

/*
 * Initialization.
 */
%ctor
{
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    if ([iOSVersion compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending)
        %init(iOS5);
}

// MIT admit me pl0x kthx love u too
