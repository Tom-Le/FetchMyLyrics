/*******************************************************************************
 * FMLAZLyricsOperation.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

#import "FMLOperation.h"

@interface FMLAZLyricsOperation : FMLOperation {
    NSAutoreleasePool *_pool;

    BOOL _executing;
    BOOL _finished;
}

- (id)init;
+ (id)operation;

- (void)completeOperation;

@end
