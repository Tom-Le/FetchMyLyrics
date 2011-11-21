/*******************************************************************************
 * LGRLyricsWikiOperation.h
 * iPodLyrics
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source.
 ******************************************************************************/

#import <Foundation/Foundation.h>

#import "LGROperation.h"

@class LGRController, LGRLyricsWrapper, LGRLyricsWikiAPIParser, LGRLyricsWikiPageParser, IUMediaQueryNowPlayingItem;

@interface LGRLyricsWikiOperation : LGROperation { 
    NSAutoreleasePool *_pool;

    BOOL _executing;
    BOOL _finished;
}

- (id)init;
+ (id)operation;

- (void)completeOperation;

@end
