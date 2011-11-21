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
        NSLog(@"iPodLyrics: I am in.");
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
            NSLog(@"iPodLyrics: Going to play \"%@\" by \"%@\".", song, artist);

            BOOL hasLyrics = [item hasDisplayableText];
            NSLog(@"iPodLyrics: Song has lyrics = %i", hasLyrics);
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
//        NSLog(@"iPodLyrics: Going to play \"%@\" by \"%@\".", song, artist);
//
//        BOOL (*HasDisplayableTextSender)(id, SEL) = (BOOL (*)(id, SEL)) objc_msgSend;
//        BOOL hasLyrics = HasDisplayableTextSender(item, @selector(hasDisplayableText));
//        NSLog(@"iPodLyrics: Song has lyrics = %i", hasLyrics);
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
//            NSLog(@"iPodLyrics: MPConcreteMediaItem valueForProperty: =========START=========");
//            NSArray *syms = [NSThread callStackSymbols];
//            if ([syms count] > 1)
//                NSLog(@"iPodLyrics: MPConcreteMediaItem valueForProperty: caller = %@", [syms objectAtIndex:1U]);
//
//            id returnValue = %orig;
//            NSLog(@"iPodLyrics: MPConcreteMediaItem valueForProperty: ==========END==========");
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
//    NSLog(@"iPodLyrics: MPConcreteMediaItem setValue:forProperty: =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: MPConcreteMediaItem setValue:forProperty: caller = %@", [syms objectAtIndex:1U]);
//    %orig;
//    NSLog(@"iPodLyrics: MPConcreteMediaItem setValue:forProperty: ==========END==========");
//}
//
//%end
//
//%hook MPPortraitInfoOverlay
//
//- (void)_updateAllItemDependenciesForItem:(id)item
//                                  animate:(BOOL)animate
//{
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateAll... =========START==========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateAll... caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateAll... item = %@", item);
//
//    %orig;
//
//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateAll... has lyrics = %i", [item performSelector:@selector(hasDisplayableText)]); 
//    }
//
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateAll... ==========END===========");
//}

//- (void)setItem:(id)item
//{
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay setItem: *********START*********");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: MPPortraitInfoOverlay setItem: caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay setItem: item = %@", item);
//    %orig;
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay setItem: ==========END==========");

//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSString *song = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"title"];
//        NSString *artist = [[item performSelector:@selector(mediaItem)]
//                                performSelector:@selector(valueForProperty:)
//                                     withObject:@"artist"];
//        NSLog(@"iPodLyrics: Going to play \"%@\" by \"%@\".", song, artist);
//    }
//
//    %orig;
//}

//- (void)_updateDisplayableTextViewForItem:(id)item
//                                  animate:(BOOL)animate
//{
//    NSArray *syms = [NSThread callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: caller = %@", [syms objectAtIndex:1U]);
//    if ([item respondsToSelector:@selector(hasDisplayableText)])
//        NSLog(@"iPodLyrics: item has displayable text = %i", [item performSelector:@selector(hasDisplayableText)]);
//    %orig;

//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateDisp... *********START*********");
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateDisp... item = %@", item);
//
//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateDisp... has lyrics = %i", [item performSelector:@selector(hasDisplayableText)]); 
//    }
//
//    %orig;
//
//    NSLog(@"iPodLyrics: MPPortraitInfoOverlay _updateDisp... ==========END===========");

//    if ([@"IUMediaQueryNowPlayingItem" isEqualToString:[NSString stringWithUTF8String:object_getClassName(item)]])
//    {
//        BOOL (*HasDisplayableTextSender)(id, SEL) = (BOOL (*)(id, SEL)) objc_msgSend;
//        BOOL hasLyrics = HasDisplayableTextSender(item, @selector(hasDisplayableText));
//        NSLog(@"iPodLyrics: Song has lyrics = %i", hasLyrics);
//    }
//
//    %orig;
//}
//
//- (void)_displayableTextAvailable:(id)arg
//{
//    NSLog(@"iPodLyrics: arg = %@", arg);
//    %orig;
//}

//%end

//%hook IUMediaQueryNowPlayingItem
//
//- (id)displayableText
//{
//    NSLog(@"iPodLyrics: IUMediaQueryNowPlayingItem displayableText =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: IUMediaQueryNowPlayingItem displayableText caller = %@", [syms objectAtIndex:1U]);
//    id returnValue = %orig;
//    NSLog(@"iPodLyrics: IUMediaQueryNowPlayingItem displayableText ==========END==========");
//    return returnValue;
//}
//
//- (BOOL)hasDisplayableText
//{
//    NSLog(@"iPodLyrics: IUMediaQueryNowPlayingItem hasDisplayableText =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: IUMediaQueryNowPlayingItem hasDisplayableText caller = %@", [syms objectAtIndex:1U]);
//    BOOL returnValue = (BOOL)%orig;
//    NSLog(@"iPodLyrics: IUMediaQueryNowPlayingItem hasDisplayableText = %@", [NSNumber numberWithBool:returnValue]);
//    NSLog(@"iPodLyrics: IUMediaQueryNowPlayingItem hasDisplayableText ==========END==========");
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
//    NSLog(@"iPodLyrics: MPAVQueuePlayerFeeder observe... =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: MPAVQueuePlayerFeeder observe... caller = %@", [syms objectAtIndex:1U]);
//
//    NSLog(@"iPodLyrics: MPAVQueuePlayerFeeder keyPath = %@", keyPath);
//    NSLog(@"iPodLyrics: MPAVQueuePlayerFeeder object = %@", object);
//    NSLog(@"iPodLyrics: MPAVQueuePlayerFeeder change = %@", change);
//    %orig;
//    NSLog(@"iPodLyrics: MPAVQueuePlayerFeeder observe... ==========END==========");
//}
//
//%end
//
//%hook MPAVItem
//
//- (NSString *)lyrics
//{
//    NSLog(@"iPodLyrics: MPAVItem lyrics =========START=========");
//    NSArray *syms = [NSThread  callStackSymbols];
//    if ([syms count] > 1)
//        NSLog(@"iPodLyrics: MPAVItem lyrics: caller = %@", [syms objectAtIndex:1U]);
//    NSString *returnValue = %orig;
//    NSLog(@"iPodLyrics: MPAVItem lyrics ==========END==========");
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
//        NSLog(@"iPodLyrics: MPTextView setText:willLoad: caller = %@", [syms objectAtIndex:1U]);
//    NSLog(@"iPodLyrics: MPTextView willLoad:%@ text:%@", [NSNumber numberWithBool:wl], text);
//    %orig;
//}
//
//%end
