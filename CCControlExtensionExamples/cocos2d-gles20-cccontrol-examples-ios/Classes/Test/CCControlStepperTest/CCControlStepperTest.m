/*
 * CCControlStepperTest.m
 *
 * Copyright (c) 2012 Yannick Loriot
 * http://yannickloriot.com
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

#import "CCControlStepperTest.h"

@interface CCControlStepperTest ()
@property (nonatomic, strong) CCLabelTTF *displayValueLabel;

/** Creates and returns a new ControlStepper. */
- (CCControlStepper *)makeControlStepper;

/** Callback for the change value. */
- (void)valueChanged:(CCControlStepper *)sender;

@end

@implementation CCControlStepperTest
@synthesize displayValueLabel;

- (void)dealloc
{
    [displayValueLabel  release];
    
    [super              dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        CGSize screenSize           = [[CCDirector sharedDirector] winSize];
        
        CCNode *layer               = [CCNode node];
        layer.position              = ccp (screenSize.width / 2, screenSize.height / 2);
        [self addChild:layer z:1];
        
        double layer_width          = 0;
        
        // Add the black background for the text
        CCScale9Sprite *background  = [CCScale9Sprite spriteWithFile:@"buttonBackground.png"];
        background.contentSize      = CGSizeMake(100, 50);
        background.position         = ccp(layer_width + background.contentSize.width / 2.0f, 0);
        [layer addChild:background];
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"0" fontName:@"HelveticaNeue-Bold" fontSize:30];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:30];
#endif
        displayValueLabel.position  = background.position;
        [layer addChild:displayValueLabel];
        
        layer_width                 += background.contentSize.width;
        
        CCControlStepper *stepper   = [self makeControlStepper];
        stepper.position            = ccp (layer_width + 10 + stepper.contentSize.width / 2, 0);
        [stepper addTarget:self action:@selector(valueChanged:) forControlEvents:CCControlEventValueChanged];
        [layer addChild:stepper];
        
        layer_width                 += stepper.contentSize.width;
        
        // Set the layer size
        layer.contentSize           = CGSizeMake(layer_width, 0);
        layer.anchorPoint           = ccp (0.5f, 0.5f);
        
        // Update the value label
        [self valueChanged:stepper];
    }
    return self;
}

#pragma mark -
#pragma mark CCControlStepperTest Public Methods

#pragma mark CCControlStepperTest Private Methods

- (CCControlStepper *)makeControlStepper
{
    CCSprite *minusSprite       = [CCSprite spriteWithFile:@"stepper-minus.png"];
    CCSprite *plusSprite        = [CCSprite spriteWithFile:@"stepper-plus.png"];
    
    return [CCControlStepper stepperWithMinusSprite:minusSprite plusSprite:plusSprite];
}

- (void)valueChanged:(CCControlStepper *)sender
{
    displayValueLabel.string    = [NSString stringWithFormat:@"%0.02f", sender.value];
}

@end
