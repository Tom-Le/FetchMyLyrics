/*******************************************************************************
 * FMLAZLyricsPageParser.m
 * FetchMyLyrics
 *
 * NOTE: This class is HIGHLY error prone.
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLAZLyricsPageParser.h"
#import "FMLCommon.h"

@implementation FMLAZLyricsPageParser

@synthesize URLToPage = _URLToPage;

- (id)init
{
    if ((self = [super init]))
    {
        _URLToPage = nil;
    }

    return self;
}

- (void)dealloc
{
    self.URLToPage = nil;

    [super dealloc];
}

- (NSString *)lyricsFromParsing
{
    if (!self.URLToPage)
        return nil;

    NSData *data = [NSData dataWithContentsOfURL:self.URLToPage];
    if (data)
    {
        NSString *pageHTML = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];

        NSRegularExpression *regexHTML = [NSRegularExpression regularExpressionWithPattern:@"(?:<!-- start of lyrics -->)([\\s\\S]*)(?:<!-- end of lyrics -->)"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
        __block NSString *lyricsUntidied = nil;
        [regexHTML enumerateMatchesInString:pageHTML
                                    options:0
                                      range:NSMakeRange(0, [pageHTML length])
                                 usingBlock: ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                     NSRange matchRange = [result rangeAtIndex:1];
                                     lyricsUntidied = [pageHTML substringWithRange:matchRange];
                                 }];
        if (lyricsUntidied)
        {
            NSRegularExpression *regexTidy = [NSRegularExpression regularExpressionWithPattern:@"(^\\s*)|(<.*>)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
            NSString *lyrics = [regexTidy stringByReplacingMatchesInString:lyricsUntidied
                                                                   options:0
                                                                     range:NSMakeRange(0, [lyricsUntidied length])
                                                              withTemplate:@""];
            return lyrics;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

@end
