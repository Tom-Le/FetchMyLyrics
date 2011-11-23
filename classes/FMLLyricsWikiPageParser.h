/*******************************************************************************
 * FMLLyricsWikiPageParser.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMLLyricsWikiPageParser : NSObject <UIWebViewDelegate> {
    NSURL *_URLToPage;
    BOOL _done;
    UIWebView *_scraperWebView;
    UIWindow *_dummyWindow;
    NSString *_lyrics;
}

@property (nonatomic, copy) NSURL *URLToPage;
@property (nonatomic, readonly, getter=isDone) BOOL done;
@property (nonatomic, readonly) NSString *lyrics;

- (void)beginParsing;

@end
