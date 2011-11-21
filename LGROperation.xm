/*******************************************************************************
 * LGROperation.xm
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, available here: http://bit.ly/vSZSvM
 ******************************************************************************/

#import "LGROperation.h"

#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import "LGRCommon.h"

@implementation LGROperation

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

    [super dealloc];
}

@end
