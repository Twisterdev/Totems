//
//  Totem.h
//  TotemBlocks
//
//  Created by Felipe Campos Clarke on 31-05-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "VRope.h"
#import <queue>
#import <list>

@interface Totem : CCNode

{
    NSMutableArray * _vRopes;
    CCSpriteBatchNode * _ropeSpriteSheet;
    BOOL    ropeCutted;
    b2Body * _anchorBody;
    VRope * _addRope;
    b2World * _world;
    b2Body *_finalBody;
}

- (id)initWithWorld : (b2World *)world downScroll: (float)downScroll;

@property (nonatomic, assign) b2World * world;
@property (nonatomic, retain) VRope * addRope;
@property (nonatomic, retain) NSMutableArray * vRopes;
@property (nonatomic, assign) b2Body * anchorBody;
@property (nonatomic, assign) b2Body * finalBody;
@property (nonatomic, retain)CCSpriteBatchNode * ropeSpriteSheet;


@end