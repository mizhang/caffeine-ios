//
//  CoverageFix.m
//  caffeine-ios
//
//  Created by Drew Crawford on 2/1/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

#import "CoverageFix.h"

static id mainSuite = nil;

@implementation CoverageFix

- (void)stopObserving
{
    [super stopObserving];
    extern void __gcov_flush(void);
    __gcov_flush();
}



@end

