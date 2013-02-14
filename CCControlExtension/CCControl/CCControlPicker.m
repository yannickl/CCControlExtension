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
#define CCControlPickerDefaultRowWidth  35      //px
#define CCControlPickerDefaultRowHeight 35      //px

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

/** Returns the row number at the closest location. */
- (NSUInteger)rowNumberAtLocation:(CGPoint)location;

/** Apply the given translation to the given position and return it. */
- (CGPoint)positionWithTranslation:(CGPoint)translation forLayerPosition:(CGPoint)position;

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
@synthesize backgroundNode      = _backgroundNode;
@synthesize swipeOrientation    = _swipeOrientation;
@synthesize looping             = _looping;
@synthesize delegate            = _delegate;
@synthesize dataSource          = _dataSource;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_previousDate);
    SAFE_ARC_RELEASE(_cellLayer);
    SAFE_ARC_RELEASE(_cells);
    SAFE_ARC_AUTORELEASE(_backgroundNode);
    
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
        self.anchorPoint                    = ccp(0.8f, 0.8f);
        self.cells                          = [NSMutableArray array];
        
        _cachedRowCount                     = 0;
        _selectedRow                        = -1;
        _cacheRowSize                       = CGSizeMake(CCControlPickerDefaultRowWidth,
                                                         CCControlPickerDefaultRowHeight);
        _swipeOrientation                   = CCControlPickerOrientationVertical;
        _looping                            = NO;
        
        CGPoint center                      = ccp (self.contentSize.width / 2, self.contentSize.height /2);
        foregroundSprite.position           = center;
        [self addChild:foregroundSprite z:3];
        
        self.cellLayer                      = [CCLayer node];
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
    
    if (_velocity.y <= 30.0f && _velocity.y >= -30.0f)
    {
        _decelerating           = NO;
        
        NSUInteger rowNumber    = [self rowNumberAtLocation:_cellLayer.position];
        [self selectRow:rowNumber animated:YES];
        return;
    }
    
    CGPoint tranlation      = ccp (_velocity.x * delta, _velocity.y * delta);
    _cellLayer.position     = [self positionWithTranslation:tranlation forLayerPosition:_cellLayer.position];
    
    // Update the new velocity
    _velocity               = ccp(_velocity.x * CCControlPickerFriction,
                                  _velocity.y * CCControlPickerFriction);
}

#pragma mark Properties

- (void)setBackgroundNode:(CCNode *)backgroundNode
{
    if (_backgroundNode)
    {
        [self removeChild:_backgroundNode cleanup:YES];
        SAFE_ARC_RELEASE(_backgroundNode);
    }
    
    _backgroundNode = SAFE_ARC_RETAIN(backgroundNode);
    
    if (_backgroundNode)
        [self addChild:_backgroundNode z:0];
}

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
        _cachedRowCount     = [_dataSource numberOfRowsInControlPicker:self];
    
    [self needsLayoutWithRowCount:_cachedRowCount];
}

- (void)selectRow:(NSUInteger)row animated:(BOOL)animated
{
    CGPoint dest = _cellLayer.position;
    
    if (_swipeOrientation == CCControlPickerOrientationVertical)
        dest.y  = _cacheRowSize.height * row;
    else
        dest.x  = -_cacheRowSize.width * row;
    
    [_cellLayer runAction:[CCEaseInOut actionWithAction:
                           [CCEaseElasticOut actionWithAction:
                            [CCMoveTo actionWithDuration:0.4f position:dest] period:0.02f] rate:1.0f]];
    
    _selectedRow    = row;
    
    if (_delegate && [_delegate respondsToSelector:@selector(controlPicker:didSelectRow:)])
        [_delegate controlPicker:self didSelectRow:row];
}

- (NSInteger)selectedRow
{
    return _selectedRow;
}

#pragma mark - CCControlPicker Private Methods

- (void)needsLayoutWithRowCount:(NSUInteger)rowCount
{
    CGPoint center  = ccp (self.contentSize.width / 2, self.contentSize.height /2);
    
    for (NSUInteger i = 0; i < rowCount; i++)
    {
        CCControlPickerRow *row     = [_dataSource controlPicker:self nodeForRow:i];
        row.anchorPoint             = ccp(0.5f, 0.5f);
        [_cellLayer addChild:row z:1];
        
        CGPoint position        = center;
        if (_swipeOrientation == CCControlPickerOrientationVertical)
            position.y          += -_cacheRowSize.height * i;
        else
            position.x          += _cacheRowSize.width * i;
        row.position            = position;
    }
    
    if ([self isLooping])
    {
        CCControlPickerRow *lab_sub         = [_dataSource controlPicker:self nodeForRow:(rowCount - 1)];
        lab_sub.anchorPoint                 = ccp(0.5f, 0.5f);
        [_cellLayer addChild:lab_sub z:1];
        
        CCControlPickerRow *lab_sub2        = [_dataSource controlPicker:self nodeForRow:(rowCount - 2)];
        lab_sub2.anchorPoint                = ccp(0.5f, 0.5f);
        [_cellLayer addChild:lab_sub2 z:1];
        
        CCControlPickerRow *lab_ove         = [_dataSource controlPicker:self nodeForRow:0];
        lab_ove.anchorPoint                 = ccp(0.5f, 0.5f);
        [_cellLayer addChild:lab_ove z:1];
        
        CCControlPickerRow *lab_ove2        = [_dataSource controlPicker:self nodeForRow:1];
        lab_ove2.anchorPoint                = ccp(0.5f, 0.5f);
        [_cellLayer addChild:lab_ove2 z:1];
        
        if (_swipeOrientation == CCControlPickerOrientationVertical)
        {
            lab_sub2.position   = ccpAdd(center, ccp (0, _cacheRowSize.height * 2));
            lab_sub.position    = ccpAdd(center, ccp (0, _cacheRowSize.height));
            lab_ove.position    = ccpAdd(center, ccp (0, -_cacheRowSize.height * rowCount));
            lab_ove2.position   = ccpAdd(center, ccp (0, -_cacheRowSize.height * (rowCount + 1)));
        } else
        {
            lab_sub2.position   = ccpAdd(center, ccp (-_cacheRowSize.width * 2, 0));
            lab_sub.position    = ccpAdd(center, ccp (-_cacheRowSize.width, 0));
            lab_ove.position    = ccpAdd(center, ccp (_cacheRowSize.height * rowCount, 0));
            lab_ove2.position   = ccpAdd(center, ccp (_cacheRowSize.height * (rowCount + 1), 0));
        }
    }
    
    // Defines the limit bounds for non-circular picker
    _limitBounds    = CGRectMake(-_cacheRowSize.width * (_cachedRowCount - 1),
                                 0,
                                 0,
                                 _cacheRowSize.height * (_cachedRowCount - 1));
    
    _selectedRow    = 0;
}

- (BOOL)isValue:(double)value outOfMinBound:(double)min maxBound:(double)max
{
    return  (value <= min || max <= value);
}

- (NSUInteger)rowNumberAtLocation:(CGPoint)location
{
    if (_swipeOrientation == CCControlPickerOrientationVertical)
    {
        if (location.y < _limitBounds.origin.y)
            return 0;
        else if (location.y >= _limitBounds.size.height)
            return _cachedRowCount - 1;
        else
        {
            NSUInteger row  = round(location.y / _cacheRowSize.height);
            if (row == _cachedRowCount)
                row         = 0;
            
            return row;
        }
    } else
    {
        if (location.x < _limitBounds.origin.x)
            return _cachedRowCount - 1;
        else if (location.x >= _limitBounds.size.width)
            return 0;
        else
        {
            NSUInteger row  = round(ABS(location.x) / _cacheRowSize.width);
            if (row == _cachedRowCount)
                row         = 0;
            
            return row;
        }
    }
}

- (CGPoint)positionWithTranslation:(CGPoint)translation forLayerPosition:(CGPoint)position
{
    if (_swipeOrientation == CCControlPickerOrientationVertical)
    {
        position.y      -= [self adjustTranslation:translation.y
                                      forAxisValue:position.y
                                     usingMinBound:_limitBounds.origin.y
                                          maxBound:_limitBounds.size.height];
        
        if ([self isLooping])
        {
            if (position.y < _limitBounds.origin.y)
            {
                double diff = _limitBounds.origin.y - position.y;
                position.y  = _limitBounds.size.height + _cacheRowSize.height - diff;
            } else if ((_limitBounds.size.height + _cacheRowSize.height) < position.y)
            {
                double diff = position.y - (_limitBounds.size.height + _cacheRowSize.height);
                position.y  = _limitBounds.origin.y + diff;
            }
        }
    } else
    {
        position.x      -= [self adjustTranslation:translation.x
                                      forAxisValue:position.x
                                     usingMinBound:_limitBounds.origin.x
                                          maxBound:_limitBounds.size.width];
        
        if ([self isLooping])
        {
            if (position.x < _limitBounds.origin.x)
            {
                double diff = _limitBounds.origin.x - position.x;
                position.x  = _limitBounds.size.width + _cacheRowSize.width - diff;
            } else if ((_limitBounds.size.width + _cacheRowSize.width) < position.x)
            {
                double diff = position.x - (_limitBounds.size.width + _cacheRowSize.width);
                position.x  = _limitBounds.origin.x + diff;
            }
        }
    }
    
    return position;
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
    } else
    {
        return tranlation;
    }
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch])
        return NO;
    
    [_cellLayer stopAllActions];
    
    CGPoint touchLocation   = [touch locationInView:[touch view]];
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation           = [[self parent] convertToNodeSpace:touchLocation];
    
    CGPoint location        = touchLocation;
    
    _decelerating           = NO;
    _previousLocation       = location;
    self.previousDate       = [NSDate date];
    
    // Update the cell layer position
    CGPoint translation     = ccpSub(_previousLocation, touchLocation);
    _cellLayer.position     = [self positionWithTranslation:translation forLayerPosition:_cellLayer.position];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation           = [[self parent] convertToNodeSpace:touchLocation];
    
    // Update the cell layer position
    CGPoint translation     = ccpSub(_previousLocation, touchLocation);
    _cellLayer.position     = [self positionWithTranslation:translation forLayerPosition:_cellLayer.position];
    
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

#pragma mark - CCControlPickerRow

@interface CCControlPickerRow ()

@end

@implementation CCControlPickerRow
@synthesize textLabel               = _textLabel;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_textLabel);
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithTitle:(NSString *)title
{
    if ((self = [super init]))
    {
        CGSize defaultSize              = CGSizeMake(CCControlPickerDefaultRowWidth, CCControlPickerDefaultRowHeight);

        _textLabel                      = SAFE_ARC_RETAIN([CCLabelTTF labelWithString:title
                                                           dimensions:CGSizeMake(CCControlPickerDefaultRowWidth, CCControlPickerDefaultRowHeight)
                                                           hAlignment:UITextAlignmentCenter
                                                             fontName:@"Arial-BoldMT"
                                                             fontSize:15]);
        _textLabel.verticalAlignment    = kCCVerticalTextAlignmentCenter;
        _textLabel.color                = ccBLACK;
        _textLabel.anchorPoint          = ccp(0.5f, 0.5f);
        _textLabel.position             = ccp (CCControlPickerDefaultRowWidth / 2, CCControlPickerDefaultRowHeight / 2);
        [self addChild:_textLabel z:1];
        
        self.contentSize                = defaultSize;
    }
    return self;
}

+ (id)rowWithTitle:(NSString *)title
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithTitle:title]);
}

#pragma mark Properties

@end
