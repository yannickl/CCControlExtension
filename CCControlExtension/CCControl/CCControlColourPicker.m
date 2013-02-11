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

#import "Utils.h"
#import "ARCMacro.h"

#pragma mark -
#pragma mark - CCControlHuePicker Interface

@interface CCControlHuePicker : CCControl
{
@public
    CGFloat     _hue;
    CGFloat     _huePercentage;     // The percentage of the dragger position on the slider
    
@protected
    CCSprite    *_background;
    CCSprite    *_slider;
    CGPoint     _startPos;
}
/** Contains the receiver’s current hue value (between 0 and 360 degree). */
@property (nonatomic, assign) CGFloat   hue;
/** Contains the receiver’s current hue value (between 0 and 1). */
@property (nonatomic, assign) CGFloat   huePercentage;
@property (nonatomic, strong) CCSprite    *background;
@property (nonatomic, strong) CCSprite    *slider;
@property (nonatomic, assign) CGPoint     startPos;

#pragma mark Constuctors - Initializers

- (id)initWithTarget:(id)target withPos:(CGPoint)pos;

#pragma mark Public Methods

- (void)updateSliderPosition:(CGPoint)location;
- (BOOL)checkSliderPosition:(CGPoint)location;

@end

#pragma mark -
#pragma mark - CCControlSaturationBrightnessPicker Interface

@interface CCControlSaturationBrightnessPicker : CCControl
{
@public
    CGFloat     _saturation, _brightness;
    
@protected
    CCSprite    *_background;
    CCSprite    *_overlay;
    CCSprite    *_shadow;
    CCSprite    *_slider;
    CGPoint     _startPos;
    
    int         _boxPos;
    int         _boxSize;
}
/** Contains the receiver’s current saturation value. */
@property (nonatomic, assign) CGFloat saturation;
/** Contains the receiver’s current brightness value. */
@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, assign) CCSprite    *background;
@property (nonatomic, assign) CCSprite    *overlay;
@property (nonatomic, assign) CCSprite    *shadow;
@property (nonatomic, assign) CCSprite    *slider;

#pragma mark Constuctors - Initializers

- (id)initWithTarget:(id)target withPos:(CGPoint)pos;

#pragma mark Public Methods

- (void)updateWithHSV:(HSV)hsv;
- (void)updateDraggerWithHSV:(HSV)hsv;
- (void)updateSliderPosition:(CGPoint)sliderPosition;
- (BOOL)checkSliderPosition:(CGPoint)location;

@end

#pragma mark -
#pragma mark - CCControlColourPicker

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
        [spriteSheet.texture setAliasTexParameters];
        
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

#pragma mark Callback Methods

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

#pragma mark -
#pragma mark - CCControlHuePicker Implementation

@implementation CCControlHuePicker
@synthesize background      = _background;
@synthesize slider          = _slider;
@synthesize startPos        = _startPos;
@synthesize hue             = _hue;
@synthesize huePercentage   = _huePercentage;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    SAFE_ARC_RELEASE(_background);
    SAFE_ARC_RELEASE(_slider);
    
	SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithTarget:(id)target withPos:(CGPoint)pos
{
    if ((self = [super init]))
    {
        // Add background and slider sprites
        self.background     = [Utils addSprite:@"huePickerBackground.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        self.slider         = [Utils addSprite:@"colourPicker.png" toTarget:target withPos:pos andAnchor:ccp(0.5f, 0.5f)];
        
        _slider.position    = ccp(pos.x, pos.y + _background.boundingBox.size.height * 0.5f);
        
        _startPos           = pos;
        
        // Sets the default value
        _hue                = 0.0f;
        _huePercentage      = 0.0f;
    }
    return self;
}

- (void)setHue:(CGFloat)hueValue
{
    _hue                = hueValue;
    
    // Set the position of the slider to the correct hue
    // We need to divide it by 360 as its taken as an angle in degrees
    float huePercentage	= hueValue / 360.0f;
    
    // update
    [self setHuePercentage:huePercentage];
}

- (void)setHuePercentage:(CGFloat)hueValueInPercent_
{
    _huePercentage          = hueValueInPercent_;
    _hue                    = hueValueInPercent_ * 360.0f;
    
    // Clamp the position of the icon within the circle
    CGRect backgroundBox    = _background.boundingBox;
    
    // Get the center point of the background image
    float centerX           = _startPos.x + backgroundBox.size.width * 0.5f;
    float centerY           = _startPos.y + backgroundBox.size.height * 0.5f;
    
    // Work out the limit to the distance of the picker when moving around the hue bar
    float limit             = backgroundBox.size.width * 0.5f - 15.0f;
    
    // Update angle
    float angleDeg          = _huePercentage * 360.0f - 180.0f;
    float angle             = CC_DEGREES_TO_RADIANS(angleDeg);
    
    // Set new position of the slider
    float x                 = centerX + limit * cosf(angle);
    float y                 = centerY + limit * sinf(angle);
    _slider.position        = ccp(x, y);
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled   = enabled;
    
    _slider.opacity = enabled ? 255.0f : 128.0f;
}

#pragma mark CCControlHuePicker Public Methods
#pragma mark CCControlHuePicker Private Methods

- (void)updateSliderPosition:(CGPoint)location
{
    // Clamp the position of the icon within the circle
    CGRect backgroundBox    = _background.boundingBox;
    
    // get the center point of the background image
    float centerX           = _startPos.x + backgroundBox.size.width * 0.5f;
    float centerY           = _startPos.y + backgroundBox.size.height * 0.5f;
    
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
    
    // Check that the touch location is within the circle
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
    if (![self isEnabled])
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
    if (![self isEnabled])
    {
        return NO;
    }
    
    // Get the event location
    CGPoint eventLocation   = [self eventLocation:event];
    
    // Check the touch position on the slider
    return [self checkSliderPosition:eventLocation];
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (![self isEnabled])
    {
        return NO;
    }
    
	// Get the event location
    CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:eventLocation];
}

#endif

@end

#pragma mark -
#pragma mark - CCControlSaturationBrightnessPicker Implementation

@implementation CCControlSaturationBrightnessPicker
@synthesize background  = _background;
@synthesize overlay     = _overlay;
@synthesize shadow      = _shadow;
@synthesize slider      = _slider;

@synthesize saturation  = _saturation;
@synthesize brightness  = _brightness;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    _background = nil;
    _overlay    = nil;
    _shadow     = nil;
    _slider     = nil;
    
	SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithTarget:(id)target withPos:(CGPoint)pos
{
    if ((self = [super init]))
    {
        // Add sprites
        _background     = [Utils addSprite:@"colourPickerBackground.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        _overlay        = [Utils addSprite:@"colourPickerOverlay.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        _shadow         = [Utils addSprite:@"colourPickerShadow.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        _slider         = [Utils addSprite:@"colourPicker.png" toTarget:target withPos:pos andAnchor:ccp(0.5f, 0.5f)];
        
        _startPos        = pos;                                  // starting position of the colour picker
        _boxPos         = 35;                                   // starting position of the virtual box area for picking a colour
        _boxSize        = _background.contentSize.width / 2;    // the size (width and height) of the virtual box for picking a colour from
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled   = enabled;
    
    _slider.opacity = enabled ? 255.0f : 128.0f;
}

#pragma mark CCControlPicker Public Methods

- (void)updateWithHSV:(HSV)hsv
{
    HSV hsvTemp;
    hsvTemp.s           = 1;
    hsvTemp.h           = hsv.h;
    hsvTemp.v           = 1;
    
    RGBA rgb            = [CCColourUtils RGBfromHSV:hsvTemp];
    
    _background.color   = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
}

- (void)updateDraggerWithHSV:(HSV)hsv
{
    // Set the position of the slider to the correct saturation and brightness
    CGPoint pos	= CGPointMake(
                              _startPos.x + _boxPos + (_boxSize*(1 - hsv.s)),
                              _startPos.y + _boxPos + (_boxSize*hsv.v));
    
    // update
    [self updateSliderPosition:pos];
}

#pragma mark CCControlPicker Private Methods

- (void)updateSliderPosition:(CGPoint)sliderPosition
{
    // Clamp the position of the icon within the circle
    
    // Get the center point of the bkgd image
    float centerX           = _startPos.x + _background.boundingBox.size.width * 0.5f;
    float centerY           = _startPos.y + _background.boundingBox.size.height * 0.5f;
    
    // Work out the distance difference between the location and center
    float dx                = sliderPosition.x - centerX;
    float dy                = sliderPosition.y - centerY;
    float dist              = sqrtf(dx * dx + dy * dy);
    
    // Update angle by using the direction of the location
    float angle             = atan2f(dy, dx);
    
    // Set the limit to the slider movement within the colour picker
    float limit             = _background.boundingBox.size.width * 0.5f;
    
    // Check distance doesn't exceed the bounds of the circle
    if (dist > limit)
    {
        sliderPosition.x    = centerX + limit * cosf(angle);
        sliderPosition.y    = centerY + limit * sinf(angle);
    }
    
    // Set the position of the dragger
    _slider.position        = sliderPosition;
    
    
    // Clamp the position within the virtual box for colour selection
    if (sliderPosition.x < _startPos.x + _boxPos)						sliderPosition.x = _startPos.x + _boxPos;
    else if (sliderPosition.x > _startPos.x + _boxPos + _boxSize - 1)	sliderPosition.x = _startPos.x + _boxPos + _boxSize - 1;
    if (sliderPosition.y < _startPos.y + _boxPos)						sliderPosition.y = _startPos.y + _boxPos;
    else if (sliderPosition.y > _startPos.y + _boxPos + _boxSize)		sliderPosition.y = _startPos.y + _boxPos + _boxSize;
    
    // Use the position / slider width to determin the percentage the dragger is at
    self.saturation         = 1 - ABS((_startPos.x + _boxPos - sliderPosition.x)/_boxSize);
    self.brightness         = ABS((_startPos.y + _boxPos - sliderPosition.y)/_boxSize);
}

-(BOOL)checkSliderPosition:(CGPoint)location
{
    // Clamp the position of the icon within the circle
    
    // get the center point of the bkgd image
    float centerX           = _startPos.x + _background.boundingBox.size.width * 0.5f;
    float centerY           = _startPos.y + _background.boundingBox.size.height * 0.5f;
    
    // work out the distance difference between the location and center
    float dx                = location.x - centerX;
    float dy                = location.y - centerY;
    float dist              = sqrtf(dx*dx + dy*dy);
    
    // check that the touch location is within the bounding rectangle before sending updates
    if (dist <= _background.boundingBox.size.width * 0.5f)
    {
        [self updateSliderPosition:location];
        
        // send CCControl callback
        [self sendActionsForControlEvents:CCControlEventValueChanged];
        
        return YES;
    }
    return NO;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isEnabled])
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
    if (![self isEnabled])
    {
        return NO;
    }
    
    // Get the event location
    CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:eventLocation];
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (![self isEnabled])
    {
        return NO;
    }
    
    // Get the event location
    CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:eventLocation];
}

#endif

@end