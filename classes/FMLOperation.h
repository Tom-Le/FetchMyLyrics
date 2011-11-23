/*******************************************************************************
 * FMLOperation.h
 * FetchMyLyrics
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class IUMediaQueryNowPlayingItem;

@interface FMLOperation : NSOperation {
    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;

    IUMediaQueryNowPlayingItem *_nowPlayingItem;

    BOOL _abs_finished;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, retain) IUMediaQueryNowPlayingItem *nowPlayingItem; 

- (id)init;
+ (id)operation;

@end

