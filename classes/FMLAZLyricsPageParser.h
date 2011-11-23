/*******************************************************************************
 * FMLAZLyricsPageParser.h
 * FetchMyLyrics
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
