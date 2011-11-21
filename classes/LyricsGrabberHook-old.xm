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
        NSLog(@"L'Fetcher: I am in.");
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
            NSLog(@"L'Fetcher: Going to play \"%@\" by \"%@\".", song, artist);

            BOOL hasLyrics = [item hasDisplayableText];
            NSLog(@"L'Fetcher: Song has lyrics = %i", hasLyrics);
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
//        NSLog(@"L'Fetcher: Going to play \"%@\" by \"%@\".", song, artist);
//
//        BOOL (*HasDisplayableTextSender)(id, SEL) = (BOOL (*)(id, SEL)) objc_msgSend;
//        BOOL hasLyrics = HasDisplayableTextSender(item, @selector(hasDisplayableText));
//        NSLog(@"L'Fetcher: Song has lyrics = %i", hasLyrics);
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
//            NSLog(@"L'Fetcher: MPConcreteMediaItem valueForProperty: =========START=========");
//            NSArray *syms = [NSThread callStackSymbols];
//            if ([syms count] > 1)
//                NSLog(@"L'Fetcher: MPConcreteMediaItem valueForProperty: caller = %@", [syms objectAtIndex:1U]);
//
//            id returnValue = %orig;
//            NSLog(@"L'Fetcher: MPConcreteMediaItem valueForProperty: ==========END==========");
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
//    NSLog(@"L'Fetcher: MPConcreteMediaItem setValue:forProperty: =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: MPConcreteMediaItem setValue:forProperty: caller = %@", [syms objectAtIndex:1U]);
//    %orig;
//    NSLog(@"L'Fetcher: MPConcreteMediaItem setValue:forProperty: ==========END==========");
//}
//
//%end
//
//%hook MPPortraitInfoOverlay
//
//- (void)_updateAllItemDependenciesForItem:(id)item
//                                  animate:(BOOL)animate
//{
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateAll... =========START==========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateAll... caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateAll... item = %@", item);
//
//    %orig;
//
//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateAll... has lyrics = %i", [item performSelector:@selector(hasDisplayableText)]); 
//    }
//
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateAll... ==========END===========");
//}

//- (void)setItem:(id)item
//{
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay setItem: *********START*********");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: MPPortraitInfoOverlay setItem: caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay setItem: item = %@", item);
//    %orig;
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay setItem: ==========END==========");

//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSString *song = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"title"];
//        NSString *artist = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"artist"];
//        NSLog(@"L'Fetcher: Going to play \"%@\" by \"%@\".", song, artist);
//    }
//
//    %orig;
//}

//- (void)_updateDisplayableTextViewForItem:(id)item
//                                  animate:(BOOL)animate
//{
//    NSArray *syms = [NSThread callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: caller = %@", [syms objectAtIndex:1U]);
//    if ([item respondsToSelector:@selector(hasDisplayableText)])
//        NSLog(@"L'Fetcher: item has displayable text = %i", [item performSelector:@selector(hasDisplayableText)]);
//    %orig;

//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateDisp... *********START*********");
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateDisp... item = %@", item);
//
//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateDisp... has lyrics = %i", [item performSelector:@selector(hasDisplayableText)]); 
//    }
//
//    %orig;
//
//    NSLog(@"L'Fetcher: MPPortraitInfoOverlay _updateDisp... ==========END===========");

//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        BOOL (*HasDisplayableTextSender)(id, SEL) = (BOOL (*)(id, SEL)) objc_msgSend;
//        BOOL hasLyrics = HasDisplayableTextSender(item, @selector(hasDisplayableText));
//        NSLog(@"L'Fetcher: Song has lyrics = %i", hasLyrics);
//    }
//
//    %orig;
//}
//
//- (void)_displayableTextAvailable:(id)arg
//{
//    NSLog(@"L'Fetcher: arg = %@", arg);
//    %orig;
//}

//%end

//%hook IUMediaQueryNowPlayingItem
//
//- (id)displayableText
//{
//    NSLog(@"L'Fetcher: IUMediaQueryNowPlayingItem displayableText =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: IUMediaQueryNowPlayingItem displayableText caller = %@", [syms objectAtIndex:1U]);
//    id returnValue = %orig;
//    NSLog(@"L'Fetcher: IUMediaQueryNowPlayingItem displayableText ==========END==========");
//    return returnValue;
//}
//
//- (BOOL)hasDisplayableText
//{
//    NSLog(@"L'Fetcher: IUMediaQueryNowPlayingItem hasDisplayableText =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: IUMediaQueryNowPlayingItem hasDisplayableText caller = %@", [syms objectAtIndex:1U]);
//    BOOL returnValue = (BOOL)%orig;
//    NSLog(@"L'Fetcher: IUMediaQueryNowPlayingItem hasDisplayableText = %@", [NSNumber numberWithBool:returnValue]);
//    NSLog(@"L'Fetcher: IUMediaQueryNowPlayingItem hasDisplayableText ==========END==========");
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
//    NSLog(@"L'Fetcher: MPAVQueuePlayerFeeder observe... =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: MPAVQueuePlayerFeeder observe... caller = %@", [syms objectAtIndex:1U]);
//
//    NSLog(@"L'Fetcher: MPAVQueuePlayerFeeder keyPath = %@", keyPath);
//    NSLog(@"L'Fetcher: MPAVQueuePlayerFeeder object = %@", object);
//    NSLog(@"L'Fetcher: MPAVQueuePlayerFeeder change = %@", change);
//    %orig;
//    NSLog(@"L'Fetcher: MPAVQueuePlayerFeeder observe... ==========END==========");
//}
//
//%end
//
//%hook MPAVItem
//
//- (NSString *)lyrics
//{
//    NSLog(@"L'Fetcher: MPAVItem lyrics =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"L'Fetcher: MPAVItem lyrics: caller = %@", [syms objectAtIndex:1U]);
//    NSString *returnValue = %orig;
//    NSLog(@"L'Fetcher: MPAVItem lyrics ==========END==========");
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
//        NSLog(@"L'Fetcher: MPTextView setText:willLoad: caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"L'Fetcher: MPTextView willLoad:%@ text:%@", [NSNumber numberWithBool:wl], text);
//    %orig;
//}
//
//%end
