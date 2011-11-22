/*******************************************************************************
 * LGRAZLyricsOperation.xm
 * L'Fetcher
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 ******************************************************************************/

#import "LGRAZLyricsOperation.h"

#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import "LGRAZLyricsPageParser.h"
#import "LGRLyricsWrapper.h"
#import "LGRController.h"
#import "LGRCommon.h"

@implementation LGRAZLyricsOperation

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

        // Set up synchronous parser
        // (Read LGRLyricsWikiOperation.xm for an explanation on why I chose to make my parser synchronous)
        LGRAZLyricsPageParser *pageParser = [[[LGRAZLyricsPageParser alloc] init] autorelease];
        pageParser.URLToPage = URLToPage;
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
    // Notify LGRController singleton
    if (self.lyrics)
        [[LGRController sharedController] operationReportsAvailableLyrics:self];

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