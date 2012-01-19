/*******************************************************************************
 * NSObject+InstanceVariable.h
 * FetchMyLyrics
 *
 * Referenced from:
 *     http://stackoverflow.com/questions/1219081/
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <objc-runtime.h>

@interface NSObject (InstanceVariable)
- (void *)pointerToInstanceVariable:(NSString *)ivarName;
- (id)objectInstanceVariable:(NSString *)ivarName;
@end
