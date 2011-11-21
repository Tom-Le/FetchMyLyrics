/*******************************************************************************
 * LGRLyricsWikiOperation.h
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, available here: http://bit.ly/vSZSvM
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
