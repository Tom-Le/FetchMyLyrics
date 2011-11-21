/*******************************************************************************
 * LGRLyricsWikiAPIParser.h
 * L'Fetcher
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source.  
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface LGRLyricsWikiAPIParser : NSObject <NSXMLParserDelegate> {
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
