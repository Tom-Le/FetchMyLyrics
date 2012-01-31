/*******************************************************************************
 * FMLOperation.h
 * FetchMyLyrics
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>

@protocol FMLOperation

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *lyrics;

+ (id)operation;
- (void)completeOperation;

@end

