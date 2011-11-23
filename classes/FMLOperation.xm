/*******************************************************************************
 * FMLOperation.xm
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLOperation.h"

#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import "FMLCommon.h"

@implementation FMLOperation

@synthesize title = _title, artist = _artist, lyrics = _lyrics, nowPlayingItem = _nowPlayingItem;

/*
 * Initialization
 */
- (id)init
{
    if ((self = [super init]))
    {
        _title = nil;
        _artist = nil;
        _lyrics = nil;

        _abs_finished = NO;
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

/*
 * Function: Abstract start. It doesn't even start anything.
 *           Automatically mark the task finished.
 */
- (void)start
{
    [self willChangeValueForKey:@"isFinished"];
    _abs_finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

/*
 * Necessary subclassing methods.
 */
- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return NO; // This is an abstract subclass
}

- (BOOL)isFinished
{
    return _abs_finished;
}

- (void)dealloc
{
    self.title = nil;
    self.artist = nil;
    self.lyrics = nil;
    self.nowPlayingItem = nil;

    [super dealloc];
}

@end

