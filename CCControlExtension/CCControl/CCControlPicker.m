/*
 * CCControlPicker.m
 *
 * Copyright 2013 Yannick Loriot. All rights reserved.
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

#import "CCControlPicker.h"
#import "ARCMacro.h"

#define CCControlPickerFriction         0.70f   // Between 0 and 1
#define CCControlPickerDefaultRowWidth  65      //px
#define CCControlPickerDefaultRowHeight 34      //px

@interface CCControlPicker ()
// Scroll Animation
@property (nonatomic, getter = isDecelerating) BOOL         decelerating;
@property (nonatomic, assign) CGPoint                       previousLocation;
@property (nonatomic, assign) CGPoint                       velocity;
@property (nonatomic, assign) CGRect                        limitBounds;
@property (nonatomic, strong) NSDate                        *previousDate;
// Picker
@property (nonatomic, strong) CCLayer                       *cellLayer;
@property (nonatomic, strong) NSMutableArray                *cells;
@property (nonatomic, assign) NSUInteger                    cachedRowCount;
@property (nonatomic, assign) NSInteger                     selectedRow;
@property (nonatomic, assign) CGSize                        cacheRowSize;

/** Layout the picker with the number given row count. */
- (void)needsLayoutWithRowCount:(NSUInteger)rowCount;

/** Returns YES whether the given value is out of the given bounds. */
- (BOOL)isValue:(double)value outOfMinBound:(double)min maxBound:(double)max;

/** Returns the translation to apply using the given axis location
 * value and the bounds of the control picker. */
- (double)adjustTranslation:(double)tranlation forAxisValue:(double)axis usingMinBound:(double)min maxBound:(double)max;

@end

@implementation CCControlPicker
@synthesize decelerating        = _decelerating;
@synthesize previousLocation    = _previousLocation;
@synthesize velocity            = _velocity;
@synthesize limitBounds         = _limitBounds;
@synthesize previousDate        = _previousDate;
@synthesize cellLayer           = _cellLayer;
@synthesize cells               = _cells;
@synthesize cachedRowCount      = _cachedRowCount;
@synthesize selectedRow         = _selectedRow;
@synthesize swipeOrientation    = _swipeOrientation;
@synthesize looping             = _looping;
@synthesize delegate            = _delegate;
@synthesize dataSource          = _dataSource;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_previousDate);
    SAFE_ARC_RELEASE(_cellLayer);
    SAFE_ARC_RELEASE(_cells);
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithForegroundSprite:(CCSprite *)foregroundSprite selectionSprite:(CCSprite *)selectionSprite
{
    if ((self = [super init]))
    {
        NSAssert(foregroundSprite,   @"Foreground sprite must be not nil");
        NSAssert(selectionSprite,    @"Selection sprite must be not nil");
        
        self.decelerating                   = NO;
        self.ignoreAnchorPointForPosition   = NO;
        self.contentSize                    = foregroundSprite.contentSize;
        self.anchorPoint                    = ccp(0.5f, 0.5f);
        self.cells                          = [NSMutableArray array];
        
        _cachedRowCount                     = 0;
        _selectedRow                        = -1;
        _cacheRowSize                       = CGSizeMake(CCControlPickerDefaultRowWidth,
                                                         CCControlPickerDefaultRowHeight);
        _swipeOrientation                   = CCControlPickerOrientationVertical;
        _looping                            = NO;
        
        CGPoint center                      = ccp (self.contentSize.width / 2, self.contentSize.height /2);
        foregroundSprite.position           = center;
        [self addChild:foregroundSprite z:0];
        
        self.cellLayer                      = [CCLayer node];
        _cellLayer.anchorPoint              = ccp(0, 0);
        [self addChild:_cellLayer z:1];
        
        selectionSprite.position            = center;
        [self addChild:selectionSprite z:2];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [self scheduleUpdate];
    
    [self reloadComponent];
}

- (void)onExit
{
    [self unscheduleUpdate];
    
    [super onExit];
}

- (void)visit
{
	if (!self.visible)
		return;
    
	glEnable(GL_SCISSOR_TEST);
    
    CGRect scissorRect  = [self boundingBox];
    
	scissorRect         = CGRectMake(scissorRect.origin.x * CC_CONTENT_SCALE_FACTOR(),
                                     scissorRect.origin.y * CC_CONTENT_SCALE_FACTOR(),
                                     scissorRect.size.width * CC_CONTENT_SCALE_FACTOR(),
                                     scissorRect.size.height * CC_CONTENT_SCALE_FACTOR());
    
	glScissor(scissorRect.origin.x, scissorRect.origin.y,
			  scissorRect.size.width, scissorRect.size.height);
    
	[super visit];
    
	glDisable(GL_SCISSOR_TEST);
}

- (void)update:(ccTime)delta
{
    if (![self isDecelerating])
        return;
    
    if (_velocity.y <= 0.05 && _velocity.y >= -0.05)
    {
        _decelerating       = NO;
        return;
    }
    
    CGPoint tranlation      = ccp (_velocity.x * delta, _velocity.y * delta);
    CGPoint cellPosition    = _cellLayer.position;
    if (_swipeOrientation == CCControlPickerOrientationVertical)
    {
        cellPosition.y      -= [self adjustTranslation:tranlation.y
                                          forAxisValue:cellPosition.y
                                         usingMinBound:_limitBounds.origin.y
                                              maxBound:_limitBounds.size.height];
    } else
    {
        cellPosition.x      -= [self adjustTranslation:tranlation.x
                                          forAxisValue:cellPosition.x
                                         usingMinBound:_limitBounds.origin.x
                                              maxBound:_limitBounds.size.width];
    }
    _cellLayer.position     = cellPosition;
    
    // Update the new velocity
    _velocity               = ccp(_velocity.x * CCControlPickerFriction,
                                  _velocity.y * CCControlPickerFriction);
}

#pragma mark Properties

#pragma mark - CCControlPicker Public Methods

- (CGSize)rowSize
{
    return _cacheRowSize;
}

- (NSUInteger)numberOfRows
{
    return 0;
}

- (void)reloadComponent
{
    _cachedRowCount        = 0;
    
    if (_dataSource)
        _cachedRowCount     = [_dataSource numberOfRowsInPickerControl:self];
    
    [self needsLayoutWithRowCount:_cachedRowCount];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated
{
    
}

- (NSInteger)selectedRow
{
    return _selectedRow;
}

#pragma mark - CCControlPicker Private Methods

- (void)needsLayoutWithRowCount:(NSUInteger)rowCount
{
    for (NSUInteger i = 0; i < rowCount; i++)
    {
        CCLabelTTF *lab         = [CCLabelTTF labelWithString:[_dataSource pickerControl:self titleForRow:i]
                                                   dimensions:_cacheRowSize
                                                   hAlignment:UITextAlignmentCenter
                                                     fontName:@"Arial"
                                                     fontSize:10];
        lab.verticalAlignment   = kCCVerticalTextAlignmentCenter;
        lab.color               = ccWHITE;
        lab.anchorPoint         = ccp(0, 0);
        [_cellLayer addChild:lab z:1];
        
        CGPoint position        = ccp (0, 0);
        if (_swipeOrientation == CCControlPickerOrientationVertical)
        {
            position.y          += (_cacheRowSize.height - _cacheRowSize.height * i);
        } else
        {
            position.x          += (0 + _cacheRowSize.width * i);
        }
        lab.position            = position;
    }
    
    // Defines the limit bounds for non-circular picker
    _limitBounds    = CGRectMake(_cacheRowSize.width * (_cachedRowCount - 1) * -1,
                                 0,
                                 0,
                                 _cacheRowSize.height * (_cachedRowCount - 1));
}

- (BOOL)isValue:(double)value outOfMinBound:(double)min maxBound:(double)max
{
    return  (value <= min || max <= value);
}

- (double)adjustTranslation:(double)tranlation forAxisValue:(double)axis usingMinBound:(double)min maxBound:(double)max
{
    // If the picker is not circular we check if we have reached an edge
    if (![self isLooping] && [self isValue:axis outOfMinBound:min maxBound:max])
    {
        double d1       = ABS(min - axis);
        double d2       = ABS(max - axis);
        
        double friction = exp(MIN(d1, d2) / 30.0f) + 1.0f;
        
        return tranlation / friction;
    }
    
    return tranlation;
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch])
        return NO;
    
    CGPoint touchLocation   = [touch locationInView:[touch view]];
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation           = [[self parent] convertToNodeSpace:touchLocation];
    
    CGPoint location        = touchLocation;
    
    _decelerating           = NO;
    _previousLocation       = location;
    self.previousDate       = [NSDate date];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation           = [[self parent] convertToNodeSpace:touchLocation];
    
    // Update the cell layer position
    CGPoint cellPosition    = _cellLayer.position;
    if (_swipeOrientation == CCControlPickerOrientationVertical)
    {
        cellPosition.y      -= [self adjustTranslation:(_previousLocation.y - touchLocation.y)
                                          forAxisValue:cellPosition.y
                                         usingMinBound:_limitBounds.origin.y
                                              maxBound:_limitBounds.size.height];
    } else
    {
        cellPosition.x      -= [self adjustTranslation:(_previousLocation.x - touchLocation.x)
                                          forAxisValue:cellPosition.x
                                         usingMinBound:_limitBounds.origin.x
                                              maxBound:_limitBounds.size.width];
    }
    _cellLayer.position     = cellPosition;
    
    // Compute the current velocity
    double delta_time       = [[NSDate date] timeIntervalSinceDate:_previousDate];
    CGPoint delta_position  = ccpSub(_previousLocation, touchLocation);
    _velocity               = ccp(delta_position.x / delta_time, delta_position.y / delta_time);
    
    // Update the previous location and date
    _previousLocation       = touchLocation;
    self.previousDate       = [NSDate date];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _decelerating           = YES;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self ccTouchEnded:touch withEvent:event];
}

@end
