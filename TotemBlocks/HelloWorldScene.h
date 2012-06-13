//
//  HelloWorldLayer.h
//  TotemBlocks
//
//  Created by Felipe Campos Clarke on 27-05-12.
//  Copyright Twisterdev 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#import "Totem.h"
#import <queue>
#import <list>


// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	b2World* _world;
	GLESDebugDraw* _m_debugDraw;
    MyContactListener* _contactListener;
    NSMutableArray *totemsBodyes;
    float _downScroll;
    float _firstTotem;
    NSMutableArray * _vRopes;
    Totem * _totem;
}

-(void) reset;
-(void) addNewTotem;
@property (nonatomic, assign) b2World *world;
@property (nonatomic, assign) GLESDebugDraw *m_debugDraw;
@property (nonatomic, assign) MyContactListener *contactListener;
@property (nonatomic, assign) float downScroll;
@property (nonatomic, assign) float firstTotem;
@property (nonatomic, retain) NSMutableArray *vRopes;
@property (nonatomic, retain) Totem *totem;


@end




// HelloWorldScene
@interface HelloWorldScene : CCScene {
	HelloWorldLayer *_layer;
}

+(CCScene *) scene;
@property (nonatomic, retain) HelloWorldLayer *layer;

@end
