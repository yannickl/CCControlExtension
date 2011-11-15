/*
 * CCControlButtonTest.m
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

#import "CCControlButtonTest.h"

#import "CCControlButton.h"
#import "CCScale9Sprite.h"

@interface CCControlButtonTest_Event ()
@property (nonatomic, retain) CCLabelTTF *displayValueLabel;

@end

@implementation CCControlButtonTest_Event
@synthesize displayValueLabel;

- (void)dealloc
{
    [displayValueLabel release], displayValueLabel = nil;
    
    [super dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];

        // Add a label in which the button events will be displayed
		self.displayValueLabel = [CCLabelTTF labelWithString:@"No Event" fontName:@"Marker Felt" fontSize:32];
        displayValueLabel.anchorPoint = ccp(0.5f, -1);
        displayValueLabel.position = ccp(screenSize.width / 2.0f, screenSize.height / 2.0f);
		[self addChild:displayValueLabel];
        
        // Add the button
        CCScale9Sprite *backgroundButton = [CCScale9Sprite spriteWithFile:@"CCControlButton.png"];
        CCLabelTTF *titleButton = [CCLabelTTF labelWithString:@"Touch Me!" fontName:@"Helvetica" fontSize:30];
        [titleButton setColor:ccBLACK];
        
        CCControlButton *controlButton = [CCControlButton buttonWithLabel:titleButton
                                                         backgroundSprite:backgroundButton];
        controlButton.anchorPoint = ccp(0.5f, 1);
        controlButton.position = ccp(screenSize.width / 2.0f, screenSize.height / 2.0f);
        [self addChild:controlButton];

        // Sets up event handlers
        [controlButton addTarget:self action:@selector(touchDownAction:) forControlEvents:CCControlEventTouchDown];
        [controlButton addTarget:self action:@selector(touchDragInsideAction:) forControlEvents:CCControlEventTouchDragInside];
        [controlButton addTarget:self action:@selector(touchDragOutsideAction:) forControlEvents:CCControlEventTouchDragOutside];
        [controlButton addTarget:self action:@selector(touchDragEnterAction:) forControlEvents:CCControlEventTouchDragEnter];
        [controlButton addTarget:self action:@selector(touchDragExitAction:) forControlEvents:CCControlEventTouchDragExit];
        [controlButton addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:CCControlEventTouchUpInside];
        [controlButton addTarget:self action:@selector(touchUpOutsideAction:) forControlEvents:CCControlEventTouchUpOutside];
        [controlButton addTarget:self action:@selector(touchCancelAction:) forControlEvents:CCControlEventTouchCancel];
	}
	return self;
}

#pragma mark -
#pragma CCControlButtonTest_Event Public Methods

#pragma CCControlButtonTest_Event Private Methods

- (void)touchDownAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Touch Down"];
}

- (void)touchDragInsideAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Drag Inside"];
}

- (void)touchDragOutsideAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Drag Outside"];
}

- (void)touchDragEnterAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Drag Enter"];
}

- (void)touchDragExitAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Drag Exit"];
}

- (void)touchUpInsideAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Touch Up Inside."];
}

- (void)touchUpOutsideAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Touch Up Outside."];
}

- (void)touchCancelAction:(CCControlButton *)sender
{
    displayValueLabel.string = [NSString stringWithFormat:@"Touch Cancel"];
}

@end

@interface CCControlButtonTest_Styling ()

- (CCControlButton *)standardButtonWithTitle:(NSString *)title;

@end

@implementation CCControlButtonTest_Styling

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCNode *layer = [CCNode node];
        [self addChild:layer];
        
        NSInteger space = 10; // px
        
        double max_w = 0, max_h = 0;
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                // Add the buttons
                CCControlButton *button = [self standardButtonWithTitle:[NSString stringWithFormat:@"%d",arc4random() % 30]];
                button.backgroundSprite.preferedSize = CGSizeMake(45, 45);  // Set the prefered size
                button.adjustBackgroundImage = NO;  // Tells the button that the background image must not be adjust
                                                    // It'll use the prefered size of the background image
                button.position = ccp ((button.contentSize.width + space) * i, (button.contentSize.height + space) * j);
                [layer addChild:button];
                
                max_w = MAX((button.contentSize.width + space) * i, max_w);
                max_h = MAX((button.contentSize.height + space) * j, max_h);
            }
        }
        
        [layer setAnchorPoint:ccp (0.5, 0.5)];
        [layer setContentSize:CGSizeMake(max_w, max_h)];
        [layer setPosition:ccp(screenSize.width / 2.0f, screenSize.height / 2.0f)];
	}
	return self;
}

#pragma mark -
#pragma CCControlButtonTest_Styling Public Methods

#pragma CCControlButtonTest_Styling Private Methods

- (CCControlButton *)standardButtonWithTitle:(NSString *)title
{
    CCScale9Sprite *backgroundButton = [CCScale9Sprite spriteWithFile:@"CCControlButton.png"];
    CCLabelTTF *titleButton = [CCLabelTTF labelWithString:title fontName:@"Helvetica" fontSize:30];
    [titleButton setColor:ccBLACK];
    
    return [CCControlButton buttonWithLabel:titleButton backgroundSprite:backgroundButton];
}

@end
