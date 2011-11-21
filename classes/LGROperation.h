/*******************************************************************************
 * LGROperation.h
 * L'Fetcher
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class IUMediaQueryNowPlayingItem;

@interface LGROperation : NSOperation {
    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;

    IUMediaQueryNowPlayingItem *_nowPlayingItem;

    BOOL _abs_finished;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, retain) IUMediaQueryNowPlayingItem *nowPlayingItem; 

- (id)init;
+ (id)operation;

@end

