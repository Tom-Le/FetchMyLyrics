/*******************************************************************************
 * LGRController.h
 * L'Fetcher
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
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
