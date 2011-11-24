/*******************************************************************************
 * FMLAZLyricsPageParser.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMLAZLyricsPageParser : NSObject <UIWebViewDelegate> {
    NSURL *_URLToPage;
    NSAutoreleasePool *_pool;
}

@property (nonatomic, copy) NSURL *URLToPage;

- (NSString *)lyricsFromParsing;

@end
