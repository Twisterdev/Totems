//
//  MyContactListener.m
//  Box2DBreakout
//
//  Created by Felipe Campos Clarke on 08-05-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyContactListener.h"

MyContactListener::MyContactListener() : _contacts() {
}

MyContactListener::~MyContactListener() {
}

void MyContactListener::BeginContact(b2Contact* contact) {
    
}

void MyContactListener::EndContact(b2Contact* contact) {

}

void MyContactListener::PreSolve(b2Contact* contact, 
                                 const b2Manifold* oldManifold) {
}

void MyContactListener::PostSolve(b2Contact* contact, 
                                  const b2ContactImpulse* impulse) {
    
    
    bool isAEnemy = contact->GetFixtureA()->GetBody()->GetUserData() != NULL;
    bool isBEnemy = contact->GetFixtureB()->GetBody()->GetUserData() != NULL;
    
    if (isAEnemy || isBEnemy)
    {
        
        int32 count = contact->GetManifold()->pointCount;
        
        float32 maxImpulse = 0.0f;
        for (int32 i = 0; i < count; ++i)
        {
            maxImpulse = b2Max(maxImpulse, impulse->normalImpulses[i]);
        }
        
        if (maxImpulse > 6.0f)
        {
            MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
            _contacts.push_back(myContact);
        }
    }
}