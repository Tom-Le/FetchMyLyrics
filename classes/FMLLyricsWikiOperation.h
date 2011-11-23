/*******************************************************************************
 * FMLLyricsWikiOperation.h
 * FetchMyLyrics
 ******************************************************************************/

#import <Foundation/Foundation.h>

#import "FMLOperation.h"

@class FMLController, FMLLyricsWrapper, FMLLyricsWikiAPIParser, FMLLyricsWikiPageParser, IUMediaQueryNowPlayingItem;

@interface FMLLyricsWikiOperation : FMLOperation { 
    NSAutoreleasePool *_pool;

    BOOL _executing;
    BOOL _finished;
}

- (void)completeOperation;

@end
