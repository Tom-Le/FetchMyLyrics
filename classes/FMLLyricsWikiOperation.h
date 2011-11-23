/*******************************************************************************
 * FMLLyricsWikiOperation.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

#import "FMLOperation.h"

@class FMLController, FMLLyricsWrapper, FMLLyricsWikiAPIParser, FMLLyricsWikiPageParser, IUMediaQueryNowPlayingItem;

@interface FMLLyricsWikiOperation : FMLOperation { 
    NSAutoreleasePool *_pool;

    BOOL _executing;
    BOOL _finished;
}

- (void)completeOperation;

@end
