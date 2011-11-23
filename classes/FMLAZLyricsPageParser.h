/*******************************************************************************
 * FMLAZLyricsPageParser.h
 * FetchMyLyrics
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMLAZLyricsPageParser : NSObject <UIWebViewDelegate> {
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
- (void)pollForPageLoadCompletion;

@end
