/*******************************************************************************
 * FMLApp-main.m
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#include <UIKit/UIKit.h>
#include "FMLAppDelegate.h"

int main(int argc, char **argv)
{
    NSAutoreleasePool *_pool = [[NSAutoreleasePool alloc] init];
    int ret = UIApplicationMain(argc, argv, nil, NSStringFromClass([FMLAppDelegate class]));
    [_pool drain];
    return ret;
}
