//
//  HelloWorldLayer.mm
//  TotemBlocks
//
//  Created by Felipe Campos Clarke on 27-05-12.
//  Copyright Twisterdev 2012. All rights reserved.
//


//Importo la interfaz y la clase totem
#import "HelloWorldScene.h"

//Defino el radio que simula un metro, cada 32px se cuenta un metro
//esto se utiliza por que box2D no trabaja en base a pixeles
#define PTM_RATIO 32

// enums that will be used as tags
enum {
    FLOOR   = 0,
    TOTEMMOVING   = 1,
    TOTEMSTAND = 2,
    ROPE    = 3,
};


//La primera implementacion (HelloWorldScene) retorna una CCScene 
//con el CCLayer "HelloWorldLayer que esta definido mas bajo"
//esto fue modificado por que estamos controlado todo desde el delegado
@implementation HelloWorldScene

@synthesize layer = _layer;

+(CCScene *) scene
{
	//Scene es un objeto autorelease
	HelloWorldScene *scene = [HelloWorldScene node];
	
	//layer es un objeto autorelease
    //se entrega el objeto layer a la variable de instancia layer
    //esto es necesario por que el layer debe ser referenciado desde el delegado
	HelloWorldLayer *layer = [HelloWorldLayer node];
    scene.layer = layer;
	
	//Se añade el layer como un hijo a la escena
	[scene addChild: layer];
	
	//Se retorna la escena
	return scene;
}

- (void)dealloc {
    self.layer = nil;
    [super dealloc];
}

@end
//HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize world = _world;
@synthesize m_debugDraw = _m_debugDraw;
@synthesize contactListener = _contactListener;
@synthesize downScroll = _downScroll;
@synthesize firstTotem = _firstTotem;
@synthesize vRopes = _vRopes;
@synthesize totem = _totem;

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        //CGSize screenSize = [CCDirector sharedDirector].winSize;
        b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
        bool doSleep = true;
        _world = new b2World(gravity, doSleep);
		_world->SetContinuousPhysics(true);
        
        // Debug object
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        
        // Create contact listener
        self.contactListener = new MyContactListener();
        _world->SetContactListener(self.contactListener);
        
        //m_debugDraw = new GLESDebugDraw(PTM_RATIO); 
		
		// Debug Draw functions
		self.m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		_world->SetDebugDraw(self.m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		self.m_debugDraw->SetFlags(flags);	
        
        b2Body * final_body;
        b2BodyDef the_body;
        b2PolygonShape the_box;
        b2FixtureDef flor_def;
        
        the_body.type = b2_staticBody;
        the_body.position.Set(5.0f, .75f);
        the_body.userData = @"0";
        final_body = _world->CreateBody(&the_body);
        flor_def.shape = &the_box;
        the_box.SetAsBox(10.0f, .75f);
        
        flor_def.density = 0;
        flor_def.friction = 0.6f;
        flor_def.restitution = 0;
        
        final_body->CreateFixture(&flor_def);
        
        self.firstTotem = false;
        
        totemsBodyes = [[NSMutableArray alloc] init];
        [self addNewTotem];
        
        [self schedule:@selector(tick:)];
        [self schedule: @selector(update:) interval:0.03];
        
        //[self schedule:@selector(addNewRandomObject:) interval:1.0];

	}
	return self;
}

-(void) draw
{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	_world->DrawDebugData();
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    for(uint i=0;i<[self.vRopes count];i++) {
        [[self.vRopes objectAtIndex:i] updateSprites];
    }
    

}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    [[self totem ] anchorBody]->SetType(b2_dynamicBody);
    
    //IMPLEMENTAR METODO DESTRUCTOR DE ESTRELLA Y REBISAR EL MUTABLE ARRAY
    for(uint i=0;i<[[[self.vRopes lastObject] ropeSprites] count];i++) {
            id fadeout = [CCFadeOut actionWithDuration:0.5f];
            [[[[self.vRopes lastObject] ropeSprites] objectAtIndex:i] runAction:fadeout];
    }
    
}


-(b2Body *) selectTotem: (int)totemIndex{
    NSValue * bodyPointer = [totemsBodyes objectAtIndex: totemIndex];
    b2Body *body = (b2Body *) [bodyPointer pointerValue];
    return body;
    
}

-(void) moveScreen: (int)level up: (Boolean)up{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float middleScreen = (winSize.height / PTM_RATIO) * 0.5;
    float topObject = [self selectTotem:[totemsBodyes count] - 1]->GetPosition().y;
    
    if(topObject >= middleScreen || [totemsBodyes count] >= 5){
        
        if(up){
            self.downScroll += [self selectTotem:[totemsBodyes count] - 4 + level]->GetPosition().y -
            [self selectTotem:[totemsBodyes count] - 5]->GetPosition().y;
            NSLog(@"MITAD %f", round(_downScroll + (winSize.height / PTM_RATIO) * 0.5 + .75f));
            NSLog(@"ULTIMO TOTEM %f", round(topObject + _downScroll));
        }else{
            int from, until;
            do {
                level++;
                if([totemsBodyes count] == 5)
                    break;
                topObject = [self selectTotem:[totemsBodyes count] - 2]->GetPosition().y;
                from = round(topObject + 1.5f * level);
                until = round((_downScroll - 1.5f) + (winSize.height / PTM_RATIO) * 0.5 + .75f);
            } while (from != until);
            
            level--;
            self.downScroll -= [self selectTotem:[totemsBodyes count] - 4 + level]->GetPosition().y -
            [self selectTotem:[totemsBodyes count] - 5]->GetPosition().y;
        }
        
        CGPoint pointDest = ccp(0, - PTM_RATIO * _downScroll);
        id action  = [CCMoveTo actionWithDuration:1 position: pointDest]; 
        id ease    = [CCEaseExponentialOut actionWithAction:action]; 
        [self runAction:ease];
    }
}

-(void)addNewTotem{
    //REVISAR QUE TAN EFICIENTE ES HACER ACA UN AUTORELEASE
    self.totem = [[[Totem alloc] initWithWorld:_world downScroll:_downScroll] autorelease];
    b2Body *totemBody = [_totem finalBody];
    [totemsBodyes addObject:[NSValue valueWithPointer:totemBody]];
    self.vRopes = [self.totem vRopes];
    [self addChild: self.totem];
}


-(void) update: (ccTime) dt 
{
    
    Boolean createTotem = true;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    //float destroyPosiyion = ceil(((screenSize.height / PTM_RATIO) * 0.15) * 10) / 10;
    float destroyPosiyion = ceil((screenSize.height / PTM_RATIO) * 0.15);
    if([totemsBodyes count] >= 2){
        
        b2Body * body;
        int limit = [totemsBodyes count] - 2;
        if([totemsBodyes count] == 2)
            limit = 1;
        
        for(uint i=limit;i<[totemsBodyes count];i++) {
            body = [self selectTotem:i];
            
            if(body->GetLinearVelocity().Length() != 0 || 
               body->GetPosition().y > ((screenSize.height / PTM_RATIO) * 0.5) + _downScroll)
                createTotem = false;
            
            if(body->GetPosition().y < destroyPosiyion){
                
                Boolean waitCreate = false;
                
                if([totemsBodyes count]-1 == i){
                    if([totemsBodyes count] >= 3){
                        if([self selectTotem:[totemsBodyes count] - 3]->GetType() == b2_staticBody){
                            NSLog(@"velocidad: %i", (int)[self selectTotem:i - 1]->GetLinearVelocity().Length());
                            if((int)[self selectTotem:i - 1]->GetLinearVelocity().Length() != 0 && 
                               [totemsBodyes count] != 5){
                                waitCreate = true;
                                createTotem = false;
                            }else{
                                [self moveScreen:0 up:false];
                                waitCreate = false;
                            }
                        }
                    }else if([totemsBodyes count]-2 == i){
                        if([totemsBodyes count] >= 3){
                            waitCreate = false;
                        }
                    }
                    
                    if(!waitCreate){
                        [self addNewTotem];
                        createTotem = false;
                    }
                }
                
                
                _world->DestroyBody(body);
                [totemsBodyes removeObject:[NSValue valueWithPointer:body]];
                if([totemsBodyes count] >= 3){
                    if(waitCreate)
                        body = [self selectTotem:[totemsBodyes count] - 2];
                    else
                        body = [self selectTotem:[totemsBodyes count] - 3];
                        
                    body->SetType(b2_dynamicBody);
                    //b2FixtureDef *totemDef = [Totem getDefinition];
                    b2PolygonShape theBox;
                    b2FixtureDef totemDef;
                    theBox.SetAsBox(.75f, .75f);
                    totemDef.shape = &theBox;
                    totemDef.density = 1;
                    totemDef.friction = 0.4f;
                    totemDef.restitution = 0;
                    body->DestroyFixture(body->GetFixtureList());
                    body->CreateFixture(&totemDef);
                }
            }
        }
        if(createTotem)
            [self addNewTotem];
    }
}


-(void) tick: (ccTime) dt
{
    
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	_world->Step(dt, velocityIterations, positionIterations);
    
    Boolean hitTotem = false;
    
    for(uint i=0;i<[self.vRopes count];i++) {
        [[self.vRopes objectAtIndex:i] update:dt];
    }
    
    std::vector<MyContact>::iterator pos;
    
    for(pos = self.contactListener->_contacts.begin(); 
        pos != self.contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        NSString *blockA = (NSString *) bodyA->GetUserData();
        NSString *blockB = (NSString *) bodyB->GetUserData();
        
        if([blockA isEqualToString:@"1"] && [blockB isEqualToString:@"1"]){
            
            if([totemsBodyes indexOfObject:[NSValue valueWithPointer:bodyA]] == [totemsBodyes count] - 1 ||
               [totemsBodyes indexOfObject:[NSValue valueWithPointer:bodyB]] == [totemsBodyes count] - 1){
                
                //Convierto el antepenultimo totem en un cuerpo estatico
                //para que solo los ultimos dos cuerpos de la torre reacciones a estimulos del mundo
                if([totemsBodyes count] >= 3){
                    b2Body * body = [self selectTotem:[totemsBodyes count] - 3];
                    body->SetType(b2_staticBody);
                }
                
                if(!hitTotem)
                    [self moveScreen:0 up:true];
                hitTotem = true;
            }
        }
        
        
        if([totemsBodyes count] == 1 || hitTotem){
            b2Joint *j = _world->GetJointList();
            if(j)
                _world->DestroyJoint(j);
            
            [_vRopes removeAllObjects];
            
            if([totemsBodyes count] == 1)
                [self addNewTotem];
        }
    }
    
    self.contactListener->_contacts.clear();
    
    
    
    
    /*
    for(pos = self.contactListener->_contacts.begin(); 
        pos != self.contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        
        
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            
            //CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            //CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            NSString *blockA = (NSString *) bodyA->GetUserData();
            NSString *blockB = (NSString *) bodyB->GetUserData();
            NSLog(@"OBJETO1 %@ OBJETO2 %@", blockA, blockB);
            
            
            if(([blockA isEqualToString:@"1"] && [blockB isEqualToString:@"2"])|| 
               ([blockA isEqualToString:@"2"] && [blockB isEqualToString:@"1"])){
                
                if([blockA isEqualToString:@"1"]){
                    bodyA->SetUserData(@"2");
                }else{
                    bodyB->SetUserData(@"2");
                }
                
                CGSize winSize = [CCDirector sharedDirector].winSize;
                float middleScreen = (winSize.height / PTM_RATIO) * 0.5;
                
                b2Body *bodyTop;
                b2Body *bodyBottom;
                float topObject = 0;
                
                if(bodyA->GetPosition().y > bodyB->GetPosition().y){
                    bodyTop = bodyA;
                    bodyBottom = bodyB;
                    topObject = bodyTop->GetPosition().y;
                }else{
                    bodyTop = bodyB;
                    bodyBottom = bodyA;
                    topObject = bodyTop->GetPosition().y;
                }
                
                NSLog(@"ultimocubo %f", topObject);
                //NSLog(@"Cube hit Y position1: %f Y psotion2: %f", bodyB->GetPosition().y, 0.5f);
                
                if(topObject >= middleScreen){
                    
                    _downScroll = floor(topObject) - ((middleScreen) - 1);
                    CGPoint pointDest = ccp(0,-PTM_RATIO * _downScroll);
                    
                    id action  = [CCMoveTo actionWithDuration:1 position: pointDest]; 
                    id ease    = [CCEaseExponentialOut actionWithAction:action]; 
                    [self runAction:[CCSequence actions: ease, nil]]; 
                    
                    if(floor(topObject) > middleScreen + 1)
                        destroy = true;
                }
                
                toDestroy.push_back(bodyBottom);
                //bodyBottom->SetUserData(NULL);
                
                b2Joint *j = _world->GetJointList();
                if(j)
                    _world->DestroyJoint(j);
                
                [_vRopes removeAllObjects];
                [self addNewTotem];

                
            }else if(([blockA isEqualToString:@"1"] && [blockB isEqualToString:@"0"])|| 
                     ([blockA isEqualToString:@"0"] && [blockB isEqualToString:@"1"])){
                
                if(!_firstTotem){
                    if([blockA isEqualToString:@"1"]){
                        bodyA->SetUserData(@"2");
                    }else{
                        bodyB->SetUserData(@"2");
                    }
                    
                    b2Joint *j = _world->GetJointList();
                    if(j)
                        _world->DestroyJoint(j);
                    
                    [_vRopes removeAllObjects];
                    self.firstTotem = true;
                    [self addNewTotem];
                }else{
                    destroyOne = true;
                     toDestroy.push_back(bodyB);
                    
                    b2Joint *j = _world->GetJointList();
                    if(j)
                        _world->DestroyJoint(j);
                    
                    [_vRopes removeAllObjects];
                    self.firstTotem = true;
                    [self addNewTotem];
                }
            }
        }             
    }
    
    //ELIMINAR CUALQUIERA QUE SEA MENOR QUE EL PRIMER TOTEM X
    //HAY QUE HACER UN TOTEM BASE COMO TAG
    
    
    if(destroyOne){
        b2Body *lastBody = toDestroy[toDestroy.size()-1];
        _world->DestroyBody(lastBody);
        toDestroy.erase(toDestroy.begin());
        destroyOne = false;
    }
    
    if(destroy){
        //_world->DestroyBody(body);
        b2Body *lastBody = toDestroy[0];
        b2Body *staticBody = toDestroy[1];
        staticBody->SetType(b2_staticBody);
        _world->DestroyBody(lastBody);
        toDestroy.erase(toDestroy.begin());
        //_world->DestroyBody(body);
    }
    
    */
}



-(void)reset {

}


- (void) dealloc
{
	delete _world;
	_world = NULL;
	delete _m_debugDraw;
    _m_debugDraw = NULL;
    delete _contactListener;
    _contactListener = NULL;
    [_vRopes release];

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
