/*******************************************************************************
 * FMLLyricsWrapper.h
 * FetchMyLyrics
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface FMLLyricsWrapper : NSObject <NSCoding> {
    NSString *_title;
    NSString *_artist;
    NSString *_lyrics;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;

- (id)init;
+ (id)lyricsWrapper;

@end
