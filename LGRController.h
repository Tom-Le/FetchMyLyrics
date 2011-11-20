/*******************************************************************************
 * LGRController.h
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, available here: http://bit.ly/vSZSvM
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class IUMediaQueryNowPlayingItem, MPMediaItem, MPPortraitInfoOverlay, LGRLyricsWrapper, LGRLyricsOperation;

@interface LGRController : NSObject {
    NSOperationQueue *_itemHandleOperationQueue;
    NSOperationQueue *_lyricsFetchOperationQueue;
    NSMutableArray *_lyricsWrappers;

    MPPortraitInfoOverlay *_currentInfoOverlay;
}

- (void)handleSongWithNowPlayingItem:(IUMediaQueryNowPlayingItem *)item;
- (NSString *)lyricsForSongWithTitle:(NSString *)title
                              artist:(NSString *)artist;
- (void)operationReportsAvailableLyrics:(LGRLyricsOperation *)operation;

- (void)setCurrentInfoOverlay:(MPPortraitInfoOverlay *)overlay;
- (void)ridCurrentInfoOverlay;

+ (id)sharedController;
@end
