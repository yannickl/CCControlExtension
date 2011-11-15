/*
 * CCControlSlider
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Israel Roth 
 * http://srooltheknife.blogspot.com/
 * https://bitbucket.org/iroth_net/ccslider
 *
 * Copyright (c) 2011 Stepan Generalov 
 *
 * Modified by Yannick Loriot
 * Copyright (c) 2011 Yannick Loriot
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

@interface CCControlSlider ()
@property (nonatomic, assign) float minX, maxX;  
@property (nonatomic, retain) CCMenuItem *thumb;
@property (nonatomic, retain) CCSprite *bg;

/** Factorize the event dispath into these methods. */
- (void)sliderBegan:(CGPoint)location;
- (void)sliderMoved:(CGPoint)location;
- (void)sliderEnded:(CGPoint)location;

@end

@implementation CCControlSlider
@synthesize minX, maxX;
@synthesize thumb = _thumb;
@synthesize bg = _bg;
@synthesize value;

- (void)dealloc
{
    [_thumb release], _thumb = nil;
    [_bg release], _bg = nil;
    
    [super dealloc];
}

- (void)onEnter
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCControlSliderPriority swallowsTouches:YES];
#endif
	[super onEnter];
}

- (void)onExit
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
#endif
    
	[super onExit];
}

+ (id)sliderWithBackgroundFile:(NSString *)bgFile thumbFile:(NSString *)thumbFile
{
	return [[[self alloc] initWithBackgroundFile:bgFile 
                                       thumbFile:thumbFile] autorelease];
}

+ (id)sliderWithBackgroundSprite:(CCSprite *)bgSprite thumbMenuItem:(CCMenuItem *)aThumb
{
	return [[[self alloc] initWithBackgroundSprite:bgSprite 
                                     thumbMenuItem:aThumb] autorelease];
}

// Easy init
- (id)initWithBackgroundFile:(NSString *)bgFile thumbFile:(NSString *)thumbFile
{	
	// Prepare background for slider.
	CCSprite *bg = [CCSprite spriteWithFile:bgFile];
	
	// Prepare thumb (menuItem) for slider.
	CCSprite *thumbNormal = [CCSprite spriteWithFile: thumbFile];
	CCSprite *thumbSelected = [CCSprite spriteWithFile: thumbFile];
	thumbSelected.color = ccGRAY;		
	CCMenuItemSprite *thumbMenuItem = [CCMenuItemSprite itemFromNormalSprite:thumbNormal selectedSprite:thumbSelected];
	
	// Continue with designated init on successfull prepare.
	if (thumbNormal && thumbSelected && thumbMenuItem && bg)
	{
		self = [self initWithBackgroundSprite:bg thumbMenuItem: thumbMenuItem];
		return self;
	}
		
	// Don't leak & return nil on fail.
	[self release];
	return nil;
}

// Designated init
- (id)initWithBackgroundSprite:(CCSprite *)bgSprite thumbMenuItem:(CCMenuItem *)aThumb  
{  
	if ((self = [super init]))  
	{   
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;  
#elif (__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		value = 0;  
		
        self.isRelativeAnchorPoint = YES;
		self.anchorPoint = ccp(0.5f,0.5f);
        
        self.bg = bgSprite;
        self.thumb = aThumb;
        
        // Defines the content size
        CGRect maxRect = CGRectUnion([_bg boundingBox], [_thumb boundingBox]);
        [self setContentSize:CGSizeMake(maxRect.size.width, maxRect.size.height)];
        
        // Calculate the min and max values  
		self.minX = _thumb.contentSize.width / 2;  
		self.maxX = _bg.contentSize.width - _thumb.contentSize.width / 2;
        
		// Add the slider background   
		_bg.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);  
		[self addChild:_bg];  
		
		// Add the slider thumb  
		_thumb.position = CGPointMake(minX, self.contentSize.height / 2);  
		[self addChild:_thumb];  
	}  
	return self;  
}  

- (void)setValue:(float)newValue
{
	// set new value with sentinel
    if (newValue < 0)
    {
		newValue = 0;
    }
	
    if (newValue > 1.0) 
    {
		newValue = 1.0;
    }
	
    value = newValue;
	
	// Update thumb position for new value
    CGPoint pos = self.thumb.position;
    pos.x = minX + newValue * (maxX - minX);
    self.thumb.position = pos;
	
    [self sendActionsForControlEvents:CCControlEventValueChanged];    
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace: touchLocation];
    
    if (touchLocation.x < minX)
    {
        touchLocation.x = minX;
    } else if (touchLocation.x > maxX)
    {
        touchLocation.x = maxX;
    }
    
    return touchLocation;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch])
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

- (NSInteger)mouseDelegatePriority
{
	return kCCControlSliderPriority;
}

- (CGPoint)locationFromEvent:(NSEvent *) theEvent
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:theEvent];
    location = [self convertToNodeSpace: location];
    if (location.x < minX)
    {
        location.x = minX;
    } else if (location.x > maxX)
    {
        location.x = maxX;
    }
    
	return location;
}

- (BOOL)ccMouseDown:(NSEvent*)event
{
    if (![self isMouseInside:event])
    {
        return NO;
    }
	
    CGPoint location = [self locationFromEvent:event];
    
    [self sliderBegan:location];
    
    return YES;
}


- (BOOL)ccMouseDragged:(NSEvent*)event
{
	if (!self.thumb.isSelected)
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

#pragma mark CCControlSlider Private Methods

- (void)sliderBegan:(CGPoint)location
{
    [self.thumb selected];
    
    CGPoint pos = self.thumb.position;
    pos.x = location.x;
    self.thumb.position = pos;
    
    self.value = (pos.x - minX) / (maxX - minX);
}

- (void)sliderMoved:(CGPoint)location
{
    CGPoint pos = self.thumb.position;
    pos.x = MIN(location.x, maxX);
	pos.x = MAX(pos.x, minX );
    self.thumb.position = pos;
    
    self.value = (pos.x - minX) / (maxX - minX);
}

- (void)sliderEnded:(CGPoint)location
{
    if (self.thumb.isSelected)
    {
		[self.thumb unselected];
        
        self.value = (self.thumb.position.x - minX) / (maxX - minX);
    }
}

@end
