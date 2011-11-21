/*******************************************************************************
 * LGRLyricsWikiPageParser.h
 * iPodLyrics
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source.
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LGRLyricsWikiPageParser : NSObject <UIWebViewDelegate> {
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

