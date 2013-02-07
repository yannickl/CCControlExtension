/*
 * CCControlColourPicker.m
 *
 * Copyright 2012 Stewart Hamilton-Arrandale.
 * http://creativewax.co.uk
 *
 * Modified by Yannick Loriot.
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

#import "CCControlColourPicker.h"

#import "CCControlSaturationBrightnessPicker.h"
#import "CCControlHuePicker.h"
#import "Utils.h"
#import "ARCMacro.h"

@interface CCControlColourPicker ()
@property (nonatomic, assign) HSV                                   hsv;
@property (nonatomic, strong) CCSprite                              *background;
@property (nonatomic, strong) CCControlSaturationBrightnessPicker   *colourPicker;
@property (nonatomic, strong) CCControlHuePicker                    *huePicker;

- (void)updateControlPicker;
- (void)updateHueAndControlPicker;

@end

@implementation CCControlColourPicker
@synthesize hsv             = _hsv;
@synthesize background      = _background;
@synthesize colourPicker    = _colourPicker;
@synthesize huePicker       = _huePicker;

- (void)dealloc
{    
    [_background    removeFromParentAndCleanup:YES];
    [_huePicker     removeFromParentAndCleanup:YES];
    [_colourPicker  removeFromParentAndCleanup:YES];

    _background     = nil;
    _huePicker      = nil;
    _colourPicker   = nil;
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)init
{
	if ((self = [super init]))
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        // Cache the sprites
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CCControlColourPickerSpriteSheet.plist"];
		
        // Create the sprite batch node
        CCSpriteBatchNode *spriteSheet  = [CCSpriteBatchNode batchNodeWithFile:@"CCControlColourPickerSpriteSheet.png"];
        [self addChild:spriteSheet];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        // Cache the sprites
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CCControlColourPickerSpriteSheet-hd.plist"];
		
        // Create the sprite batch node
        CCSpriteBatchNode *spriteSheet  = [CCSpriteBatchNode batchNodeWithFile:@"CCControlColourPickerSpriteSheet-hd.png"];
        [self addChild:spriteSheet];
#endif
        
        // MIPMAP
        //ccTexParams params              = {GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [spriteSheet.texture setAliasTexParameters];
        //[spriteSheet.texture setTexParameters:&params];
        //[spriteSheet.texture generateMipmap];
        
        // Init default color
        _hsv.h                          = 0;
        _hsv.s                          = 0;
        _hsv.v                          = 0;
        
        // Add image
        _background                     = [Utils addSprite:@"menuColourPanelBackground.png" 
                                                  toTarget:spriteSheet 
                                                   withPos:CGPointZero andAnchor:ccp(0.5f, 0.5f)];
        CGPoint backgroundPointZero     = ccpSub(_background.position, ccp (_background.contentSize.width / 2, 
                                                                            _background.contentSize.height / 2));
        
        // Setup panels
        CGFloat hueShift                = 16;
        CGFloat colourShift             = 56;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            hueShift                    = 8;
            colourShift                 = 28;
        }
#endif
        
        _huePicker                      = [[CCControlHuePicker alloc] initWithTarget:spriteSheet 
                                                                             withPos:ccp(backgroundPointZero.x + hueShift, 
                                                                                         backgroundPointZero.y + hueShift)];
        _colourPicker                   = [[CCControlSaturationBrightnessPicker alloc] initWithTarget:spriteSheet
                                                                          withPos:ccp(backgroundPointZero.x + colourShift, 
                                                                                      backgroundPointZero.y + colourShift)];
        
        // Setup events
		[_huePicker addTarget:self action:@selector(hueSliderValueChanged:) forControlEvents:CCControlEventValueChanged];
		[_colourPicker addTarget:self action:@selector(colourSliderValueChanged:) forControlEvents:CCControlEventValueChanged];
        
        // Set defaults
        [self updateHueAndControlPicker];
        
        [self addChild:_huePicker];
        [self addChild:_colourPicker];
        
        // Set content size
        [self setContentSize:[_background contentSize]];
	}
	return self;
}

+ (id)colorPicker
{
    return SAFE_ARC_AUTORELEASE([[self alloc] init]);
}

- (void)setColor:(ccColor3B)color
{
    _color      = color;
    
    RGBA rgba;
    rgba.r      = color.r / 255.0f;
    rgba.g      = color.g / 255.0f;
    rgba.b      = color.b / 255.0f;
    rgba.a      = 1.0f;
    
    _hsv        = [CCColourUtils HSVfromRGB:rgba];

    [self updateHueAndControlPicker];
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled           = enabled;
    
    _huePicker.enabled      = enabled;
    _colourPicker.enabled   = enabled;
}

#pragma mark -
#pragma mark CCControlColourPicker Public Methods

#pragma mark CCControlColourPicker Private Methods

- (void)updateControlPicker
{
    [_huePicker setHue:_hsv.h];
    [_colourPicker updateWithHSV:_hsv];
}

- (void)updateHueAndControlPicker
{
    [_huePicker setHue:_hsv.h];
    [_colourPicker updateWithHSV:_hsv];
    [_colourPicker updateDraggerWithHSV:_hsv];
}

#pragma mark - Callback Methods

- (void)hueSliderValueChanged:(CCControlHuePicker *)sender
{
    _hsv.h      = sender.hue;

    // Update the value
    RGBA rgb    = [CCColourUtils RGBfromHSV:_hsv];
    _color      = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
    
	// Send CCControl callback
	[self sendActionsForControlEvents:CCControlEventValueChanged];
    [self updateControlPicker];
}

- (void)colourSliderValueChanged:(CCControlSaturationBrightnessPicker *)sender
{
    _hsv.s      = sender.saturation;
    _hsv.v      = sender.brightness;

    // Update the value
    RGBA rgb    = [CCColourUtils RGBfromHSV:_hsv];
    _color      = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
    
    // Send CCControl callback
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return NO;
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    return NO;
}

#endif

@end
