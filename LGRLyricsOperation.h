/*******************************************************************************
 * LGRLyricsOperation.h
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, available here: http://bit.ly/vSZSvM
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class LGRController, LGRLyricsWrapper, LGRLyricsWikiAPIParser, LGRLyricsWikiPageParser, IUMediaQueryNowPlayingItem;

@interface LGRLyricsOperation : NSOperation { 
    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;
    IUMediaQueryNowPlayingItem *_nowPlayingItem;
    
    NSAutoreleasePool *_pool;

    BOOL _executing;
    BOOL _finished;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, retain) IUMediaQueryNowPlayingItem *nowPlayingItem; 

- (id)init;
+ (id)operation;

- (void)completeOperation;

@end
