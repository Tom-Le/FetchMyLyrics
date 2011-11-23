/*******************************************************************************
 * FMLCommon.h 
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#define DEBUG_MSG 1
#define DebugLog(fmt, ...) if (DEBUG_MSG == 1) NSLog((@"FetchMyLyrics: " fmt), ##__VA_ARGS__)
