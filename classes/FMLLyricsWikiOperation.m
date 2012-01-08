/*******************************************************************************
 * FMLLyricsWikiOperation.m
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLLyricsWikiOperation.h"

#import "FMLLyricsWrapper.h"
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
    if ([self isCancelled])
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
    DebugLog(@"Starting operation: %@ by %@", self.title, self.artist);

    _pool = [[NSAutoreleasePool alloc] init];

    @try
    {
        // FIRST STEP: Ask LyricsWiki API for song data.

        // Periodical check
        if ([self isCancelled])
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
        if ([self isCancelled])
            return;

        // Download XML file
        NSData *APIData = [NSData dataWithContentsOfURL:APIRequestURL];
        NSString *APIString = [[[NSString alloc] initWithData:APIData
                                                     encoding:NSUTF8StringEncoding] autorelease];
        // Set up regex for parsing
        NSRegularExpression *regexAPI = [NSRegularExpression regularExpressionWithPattern:@"<url>(.*)</url>"
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
        __block NSString *URLStringToLyricsPage = nil;
        // Parse
        [regexAPI enumerateMatchesInString:APIString
                                   options:0
                                     range:NSMakeRange(0, [APIString length])
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                    // Index 0 = range for all matched string including <url> and </url> => not what we want
                                    NSRange matchRange = [result rangeAtIndex:1];
                                    URLStringToLyricsPage = [APIString substringWithRange:matchRange];
                                }];
        
        // If the URL doesn't exist, return.
        if (!URLStringToLyricsPage)
            return;

        // THIRD STEP: Visit lyrics page and parse for the lyrics (in plain text)

        // Periodic check
        if ([self isCancelled])
            return;

        // Set up synchronous parser.
        // I chose this model (instead of an asynchronous parser that can for eg. notify this instance
        // when it's done) because it would keep our task wrapped in - (void)main which is IMO
        // 10000x cleaner. Of course, if performance issues arise, I'll rethink my choices.
        FMLLyricsWikiPageParser *pageParser = [[[FMLLyricsWikiPageParser alloc] init] autorelease];
        pageParser.URLToPage = [NSURL URLWithString:URLStringToLyricsPage];
        [pageParser beginParsing];

        // Busy waiting
        while (!pageParser.done)
        {
            if ([self isCancelled])
                return;
            [NSThread sleepForTimeInterval:0.1];
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

    DebugLog(@"Ending operation: %@ by %@", self.title, self.artist);
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

    [super dealloc];
}

@end
