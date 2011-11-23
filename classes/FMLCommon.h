/*******************************************************************************
 * FMLCommon.h 
 * FetchMyLyrics
 ******************************************************************************/

#define DEBUG_MSG 1
#define DebugLog(fmt, ...) if (DEBUG_MSG == 1) NSLog((@"FetchMyLyrics: " fmt), ##__VA_ARGS__)
