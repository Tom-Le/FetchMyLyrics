// THIS FILE IS OBSOLETE EVERYTHING INSIDE IS A FAILURE sobs

#import <iPodUI/IUNowPlayingAlbumFrontViewController.h>
#import <iPodUI/IUMediaQueryNowPlayingItem.h>
#import <MediaPlayer/MPMediaItem.h>

#import <objc-runtime.h>

#define DEBUG_ENABLE 1

%hook MPConcreteMediaItem

/*
 * Hook   : - [MPConcreteMediaItem valueForProperty:]
 * Goal   : Return the lyrics that our tweak fetches, provided that the song has no lyrics.
 * Caveats: There is no concrete way to detect if a song has no lyrics. :-(
 *          Currently we have to rely on constantly probing for song's lyrics while fetching
 *          our version from the Internet, and aborting when appropriate.
 */

- (id)valueForProperty:(id)property
{
    if ([property respondsToSelector:@selector(isEqualToString:)])
        if ([property isEqualToString:@"lyrics"])
        {
            NSString *title = objc_msgSend(self, @selector(valueForProperty:), @"title"); 
            NSString *artist = objc_msgSend(self, @selector(valueForProperty:), @"artist"); 
            DebugLog(@"Lyrics asked for song: %@ by %@", title, artist);
        }

    return %orig;
}

%end

%hook MediaApplication

- (void)application:(id)app didFinishLaunchingWithOptions:(id)opt
{
    if (DEBUG_ENABLE)
        NSLog(@"LyricsGrabber: I am in.");
    %orig;
}

%end

%hook IUPlaybackViewController

- (void)setItem:(id)item
       animated:(BOOL)animated
{
    // NOTE: Sometimes this method is called twice, once with `item` being an instance of
    //       MediaQueryFakeNowPlayingItem (and the other with `item` an instance of
    //       IUMediaQueryNowPlayingItem). We only need the IUMediaQueryNowPlayingItem
    //       instance.
    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
    {
        LGRController *lgrc = [LGRController sharedController];
        [lgrc handleNowPlayingItem:item];
    }

    %orig;
}

%end

%hook IUNowPlayingAlbumFrontViewController

- (void)setItem:(id)item
{
    // (I think) this is the best way to pinpoint an instance's class.
    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
    {
        // TODO: The shared LGController instance will receive a copy of `item` here
        if (DEBUG_ENABLE)
        {
            NSString *song = [[item mediaItem] valueForProperty:@"title"];
            NSString *artist = [[item mediaItem] valueForProperty:@"artist"];
            NSLog(@"LyricsGrabber: Going to play \"%@\" by \"%@\".", song, artist);

            BOOL hasLyrics = [item hasDisplayableText];
            NSLog(@"LyricsGrabber: Song has lyrics = %i", hasLyrics);
        }
    }

    %orig;
}

%end

// Below are failed tests and experimentations

//%hook IUNowPlayingAlbumFrontViewController
//
//- (void)setItem:(id)item
//{
//    // (I think) this is the best way to pinpoint an instance's class.
//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSString *song = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"title"];
//        NSString *artist = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"artist"];
//        NSLog(@"LyricsGrabber: Going to play \"%@\" by \"%@\".", song, artist);
//
//        BOOL (*HasDisplayableTextSender)(id, SEL) = (BOOL (*)(id, SEL)) objc_msgSend;
//        BOOL hasLyrics = HasDisplayableTextSender(item, @selector(hasDisplayableText));
//        NSLog(@"LyricsGrabber: Song has lyrics = %i", hasLyrics);
//    }
//
//    %orig;
//}
//
//%end
//
//%hook MPConcreteMediaItem
//
//- (id)valueForProperty:(id)property
//{
//    if ([property respondsToSelector:@selector(isEqualToString:)])
//    {
//        if ([(NSString *)property isEqualToString:@"lyrics"])
//        {
//            NSLog(@"LyricsGrabber: MPConcreteMediaItem valueForProperty: =========START=========");
//            NSArray *syms = [NSThread callStackSymbols];
//            if ([syms count] > 1)
//                NSLog(@"LyricsGrabber: MPConcreteMediaItem valueForProperty: caller = %@", [syms objectAtIndex:1U]);
//
//            id returnValue = %orig;
//            NSLog(@"LyricsGrabber: MPConcreteMediaItem valueForProperty: ==========END==========");
//            return returnValue;
//
//            //if (lyrics == nil)
//            //{
//            //    NSURL *url;
//            //    NSString *result;
//            //    for (int i = 0; i < 100; i++)
//            //    {
//            //        url = [NSURL URLWithString:
//            //                 [NSString stringWithFormat:@"http://lyrics.wikia.com/api.php?fmt=text&artist=%@&song=%@",
//            //                                                 %orig(@"artist"), %orig(@"title")]];
//            //        result = [NSString stringWithContentsOfURL:url
//            //                                          encoding:NSUTF8StringEncoding
//            //                                             error:NULL];
//            //    }
//            //    return result; 
//            //}
//        }
//    }
//
//    return %orig(property);
//}
//
//- (void)setValue:(id)value forProperty:(id)property
//{
//    NSLog(@"LyricsGrabber: MPConcreteMediaItem setValue:forProperty: =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: MPConcreteMediaItem setValue:forProperty: caller = %@", [syms objectAtIndex:1U]);
//    %orig;
//    NSLog(@"LyricsGrabber: MPConcreteMediaItem setValue:forProperty: ==========END==========");
//}
//
//%end
//
//%hook MPPortraitInfoOverlay
//
//- (void)_updateAllItemDependenciesForItem:(id)item
//                                  animate:(BOOL)animate
//{
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateAll... =========START==========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateAll... caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateAll... item = %@", item);
//
//    %orig;
//
//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateAll... has lyrics = %i", [item performSelector:@selector(hasDisplayableText)]); 
//    }
//
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateAll... ==========END===========");
//}

//- (void)setItem:(id)item
//{
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay setItem: *********START*********");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: MPPortraitInfoOverlay setItem: caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay setItem: item = %@", item);
//    %orig;
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay setItem: ==========END==========");

//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSString *song = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"title"];
//        NSString *artist = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"artist"];
//        NSLog(@"LyricsGrabber: Going to play \"%@\" by \"%@\".", song, artist);
//    }
//
//    %orig;
//}

//- (void)_updateDisplayableTextViewForItem:(id)item
//                                  animate:(BOOL)animate
//{
//    NSArray *syms = [NSThread callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: caller = %@", [syms objectAtIndex:1U]);
//    if ([item respondsToSelector:@selector(hasDisplayableText)])
//        NSLog(@"LyricsGrabber: item has displayable text = %i", [item performSelector:@selector(hasDisplayableText)]);
//    %orig;

//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateDisp... *********START*********");
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateDisp... item = %@", item);
//
//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateDisp... has lyrics = %i", [item performSelector:@selector(hasDisplayableText)]); 
//    }
//
//    %orig;
//
//    NSLog(@"LyricsGrabber: MPPortraitInfoOverlay _updateDisp... ==========END===========");

//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        BOOL (*HasDisplayableTextSender)(id, SEL) = (BOOL (*)(id, SEL)) objc_msgSend;
//        BOOL hasLyrics = HasDisplayableTextSender(item, @selector(hasDisplayableText));
//        NSLog(@"LyricsGrabber: Song has lyrics = %i", hasLyrics);
//    }
//
//    %orig;
//}
//
//- (void)_displayableTextAvailable:(id)arg
//{
//    NSLog(@"LyricsGrabber: arg = %@", arg);
//    %orig;
//}

//%end

//%hook IUMediaQueryNowPlayingItem
//
//- (id)displayableText
//{
//    NSLog(@"LyricsGrabber: IUMediaQueryNowPlayingItem displayableText =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: IUMediaQueryNowPlayingItem displayableText caller = %@", [syms objectAtIndex:1U]);
//    id returnValue = %orig;
//    NSLog(@"LyricsGrabber: IUMediaQueryNowPlayingItem displayableText ==========END==========");
//    return returnValue;
//}
//
//- (BOOL)hasDisplayableText
//{
//    NSLog(@"LyricsGrabber: IUMediaQueryNowPlayingItem hasDisplayableText =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: IUMediaQueryNowPlayingItem hasDisplayableText caller = %@", [syms objectAtIndex:1U]);
//    BOOL returnValue = (BOOL)%orig;
//    NSLog(@"LyricsGrabber: IUMediaQueryNowPlayingItem hasDisplayableText = %@", [NSNumber numberWithBool:returnValue]);
//    NSLog(@"LyricsGrabber: IUMediaQueryNowPlayingItem hasDisplayableText ==========END==========");
//    return returnValue;
//}
//
//%end

//
//%hook MPAVQueuePlayerFeeder
//
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
//    NSLog(@"LyricsGrabber: MPAVQueuePlayerFeeder observe... =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: MPAVQueuePlayerFeeder observe... caller = %@", [syms objectAtIndex:1U]);
//
//    NSLog(@"LyricsGrabber: MPAVQueuePlayerFeeder keyPath = %@", keyPath);
//    NSLog(@"LyricsGrabber: MPAVQueuePlayerFeeder object = %@", object);
//    NSLog(@"LyricsGrabber: MPAVQueuePlayerFeeder change = %@", change);
//    %orig;
//    NSLog(@"LyricsGrabber: MPAVQueuePlayerFeeder observe... ==========END==========");
//}
//
//%end
//
//%hook MPAVItem
//
//- (NSString *)lyrics
//{
//    NSLog(@"LyricsGrabber: MPAVItem lyrics =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: MPAVItem lyrics: caller = %@", [syms objectAtIndex:1U]);
//    NSString *returnValue = %orig;
//    NSLog(@"LyricsGrabber: MPAVItem lyrics ==========END==========");
//    return returnValue;
//}
//
//%end
//
//%hook MPTextView
//
//- (void)setText:(id)text willLoad:(BOOL)wl
//{
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"LyricsGrabber: MPTextView setText:willLoad: caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"LyricsGrabber: MPTextView willLoad:%@ text:%@", [NSNumber numberWithBool:wl], text);
//    %orig;
//}
//
//%end
