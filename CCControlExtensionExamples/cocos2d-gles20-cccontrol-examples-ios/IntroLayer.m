//
//  IntroLayer.m
//  CControlExtensionExample
//
//  Created by Yannick Loriot on 1/3/13.
//  Copyright Yannick Loriot 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "CCControlSceneManager.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)onEnter
{
	[super onEnter];

	// Ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Default.png"];
		background.rotation = 90;
	} else {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:1];
}

- (void)makeTransition:(ccTime)dt
{
    // Retrieve the scene manager
    CCControlSceneManager *sceneManager = [CCControlSceneManager sharedControlSceneManager];
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[sceneManager currentControlScene]]];
}
@end
