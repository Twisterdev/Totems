//
//  Lavel.h
//  TotemBlocks
//
//  Created by Felipe Campos Clarke on 28-05-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject {
    int _levelNum;
    NSString *_bgImage;
}

@property (nonatomic, assign) int levelNum;
@property (nonatomic, copy) NSString *bgImage;

- (id)initWithLevelNum:(int)levelNum bgImage:(NSString *)bgImage;

@end
