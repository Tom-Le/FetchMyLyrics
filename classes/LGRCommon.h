/*******************************************************************************
 * LGRCommon.h 
 * L'Fetcher
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 ******************************************************************************/

// For debugging (because they say NSLog is synchronous and all)
#define DEBUG_MSG 1
#define DebugLog(fmt, ...) if (DEBUG_MSG == 1) NSLog((@"L'Fetcher: " fmt), ##__VA_ARGS__)
