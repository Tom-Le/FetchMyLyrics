/*******************************************************************************
 * FMLLyricsWikiAPIParser.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
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
