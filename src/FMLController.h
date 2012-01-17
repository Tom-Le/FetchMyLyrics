/*******************************************************************************
 * FMLController.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

extern NSString * const kFMLLyricsStorageFolder;
extern NSString * const kFMLLyricsOperationsFolder;

@class FMLLyricsWrapper, FMLOperation;

@interface FMLController : NSObject {
    NSOperationQueue *_lyricsFetchOperationQueue;
    NSMutableArray *_lyricsWrappers;

    id _currentInfoOverlay;

    BOOL _ready;
}

- (void)handleSongWithNowPlayingItem:(id)item;
- (NSString *)lyricsForSongWithTitle:(NSString *)title
                              artist:(NSString *)artist;
- (void)operationDidReturnWithLyrics:(NSNotification *)notification;

- (void)readFromLyricsStorageFile;
- (void)writeToLyricsStorageFile;

- (void)setCurrentInfoOverlay:(id)overlay;
- (void)ridCurrentInfoOverlay;
- (void)reloadDisplayableTextView;

+ (id)sharedController;
- (void)setup;
@end
