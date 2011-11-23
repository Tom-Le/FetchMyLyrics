/*******************************************************************************
 * FMLOperation.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class IUMediaQueryNowPlayingItem;

@interface FMLOperation : NSOperation {
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

