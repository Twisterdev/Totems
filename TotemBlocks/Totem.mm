//
//  Totem.m
//  TotemBlocks
//
//  Created by Felipe Campos Clarke on 31-05-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Totem.h"

enum {
    FLOOR   = 0,
    TOTEMMOVING   = 1,
    TOTEMSTAND = 2,
    ROPE    = 3,
};

@implementation Totem

@synthesize world = _world;
@synthesize addRope = _addRope;
@synthesize vRopes = _vRopes;
@synthesize anchorBody = _anchorBody;
@synthesize finalBody = _finalBody;
@synthesize ropeSpriteSheet = _ropeSpriteSheet;


- (id)initWithWorld : (b2World *)world downScroll : (float)downScroll {
    
    self = [super init];
    if (self)
    {
        
        _world = world;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        self.ropeSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"rope.png" ];
        [self addChild:self.ropeSpriteSheet];
        // +++ Init array that will hold references to all our ropes
        self.vRopes = [[NSMutableArray alloc] init];
        
        b2BodyDef theBody;
        b2PolygonShape theBox;
        b2FixtureDef totemDef;
        
        theBody.type = b2_dynamicBody;
        theBody.position.Set(6.0f, 13.0f + downScroll);
        theBody.userData = @"1";
        
        self.finalBody = _world->CreateBody(&theBody);

        theBox.SetAsBox(.75f, .75f);
        totemDef.shape = &theBox;
        totemDef.density = 1;
        totemDef.friction = 0.3f;
        totemDef.restitution = 0;

        
        _finalBody->CreateFixture(&totemDef);
        
        //b2Vec2 force = b2Vec2(10, -2);
        //_finalBody->ApplyLinearImpulse(force, theBody.position);
        
        
        b2BodyDef anchorBodyDef;
        anchorBodyDef.position.Set(screenSize.width/PTM_RATIO/2,screenSize.height/PTM_RATIO + downScroll); 
        self.anchorBody = _world->CreateBody(&anchorBodyDef);
        b2RopeJointDef jd;
        jd.bodyA = self.anchorBody; //define bodies
        jd.bodyB = _finalBody;
        jd.localAnchorA = b2Vec2(0,0); //define anchors
        jd.localAnchorB = b2Vec2(0,0);
        jd.maxLength= (_finalBody->GetPosition() - self.anchorBody->GetPosition()).Length(); //define max length of joint = current distance between bodies
        _world->CreateJoint(&jd); //create joint
        // +++ Create VRope
        _ropeSpriteSheet.tag = ROPE;
        self.addRope = [[VRope alloc] init: _anchorBody body2:_finalBody spriteSheet:_ropeSpriteSheet];
        
        [self.vRopes addObject:_addRope]; 
        
    }
    
    return self;
}

/*
+ (b2FixtureDef *) getDefinition{
    b2PolygonShape theBox;
    b2FixtureDef totemDef;
    theBox.SetAsBox(.75f, .75f);
    totemDef.shape = &theBox;
    totemDef.density = 1;
    totemDef.friction = 0.4f;
    totemDef.restitution = 0;
    
}
*/

@end
