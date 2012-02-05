/*******************************************************************************
 * FMLAZLyricsOperation.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

#import <FMLOperation.h>

@interface FMLAZLyricsOperation : NSOperation <FMLOperation> {
    NSAutoreleasePool *_pool;

    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;

    BOOL _executing;
    BOOL _finished;
}

@end
