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
#import "ARCMacro.h"

#pragma mark -
#pragma mark - Utils

@interface Utils : NSObject

+ (CCSprite*)addSprite:(NSString *)spriteName toTarget:(id)target withPos:(CGPoint)pos andAnchor:(CGPoint)anchor;

@end

@implementation Utils

+ (CCSprite *)addSprite:(NSString *)spriteName toTarget:(CCNode *)target withPos:(CGPoint)pos andAnchor:(CGPoint)anchor
{
	CCSprite *sprite	= [CCSprite spriteWithSpriteFrameName:spriteName];
    
    // check the sprite exists
    BOOL responds		= [sprite respondsToSelector:@selector(setPosition:)];
    
    if (responds == NO)	return nil;
    
	sprite.anchorPoint	= anchor;
	sprite.position		= pos;
	[target addChild:sprite];
	
	return sprite;
}

@end

#pragma mark -
#pragma mark - CCControlHuePicker Interface

@interface CCControlHuePicker : CCControl
{
@public
    CGFloat     hue_;
    CGFloat     huePercentage_;     // The percentage of the dragger position on the slider
    
@protected
    CCSprite    *background_;
    CCSprite    *slider_;
    CGPoint     startPos_;
}
/** Contains the receiver’s current hue value (between 0 and 360 degree). */
@property (nonatomic, assign) CGFloat   hue;
/** Contains the receiver’s current hue value (between 0 and 1). */
@property (nonatomic, assign) CGFloat   huePercentage;
@property (nonatomic, strong) CCSprite  *background;
@property (nonatomic, strong) CCSprite  *slider;
@property (nonatomic, assign) CGPoint   startPos;

- (id)initWithTarget:(id)target withPos:(CGPoint)pos;
- (void)updateSliderPosition:(CGPoint)location;
- (BOOL)checkSliderPosition:(CGPoint)location;

@end

#pragma mark -
#pragma mark - CCControlSaturationBrightnessPicker Inteface

@interface CCControlSaturationBrightnessPicker : CCControl
{
@public
    CGFloat     saturation_, brightness_;
    
@protected
    CCSprite    *background;
    CCSprite    *overlay;
    CCSprite    *shadow;
    CCSprite    *slider;
    CGPoint     startPos;
    
    int         boxPos;
    int         boxSize;
}
/** Contains the receiver’s current saturation value. */
@property (nonatomic, assign) CGFloat saturation;
/** Contains the receiver’s current brightness value. */
@property (nonatomic, assign) CGFloat brightness;

- (id)initWithTarget:(id)target withPos:(CGPoint)pos;
- (void)updateWithHSV:(HSV)hsv;
- (void)updateDraggerWithHSV:(HSV)hsv;
- (void)updateSliderPosition:(CGPoint)sliderPosition;
- (BOOL)checkSliderPosition:(CGPoint)location;

@end

#pragma mark -
#pragma mark - CCControlColourPicker Implementation

@interface CCControlColourPicker ()
@property (nonatomic, assign) HSV                                   hsv;
@property (nonatomic, strong) CCSprite                              *background;
@property (nonatomic, strong) CCControlSaturationBrightnessPicker   *colourPicker;
@property (nonatomic, strong) CCControlHuePicker                    *huePicker;

- (void)updateControlPicker;
- (void)updateHueAndControlPicker;

@end

@implementation CCControlColourPicker
@synthesize hsv             = hsv_;
@synthesize background      = background_;
@synthesize colourPicker    = colourPicker_;
@synthesize huePicker       = huePicker_;

- (void)dealloc
{    
    [background_    removeFromParentAndCleanup:YES];
    [huePicker_     removeFromParentAndCleanup:YES];
    [colourPicker_  removeFromParentAndCleanup:YES];

    background_     = nil;
    huePicker_      = nil;
    colourPicker_   = nil;
    
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
        ccTexParams params              = {GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [spriteSheet.texture setAliasTexParameters];
        [spriteSheet.texture setTexParameters:&params];
        [spriteSheet.texture generateMipmap];
        
        // Init default color
        hsv_.h                          = 0;
        hsv_.s                          = 0;
        hsv_.v                          = 0;
        
        // Add image
        background_                     = [Utils addSprite:@"menuColourPanelBackground.png" 
                                                  toTarget:spriteSheet 
                                                   withPos:CGPointZero andAnchor:ccp(0.5f, 0.5f)];
        CGPoint backgroundPointZero     = ccpSub(background_.position, ccp (background_.contentSize.width / 2, 
                                                                            background_.contentSize.height / 2));
        
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
        
        huePicker_                      = [[CCControlHuePicker alloc] initWithTarget:spriteSheet 
                                                                             withPos:ccp(backgroundPointZero.x + hueShift, 
                                                                                         backgroundPointZero.y + hueShift)];
        colourPicker_                   = [[CCControlSaturationBrightnessPicker alloc] initWithTarget:spriteSheet 
                                                                          withPos:ccp(backgroundPointZero.x + colourShift, 
                                                                                      backgroundPointZero.y + colourShift)];
        
        // Setup events
		[huePicker_ addTarget:self action:@selector(hueSliderValueChanged:) forControlEvents:CCControlEventValueChanged];
		[colourPicker_ addTarget:self action:@selector(colourSliderValueChanged:) forControlEvents:CCControlEventValueChanged];
        
        // Set defaults
        [self updateHueAndControlPicker];
        
        [self addChild:huePicker_];
        [self addChild:colourPicker_];
        
        // Set content size
        [self setContentSize:[background_ contentSize]];
	}
	return self;
}

+ (id)colorPicker
{
    return SAFE_ARC_AUTORELEASE([[self alloc] init]);
}

- (void)setColor:(ccColor3B)color
{
    color_      = color;
    
    RGBA rgba;
    rgba.r      = color.r / 255.0f;
    rgba.g      = color.g / 255.0f;
    rgba.b      = color.b / 255.0f;
    rgba.a      = 1.0f;
    
    hsv_        = [CCColourUtils HSVfromRGB:rgba];

    [self updateHueAndControlPicker];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    huePicker_.enabled      = enabled;
    colourPicker_.enabled   = enabled;
}

#pragma mark CCControlColourPicker Public Methods
#pragma mark CCControlColourPicker Private Methods

- (void)updateControlPicker
{
    [huePicker_     setHue:hsv_.h];
    [colourPicker_  updateWithHSV:hsv_];
}

- (void)updateHueAndControlPicker
{
    [huePicker_     setHue:hsv_.h];
    [colourPicker_  updateWithHSV:hsv_];
    [colourPicker_  updateDraggerWithHSV:hsv_];
}

#pragma mark Callback Methods

- (void)hueSliderValueChanged:(CCControlHuePicker *)sender
{
    hsv_.h      = sender.hue;

    // Update the value
    RGBA rgb    = [CCColourUtils RGBfromHSV:hsv_];
    color_      = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
    
	// Send CCControl callback
	[self sendActionsForControlEvents:CCControlEventValueChanged];
    [self updateControlPicker];
}

- (void)colourSliderValueChanged:(CCControlSaturationBrightnessPicker *)sender
{
    hsv_.s      = sender.saturation;
    hsv_.v      = sender.brightness;

    // Update the value
    RGBA rgb    = [CCColourUtils RGBfromHSV:hsv_];
    color_      = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
    
	// Send CCControl callback
	[self sendActionsForControlEvents:CCControlEventValueChanged];
}

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

#pragma mark -
#pragma mark - CCControlHuePicker Implementation

@implementation CCControlHuePicker
@synthesize background      = background_;
@synthesize slider          = slider_;
@synthesize startPos        = startPos_;
@synthesize hue             = hue_;
@synthesize huePercentage   = huePercentage_;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    SAFE_ARC_RELEASE(background_);
    SAFE_ARC_RELEASE(slider_);
    
	SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithTarget:(id)target withPos:(CGPoint)pos
{
    if ((self = [super init]))
    {
        // Add background and slider sprites
        self.background     = [Utils addSprite:@"huePickerBackground.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        self.slider         = [Utils addSprite:@"colourPicker.png" toTarget:target withPos:pos andAnchor:ccp(0.5f, 0.5f)];
        
        slider_.position    = ccp(pos.x, pos.y + background_.boundingBox.size.height * 0.5f);
        
        startPos_           = pos;
        
        // Sets the default value
        hue_                = 0.0f;
        huePercentage_      = 0.0f;
    }
    return self;
}

- (void)setHue:(CGFloat)hueValue
{
    hue_                    = hueValue;
    
    // Set the position of the slider to the correct hue
    // We need to divide it by 360 as its taken as an angle in degrees
    float huePercentage     = hueValue / 360.0f;
    
    // update
    [self setHuePercentage:huePercentage];
}

- (void)setHuePercentage:(CGFloat)hueValueInPercent_
{
    huePercentage_          = hueValueInPercent_;
    hue_                    = hueValueInPercent_ * 360.0f;
    
    // Clamp the position of the icon within the circle
    CGRect backgroundBox    = background_.boundingBox;
    
    // Get the center point of the background image
    float centerX           = startPos_.x + backgroundBox.size.width * 0.5f;
    float centerY           = startPos_.y + backgroundBox.size.height * 0.5f;
    
    // Work out the limit to the distance of the picker when moving around the hue bar
    float limit             = backgroundBox.size.width * 0.5f - 15.0f;
    
    // Update angle
    float angleDeg          = huePercentage_ * 360.0f - 180.0f;
    float angle             = CC_DEGREES_TO_RADIANS(angleDeg);
    
    // Set new position of the slider
    float x                 = centerX + limit * cosf(angle);
    float y                 = centerY + limit * sinf(angle);
    slider_.position        = ccp(x, y);
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    slider_.opacity = enabled ? 255.0f : 128.0f;
}

#pragma mark CCControlHuePicker Public Methods
#pragma mark CCControlHuePicker Private Methods

- (void)updateSliderPosition:(CGPoint)location
{
    // Clamp the position of the icon within the circle
    CGRect backgroundBox    = background_.boundingBox;
    
    // get the center point of the background image
    float centerX           = startPos_.x + backgroundBox.size.width * 0.5f;
    float centerY           = startPos_.y + backgroundBox.size.height * 0.5f;
    
    // Work out the distance difference between the location and center
    float dx                = location.x - centerX;
    float dy                = location.y - centerY;
    
    // Update angle by using the direction of the location
    float angle             = atan2f(dy, dx);
    float angleDeg          = CC_RADIANS_TO_DEGREES(angle) + 180.0f;
    
    // Use the position / slider width to determin the percentage the dragger is at
    self.hue                = angleDeg;
    
	// Send CCControl callback
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

- (BOOL)checkSliderPosition:(CGPoint)location
{
    // Compute the distance between the current location and the center
    double distance = sqrt(pow (location.x + 10, 2) + pow(location.y, 2));
    
    // Check that the touch location is within the bounding rectangle before sending updates
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (78 > distance && distance > 56))
        || (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && (160 > distance && distance > 118)))
#else
        if (160 > distance && distance > 118)
#endif
        {
            [self updateSliderPosition:location];
            
            return YES;
        }
    return NO;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.isEnabled)
    {
        return NO;
    }
    
    // Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:touchLocation];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    // Check the touch position on the slider
    [self checkSliderPosition:touchLocation];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
    {
        return NO;
    }
    
    // Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
    // Check the touch position on the slider
    self.selected           = [self checkSliderPosition:eventLocation];
    
    return [self isSelected];
}


- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self isSelected])
    {
        return NO;
    }
    
	// Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:eventLocation];
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    self.selected = NO;
    return NO;
}

#endif

@end

#pragma mark -
#pragma mark - CCControlSaturationBrightnessPicker Implementation

@implementation CCControlSaturationBrightnessPicker
@synthesize saturation  = saturation_;
@synthesize brightness  = brightness_;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    background  = nil;
    overlay     = nil;
    shadow      = nil;
    slider      = nil;
    
	SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithTarget:(id)target withPos:(CGPoint)pos
{
    if ((self = [super init]))
    {
		// Add sprites
        background      = [Utils addSprite:@"colourPickerBackground.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        overlay         = [Utils addSprite:@"colourPickerOverlay.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        shadow          = [Utils addSprite:@"colourPickerShadow.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        slider          = [Utils addSprite:@"colourPicker.png" toTarget:target withPos:pos andAnchor:ccp(0.5f, 0.5f)];
        
        startPos        = pos;                              // starting position of the colour picker
        boxPos          = 35;                               // starting position of the virtual box area for picking a colour
        boxSize         = background.contentSize.width / 2; // the size (width and height) of the virtual box for picking a colour from
    }
    return self;
}

#pragma mark CCControlPicker Public Methods

- (void)updateWithHSV:(HSV)hsv
{
    HSV hsvTemp;
    hsvTemp.s = 1;
    hsvTemp.h = hsv.h;
    hsvTemp.v = 1;
    
    RGBA rgb    = [CCColourUtils RGBfromHSV:hsvTemp];
    
    [background setColor:ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f)];
}

- (void)updateDraggerWithHSV:(HSV)hsv
{
    // Set the position of the slider to the correct saturation and brightness
    CGPoint pos	= CGPointMake(
                              startPos.x + boxPos + (boxSize*(1 - hsv.s)),
                              startPos.y + boxPos + (boxSize*hsv.v));
    
    // update
    [self updateSliderPosition:pos];
}

#pragma mark CCControlPicker Private Methods

- (void)updateSliderPosition:(CGPoint)sliderPosition
{
    // Clamp the position of the icon within the circle
    
    // Get the center point of the bkgd image
    float centerX           = startPos.x + background.boundingBox.size.width*.5;
    float centerY           = startPos.y + background.boundingBox.size.height*.5;
    
    // Work out the distance difference between the location and center
    float dx                = sliderPosition.x - centerX;
    float dy                = sliderPosition.y - centerY;
    float dist              = sqrtf(dx * dx + dy * dy);
    
    // Update angle by using the direction of the location
    float angle             = atan2f(dy, dx);
    
    // Set the limit to the slider movement within the colour picker
    float limit             = background.boundingBox.size.width*.5;
    
    // Check distance doesn't exceed the bounds of the circle
    if (dist > limit)
    {
        sliderPosition.x    = centerX + limit * cosf(angle);
        sliderPosition.y    = centerY + limit * sinf(angle);
    }
    
    // Set the position of the dragger
    slider.position         = sliderPosition;
    
    
    // Clamp the position within the virtual box for colour selection
    if (sliderPosition.x < startPos.x + boxPos)						sliderPosition.x = startPos.x + boxPos;
    else if (sliderPosition.x > startPos.x + boxPos + boxSize - 1)	sliderPosition.x = startPos.x + boxPos + boxSize - 1;
    if (sliderPosition.y < startPos.y + boxPos)						sliderPosition.y = startPos.y + boxPos;
    else if (sliderPosition.y > startPos.y + boxPos + boxSize)		sliderPosition.y = startPos.y + boxPos + boxSize;
    
    // Use the position / slider width to determin the percentage the dragger is at
    self.saturation         = 1 - ABS((startPos.x + boxPos - sliderPosition.x)/boxSize);
    self.brightness         = ABS((startPos.y + boxPos - sliderPosition.y)/boxSize);
}

-(BOOL)checkSliderPosition:(CGPoint)location
{
    // Clamp the position of the icon within the circle
    
    // get the center point of the bkgd image
    float centerX           = startPos.x + background.boundingBox.size.width*.5;
    float centerY           = startPos.y + background.boundingBox.size.height*.5;
    
    // work out the distance difference between the location and center
    float dx                = location.x - centerX;
    float dy                = location.y - centerY;
    float dist              = sqrtf(dx*dx+dy*dy);
    
    // check that the touch location is within the bounding rectangle before sending updates
	if (dist <= background.boundingBox.size.width * 0.5f)
    {
        [self updateSliderPosition:location];
        
        // send CCControl callback
        [self sendActionsForControlEvents:CCControlEventValueChanged];
        
        return YES;
    }
    return NO;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    slider.opacity = enabled ? 255.0f : 128.0f;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
    {
        return NO;
    }
    
	// Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    // check the touch position on the slider
	return [self checkSliderPosition:touchLocation];
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    // check the touch position on the slider
	[self checkSliderPosition:touchLocation];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
    {
        return NO;
    }
    
    // Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
    // Check the touch position on the slider
    self.selected           = [self checkSliderPosition:eventLocation];
    
    return [self isSelected];
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (!self.isEnabled
        || ![self isSelected])
    {
        return NO;
    }
    
	// Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:eventLocation];
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    self.selected = NO;
    return NO;
}

#endif

@end