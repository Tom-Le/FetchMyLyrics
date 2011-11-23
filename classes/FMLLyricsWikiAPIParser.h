/*******************************************************************************
 * FMLLyricsWikiAPIParser.h
 * FetchMyLyrics
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface FMLLyricsWikiAPIParser : NSObject <NSXMLParserDelegate> {
    NSURL *_URLToAPIPage;
    NSXMLParser *_parser;

    BOOL _done;

    BOOL _foundURLToLyricsPageElement;
    NSString *_URLStringToLyricsPage;

    NSMutableString *_mutableURLStringToLyricsPage;
}

@property (nonatomic, copy) NSURL *URLToAPIPage;
@property (nonatomic, readonly, getter=isDone) BOOL done;
@property (nonatomic, readonly) NSString *URLStringToLyricsPage;

- (void)beginParsing;

@end
