/*******************************************************************************
 * LGRCommon.h 
 * iPodLyrics
 *
 * Copyright 2011, Le Son.
 * All rights reserved.
 * Licensed under the BSD license, included with the source.
 ******************************************************************************/

// For debugging (because they say NSLog is synchronous and all)
#define DEBUG_MSG 1
#define DebugLog(fmt, ...) if (DEBUG_MSG == 1) NSLog((@"iPodLyrics: " fmt), ##__VA_ARGS__)
