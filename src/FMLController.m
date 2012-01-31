/*******************************************************************************
 * FMLController.m
 * FetchMyLyrics
 *
 * Warning: God object.
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <objc-runtime.h>

#import "FMLController.h"
#import "FMLCommon.h"
#import "NSObject+InstanceVariable.h"

#import "FMLLyricsWrapper.h"
#import "FMLOperation.h"
#import "FMLLyricsWikiOperation.h"
#import "FMLAZLyricsOperation.h"

NSString * const kFMLLyricsStorageFolder = @"~/Library/FetchMyLyrics/";
NSString * const kFMLLyricsOperationsFolder = @"/Library/FetchMyLyrics/LyricsOperations/";

@implementation FMLController

#pragma mark Now Playing

/*
 * Function: Fetch lyrics if none exists for the specified song title
 *           and artist.
 * Note    : This method has to return as quickly as possible or the 
 *           UI will lock up badly.
 */
- (void)handleSongWithNowPlayingItem:(id)item
{
    // Since this method has to return ASAP, the whole task will be shoved
    // to another operation queue.
    //
    // NOTE: We use 2 queues for 2 different tasks:
    //       - Tasks in the global dispatch queue (default priority) handle arriving IUMediaQueryNowPlayingItem's.
    //       - Tasks in _lyricsFetchOperationQueue handle fetching the lyrics from the sky/Internet.

    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"FMLEnabled"];
    if (_ready && enabled)
    {
        dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(global_queue, ^{
            // NOTE: Block inherits every ivar as well as local vars

            // If the song already has lyrics, return.
            BOOL hasDisplayableText = ((BOOL (*)(id, SEL, ...))objc_msgSend)(item, @selector(hasDisplayableText));
            if (hasDisplayableText)
                return;
     
            // Song info
            id mediaItem = objc_msgSend(item, @selector(mediaItem));
            NSString *title = (NSString *)objc_msgSend(mediaItem, @selector(valueForProperty:), @"title");
            NSString *artist = (NSString *)objc_msgSend(mediaItem, @selector(valueForProperty:), @"artist");

            // Some items have no artist and title (IDK why)
            if ((title == nil) || (artist == nil))
                return;

            // If FMLController already has lyrics for the song, return.
            @synchronized(_lyricsWrappers)
            {
                for (FMLLyricsWrapper *lw in _lyricsWrappers)
                    if ([lw.title isEqualToString:title] && [lw.artist isEqualToString:artist])
                        return;
            }

            // If a task is already running for the song requested, return.
            @synchronized(_lyricsFetchOperationQueue)
            {
                for (NSOperation<FMLOperation> *lo in [_lyricsFetchOperationQueue operations])
                    if ([lo.title isEqualToString:title] && [lo.artist isEqualToString:artist])
                        return;
            }

            // Start a new task to fetch the lyrics
            NSString *operationKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"FMLOperation"];
            NSString *operationBundlePath = [kFMLLyricsOperationsFolder stringByAppendingString:[operationKey stringByAppendingString:@".bundle"]];
            NSBundle *operationBundle = [NSBundle bundleWithPath:operationBundlePath];
            Class operationClass = [operationBundle principalClass];
            if (operationClass)
            {
                NSOperation<FMLOperation> *operation = (NSOperation<FMLOperation> *)[[[operationClass alloc] init] autorelease];
                operation.title = title;
                operation.artist = artist;
                [_lyricsFetchOperationQueue addOperation:operation];
            }
        });
    }
}

/*
 * Function: Reload displayable text (ie. lyrics) view if it's present.
 * Note    : Basicaly dig into the view hierachy to reach the instance of MPPortraitInfoOverlay
 *           which has a method that will reload the displayable text (ie. lyrics) view
 *           (This is at least more elegant than the last one I used, which is to hook into
 *           MPPortraitInfoOverlay and retain instances to it--who knows how many objects I was leaking)
 */
- (void)reloadDisplayableTextViewForSongTitle:(NSString *)title artist:(NSString *)artist
{
    id/*MediaApplication*/ appDelegate = [[UIApplication sharedApplication] delegate];
    UINavigationController/*IUiPodNavigationController*/ *navController = objc_msgSend(appDelegate, @selector(IUTopNavigationController));
    id visibleViewController = [navController visibleViewController];

    // visibleViewController is actually an instance of IUMixedPlaybackViewController from my initial testing
    // but IUMixedPlaybackViewController is a subclass of IUPlaybackViewController anyway
    if ([visibleViewController isKindOfClass:NSClassFromString(@"IUPlaybackViewController")])
    {
        id/*IUNowPlayingPortraitViewController*/ activeViewController = [visibleViewController objectInstanceVariable:@"_activeViewController"];
        id/*IUNowPlayingAlbumFrontViewController*/ mainController = [activeViewController objectInstanceVariable:@"_mainController"];
        id/*IUNowPlayingPortraitInfoOverlay*/ overlayView = [mainController objectInstanceVariable:@"_overlayView"];
        if (overlayView)
        {
            id/*IUMediaQueryNowPlayingItem*/ item = [overlayView objectInstanceVariable:@"_item"];
            if (item)
            {
                if ((title == nil) || (artist == nil))
                {
                    objc_msgSend(overlayView, @selector(_updateDisplayableTextViewForItem:animate:), item, YES);
                }
                else
                {
                    id/*MPMediaItem*/ mediaItem = [item objectInstanceVariable:@"_mediaItem"];
                    NSString *nowPlayingTitle = (NSString *)objc_msgSend(mediaItem, @selector(valueForProperty:), @"title");
                    NSString *nowPlayingArtist = (NSString *)objc_msgSend(mediaItem, @selector(valueForProperty:), @"artist");
                    if ((nowPlayingTitle != nil) && (nowPlayingArtist != nil) && [nowPlayingTitle isEqualToString:title] && [nowPlayingArtist isEqualToString:artist])
                    {
                        objc_msgSend(overlayView, @selector(_updateDisplayableTextViewForItem:animate:), item, YES);
                    }
                }
            }
        }
    }
}

#pragma mark Lyrics
/*
 * Function: Return lyrics for a song with specified title and artist.
 */
- (NSString *)lyricsForSongWithTitle:(NSString *)title artist:(NSString *)artist
{
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"FMLEnabled"];
    if (_ready && enabled)
    {
        @synchronized(_lyricsWrappers)
        {
            for (FMLLyricsWrapper *lw in _lyricsWrappers)
                if ([lw.title isEqualToString:title] && [lw.artist isEqualToString:artist]) 
                {
                    return lw.lyrics; 
                }
        }
    }

    // Found nothing or wasn't ready
    return nil;
}

/*
 * Function: Update our storage with new lyrics.
 */
- (void)operationDidReturnWithLyrics:(NSNotification *)notification
{
    if (_ready && [[notification name] isEqualToString:@"FMLOperationDidReturnWithLyrics"])
    {
        NSString *title = [[notification userInfo] objectForKey:@"title"];
        NSString *artist = [[notification userInfo] objectForKey:@"artist"];
        NSString *lyrics = [[notification userInfo] objectForKey:@"lyrics"];

        DebugLog(@"Operation for %@ by %@ returned with lyrics.", title, artist);

        BOOL duplicate = NO;
        NSUInteger duplicateIndex;
        for (FMLLyricsWrapper *lw in _lyricsWrappers)
            if ([lw.title isEqualToString:title] && [lw.artist isEqualToString:artist]) 
            {
                duplicateIndex = [_lyricsWrappers indexOfObject:lw];
                duplicate = YES;
                break;
            }

        FMLLyricsWrapper *wrapper = [FMLLyricsWrapper lyricsWrapper];
        wrapper.title = title;
        wrapper.artist = artist;
        wrapper.lyrics = lyrics;

        if (!duplicate)
            [_lyricsWrappers addObject:wrapper];
        else
            [_lyricsWrappers replaceObjectAtIndex:duplicateIndex withObject:wrapper];

        [self writeToLyricsStorageFile];

        // Request the app update its lyrics display, but only if now playing song is the song whose lyrics was just fetched
        // and only if the tweak is enabled
        BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"FMLEnabled"];
        if (enabled)
        {
            [self reloadDisplayableTextViewForSongTitle:title artist:artist];
        }
    }
}

/*
 * Functions: Read/write from/to lyrics storage file.
 */
- (void)readFromLyricsStorageFile
{
    NSMutableArray *storedWrappers;
    @try
    {
        NSString *path = [[kFMLLyricsStorageFolder stringByAppendingString:@"storage"] stringByExpandingTildeInPath];
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
    if (![manager fileExistsAtPath:[kFMLLyricsStorageFolder stringByExpandingTildeInPath]])
        [manager createDirectoryAtPath:[kFMLLyricsStorageFolder stringByExpandingTildeInPath]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];

    [NSKeyedArchiver archiveRootObject:_lyricsWrappers
                                toFile:[[kFMLLyricsStorageFolder stringByAppendingString:@"storage"] stringByExpandingTildeInPath]];
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
        NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"FMLEnabled",
                                                                            @"FMLLyricsWikiOperation", @"FMLOperation", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

        [self readFromLyricsStorageFile];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(operationDidReturnWithLyrics:)
                                                     name:@"FMLOperationDidReturnWithLyrics"
                                                   object:nil];

        _ready = YES;
    });
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
        [_lyricsFetchOperationQueue setName:@"no.domain.FetchMyLyrics.LyricsFetchOperations"];

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

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
