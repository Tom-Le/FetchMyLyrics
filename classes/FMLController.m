/*******************************************************************************
 * FMLController.m
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLController.h"
#import "FMLCommon.h"

#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPPortraitInfoOverlay.h>
#import <MediaPlayer/MPAVItem.h>
#import "FMLLyricsWrapper.h"
#import "FMLOperation.h"
#import "FMLLyricsWikiOperation.h"
#import "FMLAZLyricsOperation.h"

#define FMLLyricsStorageFolder @"~/Library/FetchMyLyrics/"

@implementation FMLController

#pragma mark Now Playing

/*
 * Function: Fetch lyrics if none exists for the specified song title
 *           and artist.
 * Note    : This method has to return as quickly as possible or the 
 *           UI will lock up badly.
 */
- (void)handleSongWithNowPlayingItem:(IUMediaQueryNowPlayingItem *)item
{
    // Since this method has to return ASAP, the whole task will be shoved
    // to another operation queue.
    //
    // NOTE: We use 2 queues for 2 different tasks:
    //       - Tasks in the global dispatch queue (default priority) handle arriving IUMediaQueryNowPlayingItem's.
    //       - Tasks in _lyricsFetchOperationQueue handle fetching the lyrics from the sky/Internet.

    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"FMLEnable"];
    if (_ready && enabled)
    {
        dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(global_queue, ^{
            // NOTE: Block inherits every ivar as well as local vars

            // If the song already has lyrics, return.
            if ([item hasDisplayableText])
                return;
     
            // Song info
            NSString *title = [[item mediaItem] valueForProperty:@"title"];
            NSString *artist = [[item mediaItem] valueForProperty:@"artist"];

            // If FMLController already has lyrics for the song, return.
            for (FMLLyricsWrapper *lw in _lyricsWrappers)
                if ([lw.title isEqualToString:title] && [lw.artist isEqualToString:artist])
                    return;

            // If a task is already running for the song requested, return.
            for (FMLLyricsWikiOperation *lo in [_lyricsFetchOperationQueue operations])
                if ([lo.title isEqualToString:title] && [lo.artist isEqualToString:artist])
                    return;

            // Start a new task to fetch the lyrics
            NSString *operationKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"FMLOperation"];
            FMLOperation *operation = [[[NSClassFromString(operationKey) alloc] init] autorelease];

            if (operation)
            {
                operation.title = title;
                operation.artist = artist;
                operation.nowPlayingItem = item;
                [_lyricsFetchOperationQueue addOperation:operation];
            }
        });
    }
}

/*
 * Functions: Update reference to _currentInfoOverlay
 * Note     : This MPPortraitInfoOverlay instance provides a bridge between our tweak and
 *            the now playing UI. In particular, we need a reference to this instance to
 *            update the UI whenever we fetch new lyrics for a song currently played.
 */
- (void)setCurrentInfoOverlay:(MPPortraitInfoOverlay *)overlay
{
    [self ridCurrentInfoOverlay];
    _currentInfoOverlay = [overlay retain];
}

- (void)ridCurrentInfoOverlay
{
    [_currentInfoOverlay release];
    _currentInfoOverlay = nil;
}

- (void)reloadDisplayableTextView
{
    if (_currentInfoOverlay)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_currentInfoOverlay _updateDisplayableTextViewForItem:_currentInfoOverlay.item
                                                           animate:YES];
        }];
    }
}

#pragma mark Lyrics
/*
 * Function: Return lyrics for a song with specified title and artist.
 */
- (NSString *)lyricsForSongWithTitle:(NSString *)title artist:(NSString *)artist
{
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"FMLEnable"];
    if (_ready && enabled)
    {
        @synchronized(_lyricsWrappers)
        {
            for (FMLLyricsWrapper *lw in _lyricsWrappers)
                if ([lw.title isEqualToString:title] && [lw.artist isEqualToString:artist]) 
                    return lw.lyrics; 
        }
    }

    // Found nothing or wasn't ready
    return nil;
}

/*
 * Function: Update our storage with new lyrics.
 */
- (void)operationReportsAvailableLyrics:(FMLOperation *)operation
{
    if (_ready)
    {
        // Prevent duplicates
        BOOL duplicate = NO;
        for (FMLLyricsWrapper *lw in _lyricsWrappers)
            if ([lw.title isEqualToString:operation.title] && [lw.artist isEqualToString:operation.artist]) 
                duplicate = YES;

        if (!duplicate)
        {
            // No duplicate found, add.
            FMLLyricsWrapper *wrapper = [FMLLyricsWrapper lyricsWrapper];
            wrapper.title = operation.title;
            wrapper.artist = operation.artist;
            wrapper.lyrics = operation.lyrics;
            @synchronized(_lyricsWrappers)
            {
                [_lyricsWrappers addObject:wrapper];
            }

            [self writeToLyricsStorageFile];
        }

        // Request the app update its lyrics display, but only if now playing song is the song whose lyrics was just fetched
        // and only if the tweak is enabled
        BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"FMLEnable"];
        if (enabled)
        {
            NSString *nowPlayingTitle = _currentInfoOverlay.item.mainTitle; 
            NSString *nowPlayingArtist = _currentInfoOverlay.item.artist;
            if ([nowPlayingTitle isEqualToString:operation.title] && [nowPlayingArtist isEqualToString:operation.artist])
                [self reloadDisplayableTextView];
        }
    }
}

#pragma mark Setup
/*
 * Function: Setup the singleton.
 *           Load the saved lyrics, if there's any. 
 * Note    : Return ASAP or it will take forever to start up.
 */
- (void)setup
{
    dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global_queue, ^{
        NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"FMLEnable",
                                                                            @"FMLLyricsWikiOperation", @"FMLOperation", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

        [self readFromLyricsStorageFile];

        _ready = YES;
    });
}

/*
 * Functions: Read/write from/to lyrics storage file.
 */
- (void)readFromLyricsStorageFile
{
    NSMutableArray *storedWrappers;
    @try
    {
        NSString *path = [[FMLLyricsStorageFolder stringByAppendingString:@"storage"] stringByExpandingTildeInPath];
        storedWrappers = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (id e)
    {
        DebugLog(@"DUN DUN DUN READ EXCEPTION: %@", e);
        storedWrappers = nil;
    }

    if (storedWrappers)
    {
        if (_lyricsWrappers)
            [_lyricsWrappers release];
        _lyricsWrappers = [(NSArray *)storedWrappers mutableCopy];
    }
}

- (void)writeToLyricsStorageFile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:[FMLLyricsStorageFolder stringByExpandingTildeInPath]])
        [manager createDirectoryAtPath:[FMLLyricsStorageFolder stringByExpandingTildeInPath]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];

    [NSKeyedArchiver archiveRootObject:_lyricsWrappers
                                toFile:[[FMLLyricsStorageFolder stringByAppendingString:@"storage"] stringByExpandingTildeInPath]];
}

#pragma mark Singleton
/*
 * These functions are necessary for a singleton.
 */
+ (id)sharedController
{
    static FMLController *singleton;

    @synchronized(self)
    {
        if (!singleton)
            singleton = [[super allocWithZone:NULL] init];

        return singleton;
    }
}

- (id)init
{
    if ((self = [super init]))
    {
        _lyricsFetchOperationQueue = [[NSOperationQueue alloc] init];
        [_lyricsFetchOperationQueue setName:@"com.uglycathasnodomain.FetchMyLyrics.LyricsFetchOperations"];
        _lyricsWrappers = [[NSMutableArray alloc] init];
        _ready = NO;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedController] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (void)release
{
}

- (id)autorelease
{
    return self;
}

/*
 * Note: This should never be called, because our class is a singleton that is never released.
 */
- (void)dealloc
{
    [_lyricsFetchOperationQueue release];
    [_lyricsWrappers release];
    [self ridCurrentInfoOverlay];
    
    [super dealloc];
}

@end
