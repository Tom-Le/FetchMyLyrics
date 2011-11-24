/*******************************************************************************
 * FMLAppDelegate.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <UIKit/UIKit.h>

@class FMLRootViewController;

@interface FMLAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *_window;
    FMLRootViewController *_rootViewController;
}

@end
