/*******************************************************************************
 * NSRegularExpression+Extra.h
 *
 * Referenced from:
 *  http://stackoverflow.com/questions/4475796/
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface NSRegularExpression (Extra)

- (NSString *)stringByReplacingMatchesInString:(NSString *)string
                                       options:(NSMatchingOptions)options
                                         range:(NSRange)range
                                    usingBlock:(NSString * (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block;

@end
