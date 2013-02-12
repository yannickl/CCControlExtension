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

#define CCControlPickerFriction         0.75f   // Between 0 and 1
#define CCControlPickerDefaultRowWidth  100     //px
#define CCControlPickerDefaultRowHeight 34      //px

@interface CCControlPicker ()
// Scroll Animation
@property (nonatomic, getter = isDecelerating) BOOL         decelerating;
@property (nonatomic, assign) CGPoint                       previousLocation;
@property (nonatomic, assign) CGPoint                       velocity;
@property (nonatomic, strong) NSDate                        *previousDate;
// Picker
@property (nonatomic, strong) CCLayer                       *cellLayer;
@property (nonatomic, strong) NSMutableArray                *cells;
@property (nonatomic, assign) NSInteger                     selectedRow;
@property (nonatomic, assign) CGSize                        rowSize;

- (void)needsLayoutWithRowNumber:(NSUInteger)rowNumber;

@end

@implementation CCControlPicker
@synthesize decelerating        = _decelerating;
@synthesize previousLocation    = _previousLocation;
@synthesize velocity            = _velocity;
@synthesize previousDate        = _previousDate;
@synthesize cellLayer           = _cellLayer;
@synthesize cells               = _cells;
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
        
        _selectedRow                        = -1;
        _rowSize                            = CGSizeMake(CCControlPickerDefaultRowWidth,
                                                         CCControlPickerDefaultRowHeight);
        _swipeOrientation                   = CCControlPickerOrientationVertical;
        _looping                            = NO;
        
        CGPoint center                      = ccp (self.contentSize.width / 2, self.contentSize.height /2);
        foregroundSprite.position           = center;
        [self addChild:foregroundSprite z:0];
        
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
    
    if (_velocity.y <= 0.01 && _velocity.y >= -0.01)
    {
        _decelerating   = NO;
        return;
    }
    
    CGPoint tranlation  = ccp (_velocity.x * delta, _velocity.y * delta);
    CGPoint position    = _cellLayer.position;
    if (_swipeOrientation == CCControlPickerOrientationVertical)
        position.y      -= tranlation.y;
    else
        position.x      -= tranlation.x;
    _cellLayer.position = position;
    
    // Update the new velocity
    _velocity           = ccp(_velocity.x * CCControlPickerFriction,
                              _velocity.y * CCControlPickerFriction);
}

#pragma mark Properties

#pragma mark - CCControlPicker Public Methods

- (CGSize)rowSize
{
    return _rowSize;
}

- (NSUInteger)numberOfRows
{
    return 0;
}

- (void)reloadComponent
{
    if (_dataSource)
    {
        [self needsLayoutWithRowNumber:[_dataSource numberOfRowsInPickerControl:self]];
    }
    
    [self needsLayoutWithRowNumber:0];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated
{
    
}

- (NSInteger)selectedRow
{
    return _selectedRow;
}

#pragma mark - CCControlPicker Private Methods

- (void)needsLayoutWithRowNumber:(NSUInteger)rowNumber
{
    for (NSUInteger i = 0; i < rowNumber; i++)
    {
        CCLabelTTF *lab         = [CCLabelTTF labelWithString:[_dataSource pickerControl:self titleForRow:i]
                                           dimensions:_rowSize
                                           hAlignment:UITextAlignmentCenter
                                             fontName:@"Arial"
                                             fontSize:10];
        lab.verticalAlignment   = kCCVerticalTextAlignmentCenter;
        lab.color               = ccWHITE;
        [_cellLayer addChild:lab z:1];
        
        CGPoint position        = ccp (self.contentSize.width / 2, self.contentSize.height / 2);
        if (_swipeOrientation == CCControlPickerOrientationVertical)
        {
            position.y          += _rowSize.height * i;
        } else
        {
            position.x          += _rowSize.width * i;
        }
        lab.position            = position;
    }
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
        cellPosition.y      -= _previousLocation.y - touchLocation.y;
    else
        cellPosition.x      -= _previousLocation.x - touchLocation.x;
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
