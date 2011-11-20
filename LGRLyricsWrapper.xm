/*******************************************************************************
 * LGRLyricsWrapper.xm
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, available here: http://bit.ly/vSZSvM
 ******************************************************************************/

#import "LGRLyricsWrapper.h"

@implementation LGRLyricsWrapper

@synthesize title = _title, artist = _artist, lyrics = _lyrics;

- (id)init
{
    if ((self = [super init]))
    {
        _title = nil;
        _artist = nil;
        _lyrics = nil;
    }

    return self;
}

+ (id)lyricsWrapper
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    self.title = nil;
    self.artist = nil;
    self.lyrics = nil;

    [super dealloc];
}

@end
