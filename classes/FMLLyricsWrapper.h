/*******************************************************************************
 * FMLLyricsWrapper.h
 * FetchMyLyrics
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
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
