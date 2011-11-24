/*******************************************************************************
 * FMLAZLyricsOperation.m
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLAZLyricsOperation.h"

#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import "FMLAZLyricsPageParser.h"
#import "FMLLyricsWrapper.h"
#import "FMLController.h"
#import "FMLCommon.h"

@implementation FMLAZLyricsOperation

#pragma mark Initialization
/*
 * Function: Initialization.
 * Note    : No one calls -init nowadays.
 */
- (id)init
{
    if ((self = [super init]))
    {
        _title = nil;
        _artist = nil;
        _lyrics = nil;
        _nowPlayingItem = nil;

        _pool = nil;
        
        _executing = NO;
        _finished = NO;
    }

    return self;
}

/*
 * Function: Convenience constructor.
 */
+ (id)operation
{
    return [[[self alloc] init] autorelease];
}

#pragma mark Task
/*
 * Function: Start operation.
 *           Spawns new thread.
 */
- (void)start
{
    // If operation is cancelled, return
    if ([self.nowPlayingItem hasDisplayableText] || [self isCancelled])
    {
        // Mark operation as finished
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];

        return;
    }

    // Begin execution
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main)
                             toTarget:self
                           withObject:nil];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

/*
 * Function: Fetch the lyrics.
 */
- (void)main
{
    _pool = [[NSAutoreleasePool alloc] init];
    
    @try
    {
        // FIRST STEP: URL.

        // Periodic check.
        if ([self isCancelled] || [self.nowPlayingItem hasDisplayableText])
            return;

        NSError *error = NULL;
        NSRegularExpression *regexForURL = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9]*"
                                                                                     options:NSRegularExpressionCaseInsensitive
                                                                                       error:&error];
        if (error)
            return;

        NSString *titleForURL = [regexForURL stringByReplacingMatchesInString:[self.title lowercaseString]
                                                                      options:0
                                                                        range:NSMakeRange(0, [self.title length])
                                                                 withTemplate:@""];
        NSString *artistForURL = [regexForURL stringByReplacingMatchesInString:[self.artist lowercaseString]
                                                                       options:0
                                                                         range:NSMakeRange(0, [self.artist length])
                                                                  withTemplate:@""];
        NSString *URLStringToPage = [@"http://www.azlyrics.com/lyrics/" stringByAppendingFormat:@"%@/%@.html", artistForURL, titleForURL];
        NSURL *URLToPage = [NSURL URLWithString:URLStringToPage];

        // Periodic check.
        if ([self isCancelled] || [self.nowPlayingItem hasDisplayableText])
            return;

        // SECOND STEP: Fetch lyrics

        // Set up parser
        FMLAZLyricsPageParser *pageParser = [[[FMLAZLyricsPageParser alloc] init] autorelease];
        pageParser.URLToPage = URLToPage;
        // Fetch lyrics (woooooo)
        NSString *lyrics = [pageParser lyricsFromParsing];
        if (lyrics)
            self.lyrics = [lyrics copy];
    }
    @catch (id e)
    {
        DebugLog(@"DUN DUN DUN EXCEPTION: %@", e);
    }
    @finally
    {
        [self completeOperation];
    }
}

/*
 * Function: Wrap up the task.
 */
- (void)completeOperation
{
    // Notify FMLController singleton
    if (self.lyrics)
        [[FMLController sharedController] operationReportsAvailableLyrics:self];

    // Mark task as finished
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    _finished = YES;
    _executing = NO;

    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];

    // Release autorelease pool if it exists
    if (_pool)
    {
        [_pool release];
        _pool = nil;
    }
}

/*
 * These methods are necessary to mark our task as concurrent.
 */
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

#pragma mark Deallocation
- (void)dealloc
{
    self.title = nil;
    self.artist = nil;
    self.lyrics = nil;
    self.nowPlayingItem = nil;

    [super dealloc];
}

@end
