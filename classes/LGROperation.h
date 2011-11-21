/*******************************************************************************
 * LGROperation.h
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source. 
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class IUMediaQueryNowPlayingItem;

@interface LGROperation : NSOperation {
    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;

    IUMediaQueryNowPlayingItem *_nowPlayingItem;

    BOOL _abs_finished;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, retain) IUMediaQueryNowPlayingItem *nowPlayingItem; 

- (id)init;
+ (id)operation;

@end

