/*
 * CCControlSlider
 *
 * Copyright 2011 Yannick Loriot.
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

#import "CCControlSlider.h"
#import "ARCMacro.h"

@interface CCControlSlider ()
@property (nonatomic, strong) CCSprite  *thumbSprite;
@property (nonatomic, strong) CCSprite  *progressSprite;
@property (nonatomic, strong) CCSprite  *backgroundSprite;
@property (nonatomic, assign) float     animatedValue;

/** Factorize the event dispath into these methods. */
- (void)sliderBegan:(CGPoint)location;
- (void)sliderMoved:(CGPoint)location;
- (void)sliderEnded:(CGPoint)location;

/** Returns the value for the given location. */
- (float)valueForLocation:(CGPoint)location;

/** Layout the slider with the given value. */
- (void)layoutWithValue:(float)value;

@end

@implementation CCControlSlider
@synthesize thumbSprite         = _thumbSprite;
@synthesize progressSprite      = _progressSprite;
@synthesize backgroundSprite    = _backgroundSprite;
@synthesize animatedValue       = _animatedValue;
@synthesize value               = _value;
@synthesize minimumValue        = _minimumValue;
@synthesize maximumValue        = _maximumValue;
@synthesize onThumbTintColor    = _onThumbTintColor;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_thumbSprite);
    SAFE_ARC_RELEASE(_progressSprite);
    SAFE_ARC_RELEASE(_backgroundSprite);
    
    SAFE_ARC_SUPER_DEALLOC();
}

+ (id)sliderWithBackgroundFile:(NSString *)backgroundname progressFile:(NSString *)progressname thumbFile:(NSString *)thumbname
{
    // Prepare background for slider
    CCSprite *backgroundSprite  = [CCSprite spriteWithFile:backgroundname];
	
    // Prepare progress for slider
    CCSprite *progressSprite    = [CCSprite spriteWithFile:progressname];
    
	// Prepare thumb for slider
    CCSprite *thumbSprite       = [CCSprite spriteWithFile:thumbname];
    
    return [self sliderWithBackgroundSprite:backgroundSprite
                             progressSprite:progressSprite
                                thumbSprite:thumbSprite];
}

+ (id)sliderWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)pogressSprite thumbSprite:(CCSprite *)thumbSprite
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithBackgroundSprite:backgroundSprite
                                                        progressSprite:pogressSprite
                                                           thumbSprite:thumbSprite]);
}

// Designated init
- (id)initWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)progressSprite thumbSprite:(CCSprite *)thumbSprite
{
    if ((self = [super init]))
    {
        NSAssert(backgroundSprite,  @"Background sprite must be not nil");
        NSAssert(progressSprite,    @"Progress sprite must be not nil");
        NSAssert(thumbSprite,       @"Thumb sprite must be not nil");
        
        self.ignoreAnchorPointForPosition   = NO;
        
        self.backgroundSprite           = backgroundSprite;
        self.progressSprite             = progressSprite;
        self.thumbSprite                = thumbSprite;
        
        // Defines the content size
        CGRect maxRect                  = CGRectUnion([_backgroundSprite boundingBox], [_thumbSprite boundingBox]);
        self.contentSize                = CGSizeMake(maxRect.size.width, maxRect.size.height);
        
		// Add the slider background
        _backgroundSprite.anchorPoint   = ccp (0.5f, 0.5f);
		_backgroundSprite.position      = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
		[self addChild:_backgroundSprite];
        
        // Add the progress bar
        _progressSprite.anchorPoint     = ccp (0.0f, 0.5f);
        _progressSprite.position        = ccp (0.0f, self.contentSize.height / 2);
        [self addChild:_progressSprite];
		
		// Add the slider thumb
		_thumbSprite.position           = ccp(0, self.contentSize.height / 2);
		[self addChild:_thumbSprite];
        
        // Init default values
        _onThumbTintColor               = ccGRAY;
        _minimumValue                   = 0.0f;
        _maximumValue                   = 1.0f;
        self.value                      = _minimumValue;
    }
    return self;
}

#pragma mark Properties

- (void)setEnabled:(BOOL)enabled
{
    super.enabled           = enabled;
    
    _thumbSprite.opacity    = (enabled) ? 255.0f : 128.0f;
}

- (void)setValue:(float)value
{
    [self setValue:value animated:NO];
}

- (void)setAnimatedValue:(float)animatedValue
{
    [self layoutWithValue:animatedValue];
}

- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue       = minimumValue;
    
    if (_minimumValue >= _maximumValue)
    {
        _maximumValue   = _minimumValue + 1.0f;
    }
    
    self.value          = _maximumValue;
}

- (void)setMaximumValue:(float)maximumValue
{
    _maximumValue       = maximumValue;
    
    if (_maximumValue <= _minimumValue)
    {
        _minimumValue   = _maximumValue - 1.0f;
    }
    
    self.value          = _minimumValue;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)isTouchInside:(UITouch *)touch
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation           = [[self parent] convertToNodeSpace:touchLocation];
    
    CGRect rect             = [self boundingBox];
    rect.size.width         += _thumbSprite.contentSize.width;
    rect.origin.x           -= _thumbSprite.contentSize.width / 2;
    
    return CGRectContainsPoint(rect, touchLocation);
}

- (CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];                      // Get the touch position
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];  // Convert the position to GL space
    touchLocation           = [self convertToNodeSpace:touchLocation];                  // Convert to the node space of this class
    
    if (touchLocation.x < 0)
    {
        touchLocation.x     = 0;
    } else if (touchLocation.x > _backgroundSprite.contentSize.width)
    {
        touchLocation.x     = _backgroundSprite.contentSize.width;
    }
    
    return touchLocation;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
    {
        return NO;
    }
    
    CGPoint location = [self locationFromTouch:touch];
    
    [self sliderBegan:location];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self locationFromTouch:touch];
	
    [self sliderMoved:location];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self sliderEnded:CGPointZero];
}

#endif

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)isMouseInside:(NSEvent *)event
{
    CGPoint eventLocation   = [[CCDirector sharedDirector] convertEventToGL:event];
    eventLocation           = [[self parent] convertToNodeSpace:eventLocation];
    
    CGRect rect             = [self boundingBox];
    rect.size.width         += _thumbSprite.contentSize.width;
    rect.origin.x           -= _thumbSprite.contentSize.width / 2;
    
    return CGRectContainsPoint(rect, eventLocation);
}

- (CGPoint)locationFromEvent:(NSEvent *)event
{
    CGPoint eventLocation   = [[CCDirector sharedDirector] convertEventToGL:event];
    eventLocation           = [self convertToNodeSpace:eventLocation];
    
    if (eventLocation.x < 0)
    {
        eventLocation.x = 0;
    } else if (eventLocation.x > _backgroundSprite.contentSize.width)
    {
        eventLocation.x = _backgroundSprite.contentSize.width;
    }
    
	return eventLocation;
}

- (BOOL)ccMouseDown:(NSEvent*)event
{
    if (![self isMouseInside:event]
        || ![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
    {
        return NO;
    }
	
    CGPoint location = [self locationFromEvent:event];
    
    [self sliderBegan:location];
    
    return YES;
}


- (BOOL)ccMouseDragged:(NSEvent*)event
{
	if (![self isSelected]
        || ![self isEnabled])
    {
		return NO;
    }
	
    CGPoint location = [self locationFromEvent: event];
	
    [self sliderMoved:location];
	
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent*)event
{
    [self sliderEnded:CGPointZero];
	
	return NO;
}

#endif

#pragma mark -
#pragma mark CCControlSlider Public Methods

- (void)needsLayout
{
    [self layoutWithValue:_value];
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    // Set new value with sentinel
    if (value < _minimumValue)
		value           = _minimumValue;
	
    if (value > _maximumValue)
		value           = _maximumValue;
    
    if (animated)
    {
        [self runAction:
         [CCEaseInOut actionWithAction:[CCActionTween actionWithDuration:0.2f key:@"animatedValue" from:_value to:value]
                                  rate:1.5f]];
    } else
    {
        [self layoutWithValue:value];
    }
    
    _value              = value;
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

#pragma mark CCControlSlider Private Methods

- (void)sliderBegan:(CGPoint)location
{
    self.selected           = YES;
    self.thumbSprite.color  = _onThumbTintColor;
    self.value              = [self valueForLocation:location];
}

- (void)sliderMoved:(CGPoint)location
{
    self.value              = [self valueForLocation:location];
}

- (void)sliderEnded:(CGPoint)location
{
    if ([self isSelected])
    {
        self.value          = [self valueForLocation:_thumbSprite.position];
    }
    
    self.thumbSprite.color  = ccWHITE;
    self.selected           = NO;
}

- (float)valueForLocation:(CGPoint)location
{
    float percent           = location.x / _backgroundSprite.contentSize.width;
    return _minimumValue + percent * (_maximumValue - _minimumValue);
}

- (void)layoutWithValue:(float)value
{
    // Update thumb position for new value
    float percent               = (value - _minimumValue) / (_maximumValue - _minimumValue);
    
    CGPoint pos                 = _thumbSprite.position;
    pos.x                       = percent * _backgroundSprite.contentSize.width;
    _thumbSprite.position       = pos;
    
    // Stretches content proportional to newLevel
    CGRect textureRect          = _progressSprite.textureRect;
    textureRect                 = CGRectMake(textureRect.origin.x, textureRect.origin.y, pos.x, textureRect.size.height);
    [_progressSprite setTextureRect:textureRect rotated:_progressSprite.textureRectRotated untrimmedSize:textureRect.size];
}

@end
