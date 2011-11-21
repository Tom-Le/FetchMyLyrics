/*******************************************************************************
 * LGRController.h
 * L'Fetcher
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source. 
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class IUMediaQueryNowPlayingItem, MPMediaItem, MPPortraitInfoOverlay, LGRLyricsWrapper, LGROperation, LGRLyricsWikiOperation;

@interface LGRController : NSObject {
    NSOperationQueue *_lyricsFetchOperationQueue;
    NSMutableArray *_lyricsWrappers;

    MPPortraitInfoOverlay *_currentInfoOverlay;

    BOOL _ready;
}

- (void)handleSongWithNowPlayingItem:(IUMediaQueryNowPlayingItem *)item;
- (NSString *)lyricsForSongWithTitle:(NSString *)title
                              artist:(NSString *)artist;
- (void)operationReportsAvailableLyrics:(LGROperation *)operation;

- (void)readFromLyricsStorageFile;
- (void)writeToLyricsStorageFile;

- (void)setCurrentInfoOverlay:(MPPortraitInfoOverlay *)overlay;
- (void)ridCurrentInfoOverlay;

+ (id)sharedController;
- (void)setup;
@end
