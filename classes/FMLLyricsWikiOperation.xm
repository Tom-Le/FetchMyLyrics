/*******************************************************************************
 * FMLLyricsWikiOperation.xm
 * FetchMyLyrics
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 ******************************************************************************/

#import "FMLLyricsWikiOperation.h"

#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import "FMLLyricsWrapper.h"
#import "FMLLyricsWikiAPIParser.h"
#import "FMLLyricsWikiPageParser.h"
#import "FMLController.h"
#import "FMLCommon.h"

@implementation FMLLyricsWikiOperation

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
 *           This method spawns a new thread to run the task.
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
        // FIRST STEP: Ask LyricsWiki API for song data.

        // Note: periodically check [self.nowPlayingItem hasDisplayableText]
        // if at any time this returns yes, abort operation.
        if ([self isCancelled] || [self.nowPlayingItem hasDisplayableText])
            return;

        // Form URL for request
        NSString *APIRequestURLStringUnescaped = [NSString stringWithFormat:@"http://lyrics.wikia.com/api.php?fmt=xml&song=%@&artist=%@", self.title, self.artist];
        NSString *APIRequestURLString = [APIRequestURLStringUnescaped stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *APIRequestURL = [NSURL URLWithString:APIRequestURLString];

        // SECOND STEP: Parse for URL to page with lyrics.
        //              LyricsWiki no longer returns the full lyrics because of the fucking entertainment industry
        //              that is looking forward to pass SOPA to further destroy the Internet. Fuck you, industry.
        //              See how you're clamping innovation? This tweak could have been _way easier_ had it not been
        //              for your filthy hands. </endrant> (((sorry to whoever reading my code)))

        // Periodic check
        if ([self isCancelled] || [self.nowPlayingItem hasDisplayableText])
            return;
        
        // Set up synchronous parser.
        // I chose this model (instead of an asynchronous parser that can for eg. notify this instance
        // when it's done) because it would keep our task wrapped in - (void)main which is IMO
        // 10000x cleaner. Of course, if performance issues arise, I'll rethink my choices.
        FMLLyricsWikiAPIParser *APIParser = [[[FMLLyricsWikiAPIParser alloc] init] autorelease];
        APIParser.URLToAPIPage = APIRequestURL;
        [APIParser beginParsing];
        
        // Busy waiting (won't lock up the UI, we're on a separate thread, so don't look so scared)
        while (!APIParser.done)
        {
            if ([self isCancelled] || [self.nowPlayingItem hasDisplayableText])
                return;
            [NSThread sleepForTimeInterval:0.2];
        }
        
        // Grab the URL
        NSString *URLStringToLyricsPage = [[APIParser.URLStringToLyricsPage copy] autorelease];

        // If the URL doesn't exist, return.
        if (!URLStringToLyricsPage)
            return;

        // THIRD STEP: Visit lyrics page and parse for the lyrics (in plain text)

        // Periodic check
        if ([self isCancelled] || [self.nowPlayingItem hasDisplayableText])
            return;

        // Set up synchronous parser.
        FMLLyricsWikiPageParser *pageParser = [[[FMLLyricsWikiPageParser alloc] init] autorelease];
        pageParser.URLToPage = [NSURL URLWithString:URLStringToLyricsPage];
        [pageParser beginParsing];

        // Busy waiting
        while (!pageParser.done)
        {
            if ([self isCancelled] || [self.nowPlayingItem hasDisplayableText])
                return;
            [NSThread sleepForTimeInterval:0.2];
        }

        // Grab the lyrics (woooooo)
        if (pageParser.lyrics)
            self.lyrics = pageParser.lyrics;
    }
    @catch (id e)
    {
        DebugLog(@"DUN DUN EXCEPTION: %@", e);
    }
    @finally
    {
        // Will be executed even if the code block in @try {} returns before completing
        [self completeOperation];
    }
}

/*
 * Function: Wrap up the task.
 *           Notify FMLController singleton if we fetched some lyrics.
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
