/*******************************************************************************
 * FMLController.h
 * FetchMyLyrics
 ******************************************************************************/

#import <Foundation/Foundation.h>

@class IUMediaQueryNowPlayingItem, MPMediaItem, MPPortraitInfoOverlay;
@class FMLLyricsWrapper, FMLOperation, FMLLyricsWikiOperation, FMLAZLyricsOperation, FMLAZLyricsOperation;

@interface FMLController : NSObject {
    NSOperationQueue *_lyricsFetchOperationQueue;
    NSMutableArray *_lyricsWrappers;

    MPPortraitInfoOverlay *_currentInfoOverlay;

    BOOL _ready;
}

- (void)handleSongWithNowPlayingItem:(IUMediaQueryNowPlayingItem *)item;
- (NSString *)lyricsForSongWithTitle:(NSString *)title
                              artist:(NSString *)artist;
- (void)operationReportsAvailableLyrics:(FMLOperation *)operation;

- (void)readFromLyricsStorageFile;
- (void)writeToLyricsStorageFile;

- (void)setCurrentInfoOverlay:(MPPortraitInfoOverlay *)overlay;
- (void)ridCurrentInfoOverlay;

+ (id)sharedController;
- (void)setup;
@end
