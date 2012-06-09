//
//  Lavel.m
//  TotemBlocks
//
//  Created by Felipe Campos Clarke on 28-05-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Level.h"

@implementation Level

@synthesize levelNum = _levelNum;
@synthesize bgImage = _bgImage;

- (id)initWithLevelNum:(int)levelNum bgImage:(NSString *)bgImage {
    
    if ((self = [super init])) {
        self.levelNum = levelNum;
        self.bgImage = bgImage;
    }
    
    return self;
    
}

@end
