/*******************************************************************************
 * FMLLyricsManager.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

extern NSString * const kFMLLyricsStorageFile;

@interface FMLLyricsManager : NSObject {
    NSMutableSet *_lyricsSet;
}

- (id)init;

- (void)addLyrics:(NSString *)lyrics
          forSong:(NSString *)title
           artist:(NSString *)artist;
- (NSString *)lyricsForSong:(NSString *)title
                     artist:(NSString *)artist;

- (void)readFromLyricsStorageFile;
- (void)writeToLyricsStorageFile;

@end
