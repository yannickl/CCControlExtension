/*
 * CCControlPotentiometerTest.m
 *
 * Copyright (c) 2012 Yannick Loriot
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

#import "CCControlPotentiometerTest.h"

@interface CCControlPotentiometerTest ()
@property (nonatomic, strong) CCLabelTTF                *displayValueLabel;
@property (nonatomic, strong) CCControlPotentiometer    *potentiometer;

- (void)valueChanged:(CCControlPotentiometer *)sender;

@end

@implementation CCControlPotentiometerTest
@synthesize displayValueLabel;
@synthesize potentiometer;

- (void)dealloc
{
    [displayValueLabel  release];
    [potentiometer      release];
    
    [super              dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCNode *layer               = [CCNode node];
        layer.position              = ccp (screenSize.width / 2, screenSize.height / 2);
        [self addChild:layer z:1];
        
        double layer_width = 0;
        
        // Add the black background for the text
        CCScale9Sprite *background  = [CCScale9Sprite spriteWithFile:@"buttonBackground.png"];
        [background setContentSize:CGSizeMake(80, 50)];
        [background setPosition:ccp(layer_width + background.contentSize.width / 2.0f, 0)];
        [layer addChild:background];
        
        layer_width                 += background.contentSize.width;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-Bold" fontSize:30];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:30];
#endif
        displayValueLabel.position  = background.position;
        [layer addChild:displayValueLabel];
		
        // Add the slider
		self.potentiometer          = [CCControlPotentiometer potentiometerWithTrackFile:@"potentiometerTrack.png"
                                                                            progressFile:@"potentiometerProgress.png"
                                                                               thumbFile:@"potentiometerButton.png"];
        potentiometer.position      = ccp (layer_width + 10 + potentiometer.contentSize.width / 2, 0);
        potentiometer.value         = 0.0f;
        
        // When the value of the slider will change, the given selector will be call
		[potentiometer addTarget:self action:@selector(valueChanged:) forControlEvents:CCControlEventValueChanged];
        
		[layer addChild:potentiometer];
        
        layer_width                 += potentiometer.contentSize.width;
        
        // Set the layer size
        layer.contentSize           = CGSizeMake(layer_width, 0);
        layer.anchorPoint           = ccp (0.5f, 0.5f);
	}
	return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [potentiometer setValue:0.25f animated:YES];
}

#pragma mark -
#pragma CCSliderTestLayer Public Methods
     
#pragma CCSliderTestLayer Private Methods
     
     - (void)valueChanged:(CCControlPotentiometer *)sender
    {
        // Change value of label.
        displayValueLabel.string = [NSString stringWithFormat:@"%.02f", sender.value];
    }
     
     @end
