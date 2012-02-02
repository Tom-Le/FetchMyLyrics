/*******************************************************************************
 * NSRegularExpression+Extra.m
 *
 * Referenced from:
 *  http://stackoverflow.com/questions/4475796/
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "NSRegularExpression+Extra.h"

@implementation NSRegularExpression (Extra)

- (NSString *)stringByReplacingMatchesInString:(NSString *)string
                                       options:(NSMatchingOptions)options
                                         range:(NSRange)range
                                    usingBlock:(NSString * (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block
{
    NSMutableString *result = [NSMutableString string];
    __block NSUInteger position = 0;
    
    [self enumerateMatchesInString:string
                           options:0
                             range:range
                        usingBlock:
        ^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
        {
            if (match.range.location > position)
            {
                // Append the part before matched string
                [result appendString:[string substringWithRange:NSMakeRange(position, match.range.location - position)]];
            }

            position = match.range.location + match.range.length;
            
            [result appendString:block(match, flags, stop)];
        }];

    if (string.length > position)
    {
        [result appendString:[string substringFromIndex:position]];
    }

    return [NSString stringWithString:result];
}

@end
