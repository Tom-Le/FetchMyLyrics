/*******************************************************************************
 * LGRLyricsWrapper.h
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source.
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface LGRLyricsWrapper : NSObject <NSCoding> {
    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;

- (id)init;
+ (id)lyricsWrapper;

@end
