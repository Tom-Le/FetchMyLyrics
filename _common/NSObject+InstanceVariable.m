/*******************************************************************************
 * NSObject+InstanceVariable.m
 * FetchMyLyrics
 *
 * Referenced from:
 *     http://stackoverflow.com/questions/1219081/
 *
 * Copyright (C) 2011 by Le Son.
 * Licensed under the MIT License, bundled with the source or available here:
 *     https://raw.github.com/precocity/FetchMyLyrics/master/LICENSE
 ******************************************************************************/

#import "NSObject+InstanceVariable.h"
#import "FMLCommon.h"

@implementation NSObject (InstanceVariable)

- (void *)pointerToInstanceVariable:(NSString *)ivarName
{
    if (ivarName)
    {
        Ivar ivar = object_getInstanceVariable(self, [ivarName UTF8String], NULL);
        if (ivar)
        {
            return (void *)((char *)self + ivar_getOffset(ivar));
        }
    }
    return NULL;
}

- (id)objectInstanceVariable:(NSString *)ivarName
{
    if (ivarName)
    {
        Ivar ivar = object_getInstanceVariable(self, [ivarName UTF8String], NULL);
        if (ivar)
        {
            return object_getIvar(self, ivar);
        }
    }
    return nil;
}

@end
