/*******************************************************************************
 * FMLLyricsWrapper.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface FMLLyricsWrapper : NSObject <NSCoding> {
    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;

- (id)init;
+ (id)lyricsWrapper;

@end
