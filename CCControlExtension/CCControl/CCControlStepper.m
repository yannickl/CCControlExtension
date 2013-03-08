/*
 * CCControlStepper.m
 *
 * Copyright 2012 Yannick Loriot. All rights reserved.
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

#import "CCControlStepper.h"
#import "ARCMacro.h"

#define CCControlStepperLabelColorEnabled   ccc3(55, 55, 55)
#define CCControlStepperLabelColorDisabled  ccc3(147, 147, 147)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define CCControlStepperLabelFont           @"CourierNewPSMT"
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
#define CCControlStepperLabelFont           @"Courier New"
#endif

#define kAutorepeatDeltaTime                0.15f
#define kAutorepeatIncreaseTimeIncrement    12

@interface CCControlStepper ()
@property (nonatomic, strong) CCSprite      *minusSprite;
@property (nonatomic, strong) CCSprite      *plusSprite;
@property (nonatomic, strong) CCLabelTTF    *minusLabel;
@property (nonatomic, strong) CCLabelTTF    *plusLabel;

/** Update the layout of the stepper with the given touch location. */
- (void)updateLayoutUsingTouchLocation:(CGPoint)location;

/** Set the numeric value of the stepper. If send is true, the CCControlEventValueChanged is sent. */
- (void)setValue:(double)value sendingEvent:(BOOL)send;

/** Start the autorepeat increment/decrement. */
- (void)startAutorepeat;

/** Stop the autorepeat. */
- (void)stopAutorepeat;

@end

@implementation CCControlStepper
@synthesize minusSprite     = _minusSprite;
@synthesize plusSprite      = _plusSprite;
@synthesize minusLabel      = _minusLabel;
@synthesize plusLabel       = _plusLabel;

@synthesize value           = _value;
@synthesize continuous      = _continuous;
@synthesize autorepeat      = _autorepeat;
@synthesize wraps           = _wraps;
@synthesize minimumValue    = _minimumValue;
@synthesize maximumValue    = _maximumValue;
@synthesize stepValue       = _stepValue;
@synthesize pushedTintColor = _pushedTintColor;

- (void)dealloc
{
    [self unscheduleAllSelectors];
    
    SAFE_ARC_RELEASE(_minusSprite);
    SAFE_ARC_RELEASE(_plusSprite);
    SAFE_ARC_RELEASE(_minusLabel);
    SAFE_ARC_RELEASE(_plusLabel);
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite
{
    if ((self = [super init]))
    {
        NSAssert(minusSprite,   @"Minus sprite must be not nil");
        NSAssert(plusSprite,    @"Plus sprite must be not nil");
        
        // Set the default values
        _autorepeat                         = YES;
        _continuous                         = YES;
        _minimumValue                       = 0;
        _maximumValue                       = 100;
        _value                              = 0;
        _stepValue                          = 1;
        _wraps                              = NO;
        _pushedTintColor                    = ccGRAY;
        self.ignoreAnchorPointForPosition   = NO;
    
        // Add the minus components
        self.minusSprite                    = minusSprite;
		_minusSprite.position               = ccp(minusSprite.contentSize.width / 2, minusSprite.contentSize.height / 2);
		[self addChild:_minusSprite];
        
        self.minusLabel                     = [CCLabelTTF labelWithString:@"-" fontName:CCControlStepperLabelFont fontSize:40];
        _minusLabel.color                   = CCControlStepperLabelColorDisabled;
        _minusLabel.position                = CGPointMake(_minusSprite.contentSize.width / 2, _minusSprite.contentSize.height / 2);
        [_minusSprite addChild:_minusLabel];
        
        // Add the plus components 
        self.plusSprite                     = plusSprite;
		_plusSprite.position                = ccp(minusSprite.contentSize.width + plusSprite.contentSize.width / 2,
                                                  minusSprite.contentSize.height / 2);
		[self addChild:_plusSprite];
        
        self.plusLabel                      = [CCLabelTTF labelWithString:@"+" fontName:CCControlStepperLabelFont fontSize:40];
        _plusLabel.color                    = CCControlStepperLabelColorEnabled;
        _plusLabel.position                 = CGPointMake(_plusSprite.contentSize.width / 2, _plusSprite.contentSize.height / 2);
        [_plusSprite addChild:_plusLabel];
        
        // Defines the content size
        CGRect maxRect                      = CGRectUnion([_minusSprite boundingBox], [_plusSprite boundingBox]);
        self.contentSize                    = CGSizeMake(_minusSprite.contentSize.width + _plusSprite.contentSize.height,
                                                         maxRect.size.height);
    }
    return self;
}

+ (id)stepperWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithMinusSprite:minusSprite plusSprite:plusSprite]);
}

+ (id)stepperWithMinusFile:(NSString *)minusFile plusFile:(NSString *)plusFile
{
    // Prepare minus for stepper
    CCSprite *minusSprite   = [CCSprite spriteWithFile:plusFile];
    
    // Prepare plus for stepper
    CCSprite *plusSprite    = [CCSprite spriteWithFile:minusFile];
    
    return [self stepperWithMinusSprite:minusSprite plusSprite:plusSprite];
}

#pragma mark Properties

- (void)setWraps:(BOOL)wraps
{
    _wraps = wraps;
    
    if (_wraps)
    {
        _minusLabel.color   = CCControlStepperLabelColorEnabled;
        _plusLabel.color    = CCControlStepperLabelColorEnabled;
    }
    
    self.value  = _value;
}

- (void)setMinimumValue:(double)minimumValue
{
    if (minimumValue >= _maximumValue)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Must be numerically less than maximumValue." userInfo:nil];
    }
    
    _minimumValue   = minimumValue;
    self.value      = _value;
}

- (void)setMaximumValue:(double)maximumValue
{
    if (maximumValue <= _minimumValue)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Must be numerically greater than minimumValue." userInfo:nil];
    }
    
    _maximumValue   = maximumValue;
    self.value      = _value;
}

- (void)setValue:(double)value
{
    [self setValue:value sendingEvent:YES];
}

- (void)setStepValue:(double)stepValue
{
    if (stepValue <= 0)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Must be numerically greater than 0." userInfo:nil];  
    }
    
    _stepValue  = stepValue;
}

#pragma mark -
#pragma mark CCControlStepper Public Methods

- (void)setValue:(double)value sendingEvent:(BOOL)send
{
    if (value < _minimumValue)
    {
        value = _wraps ? _maximumValue : _minimumValue;
    } else if (value > _maximumValue)
    {
        value = _wraps ? _minimumValue : _maximumValue;
    }
    
    _value = value;
    
    if (!_wraps)
    {
        _minusLabel.color   = (value == _minimumValue) ? CCControlStepperLabelColorDisabled : CCControlStepperLabelColorEnabled;
        _plusLabel.color    = (value == _maximumValue) ? CCControlStepperLabelColorDisabled : CCControlStepperLabelColorEnabled;
    }
    
    if (send)
    {
        [self sendActionsForControlEvents:CCControlEventValueChanged];
    }
}

- (void)startAutorepeat
{
    _autorepeatCount    = -1;
    
    [self schedule:@selector(update:) interval:kAutorepeatDeltaTime repeat:kCCRepeatForever delay:kAutorepeatDeltaTime * 3];
}

/** Stop the autorepeat. */
- (void)stopAutorepeat
{
    [self unschedule:@selector(update:)];
}

- (void)update:(ccTime)dt
{
    _autorepeatCount++;
    
    if ((_autorepeatCount < kAutorepeatIncreaseTimeIncrement) && (_autorepeatCount % 3) != 0)
        return;
    
    if (_touchedPart == kCCControlStepperPartMinus)
    {
        [self setValue:(_value - _stepValue) sendingEvent:_continuous];
    } else if (_touchedPart == kCCControlStepperPartPlus)
    {
        [self setValue:(_value + _stepValue) sendingEvent:_continuous];
    }
}

#pragma mark CCControlStepper Private Methods

- (void)updateLayoutUsingTouchLocation:(CGPoint)location
{
    if (location.x < _minusSprite.contentSize.width
        && _value > _minimumValue)
    {
        _touchedPart        = kCCControlStepperPartMinus;
        
        _minusSprite.color  = _pushedTintColor;
        _plusSprite.color   = ccWHITE;
    } else if (location.x >= _minusSprite.contentSize.width
               && _value < _maximumValue)
    {
        _touchedPart        = kCCControlStepperPartPlus;
        
        _minusSprite.color  = ccWHITE;
        _plusSprite.color   = _pushedTintColor;
    } else
    {
        _touchedPart        = kCCControlStepperPartNone;
        
        _minusSprite.color  = ccWHITE;
        _plusSprite.color   = ccWHITE;
    }
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
        return NO;
    
    CGPoint location    = [self touchLocation:touch];
    [self updateLayoutUsingTouchLocation:location];
    
    _touchInsideFlag = YES;
    
    if (_autorepeat)
    {
        [self startAutorepeat];
    }
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([self isTouchInside:touch])
    {
        CGPoint location    = [self touchLocation:touch];
        [self updateLayoutUsingTouchLocation:location];
        
        if (!_touchInsideFlag)
        {
            _touchInsideFlag    = YES;
            
            if (_autorepeat)
            {
                [self startAutorepeat];
            }
        }
    } else
    {
        _touchInsideFlag    = NO;
        
        _touchedPart        = kCCControlStepperPartNone;
        
        _minusSprite.color  = ccWHITE;
        _plusSprite.color   = ccWHITE;
        
        if (_autorepeat)
        {
            [self stopAutorepeat];
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _minusSprite.color  = ccWHITE;
    _plusSprite.color   = ccWHITE;
    
    if (_autorepeat)
    {
        [self stopAutorepeat];
    }
    
    if ([self isTouchInside:touch])
    {
        CGPoint location    = [self touchLocation:touch];
        
        self.value += (location.x < _minusSprite.contentSize.width) ? - _stepValue : _stepValue;
    }
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isMouseInside:event]
        || ![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
        return NO;
    
    CGPoint location    = [self eventLocation:event];
    [self updateLayoutUsingTouchLocation:location];
    
    _touchInsideFlag    = YES;
    self.selected       = YES;
    
    if (_autorepeat)
    {
        [self startAutorepeat];
    }
    
    return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (![self isSelected])
        return NO;
    
    if ([self isMouseInside:event])
    {
        CGPoint location    = [self eventLocation:event];
        [self updateLayoutUsingTouchLocation:location];
        
        if (!_touchInsideFlag)
        {
            _touchInsideFlag    = YES;
            
            if (_autorepeat)
            {
                [self startAutorepeat];
            }
        }
    } else
    {
        _touchInsideFlag    = NO;
        
        _touchedPart        = kCCControlStepperPartNone;
        
        _minusSprite.color  = ccWHITE;
        _plusSprite.color   = ccWHITE;
        
        if (_autorepeat)
        {
            [self stopAutorepeat];
        }
    }
    
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    if (![self isSelected])
        return NO;
    
    self.selected       = NO;
    _minusSprite.color  = ccWHITE;
    _plusSprite.color   = ccWHITE;
    
    if (_autorepeat)
    {
        [self stopAutorepeat];
    }
    
    if ([self isMouseInside:event])
    {
        CGPoint location    = [self eventLocation:event];
        
        self.value += (location.x < _minusSprite.contentSize.width) ? - _stepValue : _stepValue;
    }
    
	return YES;
}

#endif

@end
