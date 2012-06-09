//
//  AppDelegate.h
//  TotemBlocks
//
//  Created by Felipe Campos Clarke on 27-05-12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class HelloWorldScene;
@class Level;
@class AddLevel;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	RootViewController	*viewController;
    UIWindow			*window;
    int _curLevelIndex;
    NSMutableArray * _levels;
    AddLevel * _newLevelScene;
    HelloWorldScene *_mainScene;
    
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) int curLevelIndex;
@property (nonatomic, retain) CCScene *mainScene;
@property (nonatomic, retain) NSMutableArray *levels;

- (Level *)curLevel;
//- (void)nextLevel;
//- (void)levelComplete;
//- (void)restartGame;
//- (void)loadGameOverScene;
//- (void)loadWinScene;

@end
