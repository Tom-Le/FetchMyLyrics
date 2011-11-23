/*******************************************************************************
 * FMLAZLyricsPageParser.xm
 * FetchMyLyrics
 *
 * NOTE: This class is HIGHLY error prone.
 ******************************************************************************/

#import "FMLAZLyricsPageParser.h"
#import "FMLCommon.h"

@implementation FMLAZLyricsPageParser

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
        NSString *pageHTML = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _dummyWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            _scraperWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [_dummyWindow addSubview:_scraperWebView];
            _scraperWebView.delegate = self;
            [_scraperWebView loadHTMLString:pageHTML
                                    baseURL:self.URLToPage];
        }];

        _done = NO;
    }
    else
        _done = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // This method is actually called several times before the page actually loads.
    // I don't know why either.
    // We'll have to detect page load completion the JavaScript way.
    [webView stringByEvaluatingJavaScriptFromString:@"if (/loaded|complete/.test(document.readyState)){document.UIWebViewDocumentIsReady = true;}else{document.addEventListener('DOMContentLoaded', function(){document.UIWebViewDocumentIsReady = true;}, false);}"];

    [self performSelector:@selector(pollForPageLoadCompletion)
               withObject:nil
               afterDelay:1];
}

- (void)pollForPageLoadCompletion
{
    // - (void)pollForPageLoadCompletion is a tip found from this blog post:
    // http://benedictcohen.co.uk/blog/archives/74

    if ([@"true" isEqualToString:[_scraperWebView stringByEvaluatingJavaScriptFromString:@"document.UIWebViewDocumentIsReady"]])
    {
        // We are extracting the lyrics through Javascript (see FMLLyricsWikiPageParser.xm for more detail)
        // Note: This class will break if AZLyrics changes its layout.

        // Check if the lyrics page exist.
        // The lyrics page always has a div.ArtistTitle; check its existence.
        NSString *fourOhFour = [_scraperWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('ArtistTitle').length"];
        if (![fourOhFour isEqualToString:@"1"])
        {
            _done = YES;
            return;
        }

        // The lyrics reside inside a <div style='margin-left:10px;margin-right:10px;'>
        // This is _extremely error prone; they only need to change the margin to break the whole script.
        NSString *lyrics = [_scraperWebView stringByEvaluatingJavaScriptFromString:@"for (i = 0; i < document.getElementsByTagName('div').length; i++){var str = document.getElementsByTagName('div')[i].getAttribute('style');if (str){if (str.search('margin-left:[0-9]+px;margin-right:[0-9]+px;') !== -1){document.getElementsByTagName('div')[i].innerText}}}"];
        if (lyrics)
            _lyrics = [lyrics copy];
        else
            _lyrics = [@"" copy];
            // See FMLLyricsWikiPageParser.xm on what's the meaning of the empty string @""

        _done = YES;
    }
    else
        [self performSelector:@selector(pollForPageLoadCompletion)
                   withObject:nil
                   afterDelay:1];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _lyrics = nil;
    _done = YES;
}

@end
