/*******************************************************************************
 * FMLAppDelegate.m
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "FMLAppDelegate.h"
#import "FMLRootViewController.h"

@implementation FMLAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _rootViewController = [[FMLRootViewController alloc] init];
    [_window addSubview:_rootViewController.view];
    [_window makeKeyAndVisible];
}

- (void)dealloc
{
    [_rootViewController release];
    [_window release];

    [super dealloc];
}

@end
