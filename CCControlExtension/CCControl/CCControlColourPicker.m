/*
 * CCControlColourPicker.m
 *
 * Copyright 2012 Stewart Hamilton-Arrandale.
 * http://creativewax.co.uk
 *
 * Modified in 2012/2013 by Yannick Loriot.
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
#pragma mark - CCControlHuePicker Interface

@interface CCControlHuePicker : CCControl
{
@public
    CGFloat     hue_;
    CGFloat     huePercentage_;     // The percentage of the dragger position on the picker
    
@protected
    CCSprite    *background_;
    CCSprite    *picker_;
    double      length_;
}
/** Contains the receiver’s current hue value (between 0 and 360 degree). */
@property (nonatomic, assign) CGFloat   hue;
/** Contains the receiver’s current hue value (between 0 and 1). */
@property (nonatomic, assign) CGFloat   huePercentage;
@property (nonatomic, strong) CCSprite  *background;
@property (nonatomic, strong) CCSprite  *picker;
@property (nonatomic, assign) double    length;

- (id)initWithBackgroundFile:(NSString *)backgroundFile pickerFile:(NSString *)pickerFile disableZoneLength:(double)length;
- (void)updatePickerPosition:(CGPoint)location;
- (BOOL)checkPickerPosition:(CGPoint)location;

@end

#pragma mark -
#pragma mark - CCControlSaturationBrightnessPicker Inteface

@interface CCControlSaturationBrightnessPicker : CCControl
{
@public
    CGFloat     saturation_, brightness_;
    
@protected
    CCSprite    *background_;
    CCSprite    *picker_;
}
/** Contains the receiver’s current saturation value. */
@property (nonatomic, assign) CGFloat saturation;
/** Contains the receiver’s current brightness value. */
@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, assign) CCSprite    *background;
@property (nonatomic, assign) CCSprite    *picker;

- (id)initWithBackgroundFile:(NSString *)backgroundFile overlayFile:(NSString *)overlayFile pickerFile:(NSString *)pickerFile;
- (void)updateWithHSV:(HSV)hsv;
- (void)updateDraggerWithHSV:(HSV)hsv;
- (void)updatePickerPosition:(CGPoint)pickerPosition;
- (BOOL)checkPickerPosition:(CGPoint)location;

@end

#pragma mark -
#pragma mark - CCControlColourPicker Implementation

@interface CCControlColourPicker ()
@property (nonatomic, assign) HSV                                   hsv;
@property (nonatomic, strong) CCControlSaturationBrightnessPicker   *colourPicker;
@property (nonatomic, strong) CCControlHuePicker                    *huePicker;

- (void)updateArrow;
- (void)updateControlPicker;
- (void)updateHueAndControlPicker;

@end

@implementation CCControlColourPicker
@synthesize hsv             = hsv_;
@synthesize colourPicker    = colourPicker_;
@synthesize huePicker       = huePicker_;
@synthesize arrow           = arrow_;
@synthesize arrowDirection  = arrowDirection_;

- (void)dealloc
{
    [huePicker_     removeFromParentAndCleanup:YES];
    [colourPicker_  removeFromParentAndCleanup:YES];
    
    SAFE_ARC_RELEASE(huePicker_);
    SAFE_ARC_RELEASE(colourPicker_);
    SAFE_ARC_RELEASE(arrow_);
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile
{
    return [self initWithHueFile:hueBackgroundFile tintBackgroundFile:tintBackgroundFile tintOverlayFile:tintOverlayFile pickerFile:pickerFile arrowFile:nil];
}

+ (id)colourPickerWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithHueFile:hueBackgroundFile tintBackgroundFile:tintBackgroundFile tintOverlayFile:tintOverlayFile pickerFile:pickerFile]);
}

- (id)initWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile arrowFile:(NSString *)arrowFile
{
    if ((self = [super init]))
	{
        NSAssert(hueBackgroundFile,     @"Hue background must be not nil");
        NSAssert(tintBackgroundFile,    @"Tint background sprite must be not nil");
        NSAssert(tintOverlayFile,       @"Tint overlay must be not nil");
        NSAssert(pickerFile,            @"Picker must be not nil");
        
        // Init the arrow direction
        arrowDirection_                 = CCControlColourPickerArrowDirectionRight;
        
        // Init default color
        hsv_.h                          = 0;
        hsv_.s                          = 0;
        hsv_.v                          = 0;
        
        // Setup panels
        colourPicker_                   = [[CCControlSaturationBrightnessPicker alloc] initWithBackgroundFile:tintBackgroundFile
                                                                                                  overlayFile:tintOverlayFile
                                                                                                   pickerFile:pickerFile];
        huePicker_                      = [[CCControlHuePicker alloc] initWithBackgroundFile:hueBackgroundFile
                                                                                  pickerFile:pickerFile
                                                                           disableZoneLength:(colourPicker_.contentSize.width / 2)];
        
        // Setup events
		[huePicker_ addTarget:self action:@selector(huePickerValueChanged:) forControlEvents:CCControlEventValueChanged];
		[colourPicker_ addTarget:self action:@selector(colourPickerValueChanged:) forControlEvents:CCControlEventValueChanged];
        
        // Set defaults
        [self updateHueAndControlPicker];
        
        [self addChild:colourPicker_ z:2];
        [self addChild:huePicker_ z:1];
        
        // Set content size
        [self setContentSize:[huePicker_ contentSize]];
        
        // Add the arrow
        if (arrowFile)
        {
            self.arrow                  = [CCSprite spriteWithFile:arrowFile];
            [self addChild:arrow_ z:0];
        }
	}
	return self;
}

+ (id)colourPickerWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile arrowFile:(NSString *)arrowFile
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithHueFile:hueBackgroundFile tintBackgroundFile:tintBackgroundFile tintOverlayFile:tintOverlayFile pickerFile:pickerFile arrowFile:arrowFile]);
}

#pragma mark Properties

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

- (void)setArrow:(CCSprite *)arrow
{
    if (arrow_)
        SAFE_ARC_RELEASE(arrow_);
    
    arrow_  = SAFE_ARC_RETAIN(arrow);
    
    [self updateArrow];
}

- (void)setArrowDirection:(CCControlColourPickerArrowDirection)arrowDirection
{
    arrowDirection_ = arrowDirection;
    
    [self updateArrow];
}

#pragma mark CCControlColourPicker Public Methods
#pragma mark CCControlColourPicker Private Methods

- (void)updateArrow
{
    CGSize arrowSize    = [arrow_ contentSize];
    CGSize hueSize      = [huePicker_ contentSize];
    
    switch (arrowDirection_)
    {
        case CCControlColourPickerArrowDirectionTop:
            arrow_.rotation = 270;
            arrow_.position = ccp(0, hueSize.height / 2 + arrowSize.width / 2 - 3);
            hueSize.height  += arrowSize.width;
            break;
        case CCControlColourPickerArrowDirectionBottom:
            arrow_.rotation = 90;
            arrow_.position = ccp(0, -hueSize.height / 2 - arrowSize.width / 2 + 3);
            hueSize.height  += arrowSize.width;
            break;
        case CCControlColourPickerArrowDirectionLeft:
            arrow_.rotation = 180;
            arrow_.position = ccp(-hueSize.width / 2 - arrowSize.width / 2 + 3, 0);
            hueSize.width   += arrowSize.width;
            break;
        default:
            arrow_.rotation = 0;
            arrow_.position = ccp(hueSize.width / 2 + arrowSize.width / 2 - 3, 0);
            hueSize.width   += arrowSize.width;
            break;
    }

    [self setContentSize:hueSize];
}

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

- (void)huePickerValueChanged:(CCControlHuePicker *)sender
{
    hsv_.h      = sender.hue;
    
    // Update the value
    RGBA rgb    = [CCColourUtils RGBfromHSV:hsv_];
    color_      = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
    
	// Send CCControl callback
	[self sendActionsForControlEvents:CCControlEventValueChanged];
    [self updateControlPicker];
}

- (void)colourPickerValueChanged:(CCControlSaturationBrightnessPicker *)sender
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
@synthesize picker          = picker_;
@synthesize length          = length_;
@synthesize hue             = hue_;
@synthesize huePercentage   = huePercentage_;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    SAFE_ARC_RELEASE(background_);
    SAFE_ARC_RELEASE(picker_);
    
	SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithBackgroundFile:(NSString *)backgroundFile pickerFile:(NSString *)pickerFile disableZoneLength:(double)length
{
    if ((self = [super init]))
    {
        self.background     = [CCSprite spriteWithFile:backgroundFile];
        [self addChild:background_];
        
        self.picker         = [CCSprite spriteWithFile:pickerFile];
        [self addChild:picker_];
        
        length_             = length;
        
        // Sets the default value
        hue_                = 0.0f;
        huePercentage_      = 0.0f;
        
        self.contentSize    = [background_ contentSize];
    }
    return self;
}

- (void)setHue:(CGFloat)hueValue
{
    hue_                    = hueValue;
    
    // Set the position of the picker to the correct hue
    // We need to divide it by 360 as its taken as an angle in degrees
    float huePercentage     = hueValue / 360.0f;
    
    // update
    [self setHuePercentage:huePercentage];
}

- (void)setHuePercentage:(CGFloat)hueValueInPercent_
{
    huePercentage_          = hueValueInPercent_;
    hue_                    = hueValueInPercent_ * 360.0f;
    
    // Work out the limit to the distance of the picker when moving around the hue bar
    float limit             = length_ + (((self.contentSize.width / 2) - length_) / 2) - 1;
    
    // Update angle
    float angleDeg          = huePercentage_ * 360.0f - 180.0f;
    float angle             = CC_DEGREES_TO_RADIANS(angleDeg);
    
    // Set new position of the picker
    float x                 = limit * cosf(angle);
    float y                 = limit * sinf(angle);
    picker_.position        = ccp(x, y);
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    picker_.opacity = enabled ? 255.0f : 128.0f;
}

#pragma mark CCControlHuePicker Public Methods
#pragma mark CCControlHuePicker Private Methods

- (void)updatePickerPosition:(CGPoint)location
{
    // Work out the distance difference between the location and center
    float dx                = location.x;
    float dy                = location.y;
    
    // Update angle by using the direction of the location
    float angle             = atan2f(dy, dx);
    float angleDeg          = CC_RADIANS_TO_DEGREES(angle) + 180.0f;
    
    // Use the position / picker width to determin the percentage the dragger is at
    self.hue                = angleDeg;
    
	// Send CCControl callback
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

- (BOOL)checkPickerPosition:(CGPoint)location
{
    // Compute the distance between the current location and the center
    double distance     = sqrt(pow(location.x, 2) + pow(location.y, 2));
    int max_distance    = self.contentSize.width / 2;
    int min_distance    = length_;
    
    // Check that the touch location is within the bounding rectangle before sending updates
    if (max_distance > distance && distance > min_distance)
    {
        [self updatePickerPosition:location];
        
        return YES;
    }
    
    return NO;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.isEnabled)
        return NO;
    
    // Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    // Check the touch position on the picker
    return [self checkPickerPosition:touchLocation];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
    [self updatePickerPosition:touchLocation];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
        return NO;
    
    // Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
    // Check the touch position on the picker
    self.selected           = [self checkPickerPosition:eventLocation];
    
    return [self isSelected];
}


- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self isSelected])
        return NO;
    
	// Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
	[self updatePickerPosition:eventLocation];
    
    return YES;
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
@synthesize background  = background_;
@synthesize picker      = picker_;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    SAFE_ARC_RELEASE(background_);
    SAFE_ARC_RELEASE(picker_);
    
	SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithBackgroundFile:(NSString *)backgroundFile overlayFile:(NSString *)overlayFile pickerFile:(NSString *)pickerFile
{
    if ((self = [super init]))
    {
        self.background = [CCSprite spriteWithFile:backgroundFile];
        [self addChild:background_];
        
        [self addChild:[CCSprite spriteWithFile:overlayFile] z:1];
        
        self.picker     = [CCSprite spriteWithFile:pickerFile];
        [self addChild:picker_ z:2];
        
        self.contentSize    = [background_ contentSize];
    }
    return self;
}

#pragma mark CCControlPicker Public Methods

- (void)updateWithHSV:(HSV)hsv
{
    HSV hsvTemp;
    hsvTemp.s           = 1;
    hsvTemp.h           = hsv.h;
    hsvTemp.v           = 1;
    
    RGBA rgb            = [CCColourUtils RGBfromHSV:hsvTemp];
    
    background_.color   = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
}

- (void)updateDraggerWithHSV:(HSV)hsv
{
    // Set the position of the picker to the correct saturation and brightness
    CGPoint pos	= CGPointMake(self.contentSize.width * (1 - hsv.s),
                              self.contentSize.height * hsv.v);
    
    // Update
    [self updatePickerPosition:pos];
}

#pragma mark CCControlPicker Private Methods

- (void)updatePickerPosition:(CGPoint)pickerPosition
{
    // Clamp the position of the icon within the circle
    static const int boxPos = 20;
    
    // Work out the distance difference between the location and center
    float dx                = pickerPosition.x;
    float dy                = pickerPosition.y;
    float dist              = sqrtf(dx * dx + dy * dy);
    
    // Update angle by using the direction of the location
    float angle             = atan2f(dy, dx);
    
    // Set the limit to the picker movement within the colour picker
    float limit             = self.contentSize.width * 0.5f;
    
    // Check distance doesn't exceed the bounds of the circle
    if (dist > limit)
    {
        pickerPosition.x    = limit * cosf(angle);
        pickerPosition.y    = limit * sinf(angle);
    }
    
    // Set the position of the dragger
    picker_.position        = pickerPosition;
    
    // Compute the box size
    float boxSize           = self.contentSize.width - (boxPos * 2);
    
    // Clamp the position within the virtual box for colour selection
    if (pickerPosition.x < -limit + boxPos)         pickerPosition.x = -limit + boxPos;
    else if (pickerPosition.x > limit - boxPos - 1) pickerPosition.x = limit - boxPos - 1;
    if (pickerPosition.y < -limit + boxPos)         pickerPosition.y = -limit + boxPos;
    else if (pickerPosition.y > limit - boxPos)     pickerPosition.y = limit - boxPos;
    
    // Use the position / picker width to determin the percentage the dragger is at
    self.saturation         = 1 - ABS((-limit + boxPos - pickerPosition.x) / boxSize);
    self.brightness         = ABS((-limit + boxPos - pickerPosition.y) / boxSize);
}

- (BOOL)checkPickerPosition:(CGPoint)location
{
    // Clamp the position of the icon within the circle
    
    // Get the center point of the bkgd image
    float centerX   = 0;
    float centerY   = 0;
    
    // Work out the distance difference between the location and center
    float dx        = location.x - centerX;
    float dy        = location.y - centerY;
    float dist      = sqrtf(dx*dx + dy*dy);
    
    // Check that the touch location is within the bounding rectangle before sending updates
	if (dist <= self.contentSize.width / 2)
    {
        [self updatePickerPosition:location];
        
        // Send CCControl callback
        [self sendActionsForControlEvents:CCControlEventValueChanged];
        
        return YES;
    }
    return NO;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    picker_.opacity = enabled ? 255.0f : 128.0f;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
        return NO;
    
	// Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
    
    // check the touch position on the picker
	return [self checkPickerPosition:touchLocation];
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Get the touch location
	CGPoint touchLocation   = [self touchLocation:touch];
	
    [self updatePickerPosition:touchLocation];
    
    // Send CCControl callback
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
        return NO;
    
    // Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
    // Check the touch position on the picker
    self.selected           = [self checkPickerPosition:eventLocation];
    
    return [self isSelected];
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (!self.isEnabled
        || ![self isSelected])
        return NO;
    
	// Get the event location
	CGPoint eventLocation   = [self eventLocation:event];
    [self updatePickerPosition:eventLocation];
    
    // Send CCControl callback
    [self sendActionsForControlEvents:CCControlEventValueChanged];
    
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    self.selected = NO;
    return NO;
}

#endif

@end