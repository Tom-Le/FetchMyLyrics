/*******************************************************************************
 * LGRAZLyricsOperation.h
 * L'Fetcher
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 ******************************************************************************/

#import <Foundation/Foundation.h>

#import "LGROperation.h"

@class LGRController, LGRLyricsWrapper, IUMediaQueryNowPlayingItem;

@interface LGRAZLyricsOperation : LGROperation {
    NSAutoreleasePool *_pool;

    BOOL _executing;
    BOOL _finished;
}

- (id)init;
+ (id)operation;

- (void)completeOperation;

@end
