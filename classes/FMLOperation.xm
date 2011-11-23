/*******************************************************************************
 * FMLOperation.xm
 * FetchMyLyrics
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
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

