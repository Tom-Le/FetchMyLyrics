/*******************************************************************************
 * FMLLyricsWikiAPIParser.h
 * FetchMyLyrics
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
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
