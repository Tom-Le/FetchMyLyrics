/*******************************************************************************
 * FMLLyricsWikiPageParser.m
 * FetchMyLyrics
 *
 * NOTE: This class is HIGHLY error prone.
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLLyricsWikiPageParser.h"
#import "FMLCommon.h"

@implementation FMLLyricsWikiPageParser

@synthesize URLToPage = _URLToPage, lyrics = _lyrics, done = _done;

- (id)init
{
    if ((self = [super init]))
    {
        _URLToPage = nil;
        _scraperWebView = nil;
        _dummyWindow = nil;
        _done = YES;
        _lyrics = nil;
    }

    return self;
}

- (void)dealloc
{
    if (_scraperWebView)
    {
        _scraperWebView.delegate = nil;
        [_scraperWebView removeFromSuperview];
        [_scraperWebView release];
    }
    if (_dummyWindow)
        [_dummyWindow release];
    if (_lyrics)
        [_lyrics release];

    self.URLToPage = nil;

    [super dealloc];
}

- (void)beginParsing
{
    if (!self.URLToPage)
        return;

    NSData *data = [NSData dataWithContentsOfURL:self.URLToPage];
    if (data)
    {
        // This method combines the UIWebView with some regex to reduce load time
        // I would _love_ to eliminate the UIWebView completely, but, alas, those
        // HTML entities make my head spin.

        NSString *pageHTML = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];

        NSRegularExpression *regexHTML = [NSRegularExpression regularExpressionWithPattern:@"<div class='lyricbox'><div class='rtMatcher'>.*</div>(.*)<!--"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        __block NSString *lyricsHTMLEncoded = nil;
        [regexHTML enumerateMatchesInString:pageHTML
                                    options:0
                                      range:NSMakeRange(0, [pageHTML length])
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                     NSRange matchRange = [result rangeAtIndex:1];
                                     lyricsHTMLEncoded = [pageHTML substringWithRange:matchRange];
                                 }];

        if (lyricsHTMLEncoded)
        {
            // UIWebView is _not_ thread-safe. Therefore we have to deal with it in the main thread
            // (which sucks because it will block the UI momentarily but whatever)
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // init the web view
                _dummyWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                _scraperWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                _scraperWebView.delegate = self;
                [_dummyWindow addSubview:_scraperWebView];

                // construct bare bone web page
                NSString *lyricsPage = [NSString stringWithFormat:@"<html><head></head><body>%@</body></html>", lyricsHTMLEncoded];

                // load page
                [_scraperWebView loadHTMLString:lyricsPage
                                        baseURL:nil];

            }];

            _done = NO;
        }
        else
        {
            _done = YES;
        }
    }
    else
    {
        _done = YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // When the web view has finished loading, ugly HTML entities should have been
    // transformed to normal characters; retrieve them here through JavaScript

    NSString *lyrics = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].innerText"];
    if (lyrics)
    {
        if ([lyrics rangeOfString:@"Unfortunately, we are not licensed to display the full lyrics for this song at the moment"].location != NSNotFound)
            _lyrics = nil;
        else
            _lyrics = [lyrics copy];
    }

    _done = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _lyrics = nil;
    _done = YES;
}

@end
