/*******************************************************************************
 * LGRLyricsWrapper.h
 * LyricsGrabber
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, available here: http://bit.ly/vSZSvM
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
