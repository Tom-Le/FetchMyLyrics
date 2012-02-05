/*******************************************************************************
 * FMLLyricsManager.m
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLLyricsManager.h"

#import <FMLCommon.h>

NSString * const kFMLLyricsStorageFile = @"/var/mobile/Library/FetchMyLyrics/storage";

@implementation FMLLyricsManager

#pragma mark Lyrics Management

- (NSString *)lyricsForSong:(NSString *)title
                     artist:(NSString *)artist
{
    for (NSDictionary *lyricsDict in _lyricsSet)
    {
        NSString *currTitle = [lyricsDict objectForKey:@"title"];
        NSString *currArtist = [lyricsDict objectForKey:@"artist"];
        if ([currTitle isEqualToString:title] && [currArtist isEqualToString:artist])
            return [lyricsDict objectForKey:@"lyrics"];
    }
    return nil;
}

- (void)addLyrics:(NSString *)lyrics
          forSong:(NSString *)title
           artist:(NSString *)artist
{
    // Check for duplicates
    for (NSDictionary *lyricsDict in _lyricsSet)
    {
        NSString *currTitle = [lyricsDict objectForKey:@"title"];
        NSString *currArtist = [lyricsDict objectForKey:@"artist"];
        if ([currTitle isEqualToString:title] && [currArtist isEqualToString:artist])
        {
            [_lyricsSet removeObject:lyricsDict];
            break;
        }
    }

    NSDictionary *newLyricsDict = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title",
                                                                             artist, @"artist",
                                                                             lyrics, @"lyrics", nil];
    [_lyricsSet addObject:newLyricsDict];
}

- (void)readFromLyricsStorageFile
{
    NSSet *newLyricsSet = nil;
    @try
    {
        newLyricsSet = [NSKeyedUnarchiver unarchiveObjectWithFile:kFMLLyricsStorageFile];
    }
    @catch (NSException *e)
    {
        DebugLog(@"DUN DUN DUN EXCEPTION: %@", e);
    }

    if (newLyricsSet)
    {
        [_lyricsSet release];
        _lyricsSet = [newLyricsSet mutableCopy];
    }
}

- (void)writeToLyricsStorageFile
{
    [NSKeyedArchiver archiveRootObject:_lyricsSet
                                toFile:kFMLLyricsStorageFile];
}

#pragma mark Initialization
- (id)init
{
    if ((self = [super init]))
    {
        _lyricsSet = [[NSMutableSet alloc] init];
    }
    return self;
}

@end
