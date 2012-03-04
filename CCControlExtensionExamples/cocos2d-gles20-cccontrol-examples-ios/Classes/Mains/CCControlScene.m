/*
 * CCControlScene.m
 *
 * Copyright (c) 2011 Yannick Loriot
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCControlScene.h"

#import "CCControlSceneManager.h"

@interface CCControlScene ()

// Menu Callbacks
- (void)previousCallback:(id)sender;
- (void)restartCallback:(id)sender;
- (void)nextCallback:(id)sender;

@end

@implementation CCControlScene
@synthesize sceneTitleLabel;

- (void) dealloc
{
    [sceneTitleLabel release], sceneTitleLabel = nil;
    
	[super dealloc];
}

#pragma mark Constructors - Initializers

- (id)init
{
	if ((self = [super init]))
    {    
        // Get the sceensize
        CGSize screensize = [[CCDirector sharedDirector] winSize];

        // Add the generated background
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        [background setPosition:ccp(screensize.width / 2, screensize.height / 2)];
        [self addChild:background];
        
        // Add the ribbon
        CCScale9Sprite *ribbon = [CCScale9Sprite spriteWithFile:@"ribbon.png" capInsets:CGRectMake(1, 1, 48, 55)];
        [ribbon setContentSize:CGSizeMake(screensize.width, 57)];
        [ribbon setPosition:ccp(screensize.width / 2.0f, screensize.height - ribbon.contentSize.height / 2.0f)];
        [self addChild:ribbon];
        
        // Add the title
        self.sceneTitleLabel = [CCLabelTTF labelWithString:@"Title" fontName:@"Arial" fontSize:12];
        [sceneTitleLabel setPosition:ccp (screensize.width / 2, screensize.height - sceneTitleLabel.contentSize.height / 2 - 5)];
        [self addChild:sceneTitleLabel z:1];
        
        // Add the menu
		CCMenuItemImage *item1 = 
        [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(previousCallback:)];
		CCMenuItemImage *item2 =
        [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 =
        [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
        
		CCMenu *menu = [CCMenu menuWithItems:item1, item3, item2, nil];
        [menu setPosition:CGPointZero];
		[item1 setPosition:ccp(screensize.width / 2 - 100, 37)];
		[item2 setPosition:ccp(screensize.width / 2, 35)];
		[item3 setPosition:ccp(screensize.width / 2 + 100, 37)];
        
		[self addChild:menu z:1];
    }
    return self;
}

+ (CCScene *)sceneWithTitle:(NSString *)title
{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CCControlScene *controlLayer = [self node];
	[controlLayer.sceneTitleLabel setString:title];
    
	// add layer as a child to scene
	[scene addChild:controlLayer];
	
	// return the scene
	return scene;
}

#pragma mark -
#pragma mark CCControlScene Public Methods

#pragma mark CCControlScene Private Methods

- (void)previousCallback:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[[CCControlSceneManager sharedControlSceneManager] previousControlScene]];
}

- (void)restartCallback:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[[CCControlSceneManager sharedControlSceneManager] currentControlScene]];
}

- (void)nextCallback:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[[CCControlSceneManager sharedControlSceneManager] nextControlScene]];
}

@end
