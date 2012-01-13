/*******************************************************************************
 * NSRegularExpression+Extra.h
 *
 * Referenced from:
 *  http://stackoverflow.com/questions/4475796/
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface NSRegularExpression (Extra)

- (NSString *)stringByReplacingMatchesInString:(NSString *)string
                                       options:(NSMatchingOptions)options
                                         range:(NSRange)range
                                    usingBlock:(NSString * (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block;

@end
