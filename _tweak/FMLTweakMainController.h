/*******************************************************************************
 * FMLTweakMainController.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <UIKit/UIKit.h>

extern NSString * const kFMLLyricsOperationsFolder;

@class FMLLyricsManager, FMLOperation;

@interface FMLTweakMainController : NSObject {
    NSOperationQueue *_lyricsFetchOperationQueue;
    FMLLyricsManager *_lyricsManager;

    BOOL _ready;
}

+ (id)sharedController;

- (void)handleSongWithNowPlayingItem:(id)item;
- (NSString *)lyricsForSongWithTitle:(NSString *)title
                              artist:(NSString *)artist;
- (void)operationDidReturnWithLyrics:(NSNotification *)notification;

- (void)reloadDisplayableTextViewForSongTitle:(NSString *)title artist:(NSString *)artist;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationDidEnterBackground:(NSNotification *)notification;
- (void)applicationWillTerminate:(NSNotification *)notification;

@end
