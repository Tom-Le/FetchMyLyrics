/*******************************************************************************
 * FMLAZLyricsOperation.h
 * FetchMyLyrics
 ******************************************************************************/

#import <Foundation/Foundation.h>

#import "FMLOperation.h"

@class FMLController, FMLLyricsWrapper, IUMediaQueryNowPlayingItem;

@interface FMLAZLyricsOperation : FMLOperation {
    NSAutoreleasePool *_pool;

    BOOL _executing;
    BOOL _finished;
}

- (id)init;
+ (id)operation;

- (void)completeOperation;

@end
