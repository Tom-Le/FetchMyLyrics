/*******************************************************************************
 * LGRController.xm
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source.
 ******************************************************************************/

#import "LGRController.h"
#import "LGRCommon.h"

#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPPortraitInfoOverlay.h>
#import <MediaPlayer/MPAVItem.h>
#import "LGRLyricsWrapper.h"
#import "LGROperation.h"
#import "LGRLyricsWikiOperation.h"

#define LGRLyricsStorageFilePath @"~/Library/LyricsGrabber/storage"

@implementation LGRController

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

    if (_ready)
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

            // If LGRController already has lyrics for the song, return.
            for (LGRLyricsWrapper *lw in _lyricsWrappers)
                if ([lw.title isEqualToString:title] && [lw.artist isEqualToString:artist])
                    return;

            // If a task is already running for the song requested, return.
            for (LGRLyricsWikiOperation *lo in [_lyricsFetchOperationQueue operations])
                if ([lo.title isEqualToString:title] && [lo.artist isEqualToString:artist])
                    return;

            // Start a new task to fetch the lyrics
            LGRLyricsWikiOperation *operation = [LGRLyricsWikiOperation operation];
            operation.title = title;
            operation.artist = artist;
            operation.nowPlayingItem = item;
            [_lyricsFetchOperationQueue addOperation:operation];
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

#pragma mark Lyrics
/*
 * Function: Return lyrics for a song with specified title and artist.
 */
- (NSString *)lyricsForSongWithTitle:(NSString *)title artist:(NSString *)artist
{
    if (_ready)
    {
        for (LGRLyricsWrapper *lw in _lyricsWrappers)
            if ([lw.title isEqualToString:title] && [lw.artist isEqualToString:artist]) 
                return lw.lyrics;
    }

    // Found nothing or wasn't ready
    return nil;
}

/*
 * Function: Update our storage with new lyrics.
 */
- (void)operationReportsAvailableLyrics:(LGROperation *)operation
{
    if (_ready)
    {
        // Prevent duplicates
        BOOL duplicate = NO;
        for (LGRLyricsWrapper *lw in _lyricsWrappers)
            if ([lw.title isEqualToString:operation.title] && [lw.artist isEqualToString:operation.artist]) 
            {
                lw.lyrics = operation.lyrics;
                duplicate = YES;
            }

        if (!duplicate)
        {
            // No duplicate found, add.
            LGRLyricsWrapper *wrapper = [LGRLyricsWrapper lyricsWrapper];
            wrapper.title = operation.title;
            wrapper.artist = operation.artist;
            wrapper.lyrics = operation.lyrics;
            [_lyricsWrappers addObject:wrapper];

            [self writeToLyricsStorageFile];
        }

        // Request the app update its lyrics display, but only if now playing song is the song whose lyrics was just fetched
        NSString *nowPlayingTitle = _currentInfoOverlay.item.mainTitle; 
        NSString *nowPlayingArtist = _currentInfoOverlay.item.artist;
        if ([nowPlayingTitle isEqualToString:operation.title] && [nowPlayingArtist isEqualToString:operation.artist])
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_currentInfoOverlay _updateDisplayableTextViewForItem:operation.nowPlayingItem
                                                               animate:YES];
            }];
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
        storedWrappers = [NSKeyedUnarchiver unarchiveObjectWithFile:[LGRLyricsStorageFilePath stringByExpandingTildeInPath]];
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
        _lyricsWrappers = [storedWrappers retain];
    }
}

- (void)writeToLyricsStorageFile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:[@"~/Library/LyricsGrabber" stringByExpandingTildeInPath]])
        [manager createDirectoryAtPath:[@"~/Library/LyricsGrabber" stringByExpandingTildeInPath]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];

    [NSKeyedArchiver archiveRootObject:_lyricsWrappers
                                toFile:[LGRLyricsStorageFilePath stringByExpandingTildeInPath]];
}

#pragma mark Singleton
/*
 * These functions are necessary for a singleton.
 */
+ (id)sharedController
{
    static LGRController *singleton;

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
