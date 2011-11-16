/*
 * CCControlButton.m
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

#import "CCControlButton.h"

#import "CCScale9Sprite.h"

enum
{
	kZoomActionTag = 0xCCCB0001,
};

@interface CCControlButton ()
/** Flag to know if the button is currently pushed.  */
@property (nonatomic, getter = isPushed) BOOL pushed;
/** Table of correspondence between the state and its title. */
@property (nonatomic, retain) NSMutableDictionary *titleDispatchTable;
/** Table of correspondence between the state and its title color. */
@property (nonatomic, retain) NSMutableDictionary *titleColorDispatchTable;
/** Table of correspondence between the state and its title label. */
@property (nonatomic, retain) NSMutableDictionary *titleLabelDispatchTable;
/** Table of correspondence between the state and the background sprite. */
@property (nonatomic, retain) NSMutableDictionary *backgroundSpriteDispatchTable;

/**
 * Updates the layout using the current state value.
 */
- (void)needsLayout;

@end

@implementation CCControlButton
@synthesize pushed = pushed_;
@synthesize titleLabel = titleLabel_;
@synthesize backgroundSprite = backgroundSprite_;
@synthesize titleDispatchTable = titleDispatchTable_;
@synthesize titleColorDispatchTable = titleColorDispatchTable_;
@synthesize titleLabelDispatchTable = titleLabelDispatchTable_;
@synthesize backgroundSpriteDispatchTable = backgroundSpriteDispatchTable_;
@synthesize opacity = opacity_;
@synthesize color = color_;
@synthesize opacityModifyRGB = opacityModifyRGB_;
@synthesize adjustBackgroundImage = adjustBackgroundImage_;
@synthesize currentTitle = currentTitle_;
@synthesize currentTitleColor = currentTitleColor_;

- (void)dealloc
{
    [backgroundSpriteDispatchTable_ release], backgroundSpriteDispatchTable_ = nil;
    [titleLabelDispatchTable_ release], titleLabelDispatchTable_ = nil;
    [titleColorDispatchTable_ release], titleColorDispatchTable_ = nil;
    [titleDispatchTable_ release], titleDispatchTable_ = nil;
    [backgroundSprite_ release], backgroundSprite_ = nil;
    [titleLabel_ release], titleLabel_ = nil;
    [currentTitle_ release], currentTitle_ = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark CCButton - Initializers

- (id)initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)label backgroundSprite:(CCScale9Sprite *)backgroundsprite
{
    if ((self = [super init]))
    {
        NSAssert(label, @"Label must not be nil.");
        NSAssert(backgroundsprite, @"Background sprite must not be nil.");

        self.pushed = NO;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		// Enabled the touch event
        self.isTouchEnabled = YES;
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        // Enabled the mouse event
		self.isMouseEnabled = YES;
#endif
        // Adjust the background image by default
        self.adjustBackgroundImage = YES;
        
        // Set the default anchor point
        self.isRelativeAnchorPoint = YES;
        self.anchorPoint = ccp (0.5f, 0.5f);

        // Set the nodes
        self.titleLabel = label;
        self.backgroundSprite = backgroundsprite;
        
        // Initialize the button state tables
        self.titleDispatchTable = [NSMutableDictionary dictionary];
        self.titleColorDispatchTable = [NSMutableDictionary dictionary];
        self.titleLabelDispatchTable = [NSMutableDictionary dictionary];
        self.backgroundSpriteDispatchTable = [NSMutableDictionary dictionary];
        
        // Set the default color and opacity
        [self setColor:ccc3(255, 255, 255)];
        [self setOpacity:255];
        [self setOpacityModifyRGB:YES];
        
        // Initialize the dispatch table
        [self setTitle:[label string] forState:CCControlStateNormal];
        [self setTitleColor:[label color] forState:CCControlStateNormal];
        [self setTitleLabel:label forState:CCControlStateNormal];
        [self setBackgroundSprite:backgroundsprite forState:CCControlStateNormal];
        
        // Layout update
        [self needsLayout];
    }
    return self;
}

+ (id)buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)label backgroundSprite:(CCScale9Sprite *)backgroundsprite
{
    return [[[self alloc] initWithLabel:label backgroundSprite:backgroundsprite] autorelease];
}

- (id)initWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(NSUInteger)fontsize
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:fontName fontSize:fontsize];
    
    return [self initWithLabel:label backgroundSprite:[CCScale9Sprite node]];
}

+ (id)buttonWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(NSUInteger)fontsize
{
    return [[[self alloc] initWithTitle:title fontName:fontName fontSize:fontsize] autorelease];
}

/** Initializes a button with a sprite in background. */
- (id)initWithBackgroundSprite:(CCScale9Sprite *)sprite
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:30];
    
    return [self initWithLabel:label backgroundSprite:sprite];
}

+ (id)buttonWithBackgroundSprite:(CCScale9Sprite *)sprite
{
    return [[[self alloc] initWithBackgroundSprite:sprite] autorelease];
}

#pragma mark Properties

- (void)setColor:(ccColor3B)color
{
    color_ = color;
    
    for (CCNode<CCRGBAProtocol> *child in self.children)
    {
        [child setColor:color];
    }
}

- (void)setOpacity:(GLubyte)opacity
{
    opacity_ = opacity;
    
    for (CCNode<CCRGBAProtocol> *child in self.children)
    {
        [child setOpacity:opacity];
    }
}

- (void)setOpacityModifyRGB:(BOOL)opacityModifyRGB
{
    opacityModifyRGB_ = opacityModifyRGB;
    
    for (CCNode<CCRGBAProtocol> *child in self.children)
    {
        [child setOpacityModifyRGB:opacityModifyRGB];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self needsLayout];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self needsLayout];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self needsLayout];

    CCAction *action = [self getActionByTag:kZoomActionTag];
    if (action)
    {
        [self stopAction:action];
    }
    
    float scaleValue = (highlighted && [self isEnabled] && ![self isSelected]) ? 1.1f : 1.0f;
    CCAction *zoomAction = [CCScaleTo actionWithDuration:0.05f scale:scaleValue];
    zoomAction.tag = kZoomActionTag;
    [self runAction:zoomAction];
}

- (void)setAdjustBackgroundImage:(BOOL)adjustBackgroundImage
{
    adjustBackgroundImage_ = adjustBackgroundImage;
    
    [self needsLayout];
}

#pragma mark -
#pragma mark CCButton Public Methods

- (NSString *)titleForState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    NSString *title = [titleDispatchTable_ objectForKey:stateNumber];
    
    if (title)
    {
        return title;
    }
    
    return [titleDispatchTable_ objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
}

- (void)setTitle:(NSString *)title forState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];

    [titleDispatchTable_ removeObjectForKey:stateNumber];
    
    if (title)
    {
        [titleDispatchTable_ setObject:title forKey:stateNumber];
    }
    
    // If the current state if equal to the given state we update the layout
    if (state_ == state)
    {
        [self needsLayout];
    }
}

- (ccColor3B)titleColorForState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    ccColor3B returnColor;
    NSValue *colorValue = [titleColorDispatchTable_ objectForKey:stateNumber];
    
    if (colorValue)
    {
        [colorValue getValue:&returnColor];
        
        return returnColor;
    }
    
    colorValue = [titleColorDispatchTable_ objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
    [colorValue getValue:&returnColor];
    
    return returnColor;
}

- (void)setTitleColor:(ccColor3B)color forState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    NSValue *colorValue = [NSValue valueWithBytes:&color objCType:@encode(ccColor3B)];
    
    [titleColorDispatchTable_ removeObjectForKey:stateNumber];
    [titleColorDispatchTable_ setObject:colorValue forKey:stateNumber];
    
    // If the current state if equal to the given state we update the layout
    if (state_ == state)
    {
        [self needsLayout];
    }
}

- (CCNode<CCLabelProtocol,CCRGBAProtocol> *)titleLabelForState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    CCNode<CCLabelProtocol,CCRGBAProtocol> *titleLabel = [titleLabelDispatchTable_ objectForKey:stateNumber];
    
    if (titleLabel)
    {
        return titleLabel;
    }
    
    return [titleLabelDispatchTable_ objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
}

- (void)setTitleLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)label forState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    CCNode<CCLabelProtocol,CCRGBAProtocol> *previousLabel = [titleLabelDispatchTable_ objectForKey:stateNumber];
    if (previousLabel)
    {
        [self removeChild:previousLabel cleanup:YES];
        [titleLabelDispatchTable_ removeObjectForKey:stateNumber];
    }
    
    [titleLabelDispatchTable_ setObject:label forKey:stateNumber];
    [label setVisible:NO];
    [label setAnchorPoint:ccp (0.5f, 0.5f)];
    [self addChild:label z:1];
    
    // If the current state if equal to the given state we update the layout
    if (state_ == state)
    {
        [self needsLayout];
    }
}

- (CCScale9Sprite *)backgroundSpriteForState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    CCScale9Sprite *backgroundSprite = [backgroundSpriteDispatchTable_ objectForKey:stateNumber];
    
    if (backgroundSprite)
    {
        return backgroundSprite;
    }
    
    return [backgroundSpriteDispatchTable_ objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
}

- (void)setBackgroundSprite:(CCScale9Sprite *)sprite forState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    CCScale9Sprite *previousBackgroundSprite = [backgroundSpriteDispatchTable_ objectForKey:stateNumber];
    if (previousBackgroundSprite)
    {
        [self removeChild:previousBackgroundSprite cleanup:YES];
        [backgroundSpriteDispatchTable_ removeObjectForKey:stateNumber];
    }
    
    [backgroundSpriteDispatchTable_ setObject:sprite forKey:stateNumber];
    [sprite setVisible:NO];
    [self addChild:sprite];
    
    // If the current state if equal to the given state we update the layout
    if (state_ == state)
    {
        [self needsLayout];
    }
}

#pragma mark CCButton Private Methods

- (void)needsLayout
{
    // Hide the background and the label
    [titleLabel_ setVisible:NO];
    [backgroundSprite_ setVisible:NO];
    
    // Update the label to match with the current state
    if (currentTitle_)
    {
        [currentTitle_ release], currentTitle_ = nil;
    }
    currentTitle_ = [[self titleForState:state_] retain];
    currentTitleColor_ = [self titleColorForState:state_];
    
    self.titleLabel = [self titleLabelForState:state_];
    [titleLabel_ setString:currentTitle_];
    [titleLabel_ setColor:currentTitleColor_];
    [titleLabel_ setPosition:ccp (self.contentSize.width / 2, self.contentSize.height / 2)];
    
    // Update the background sprite
    self.backgroundSprite = [self backgroundSpriteForState:state_];
    [backgroundSprite_ setPosition:ccp (self.contentSize.width / 2, self.contentSize.height / 2)];
    
    // Get the title label size
    CGSize titleLabelSize = [titleLabel_ boundingBox].size;
    
    // Adjust the background image if necessary
    if ([self doesAdjustBackgroundImage])
    {
        // Add the margins
        [backgroundSprite_ setContentSize:
         CGSizeMake(titleLabelSize.width + CCControlButtonMarginLR * 2, titleLabelSize.height + CCControlButtonMarginTB * 2)];
    } else
    {
        CGSize preferedSize = [backgroundSprite_ preferedSize];
        if (preferedSize.width <= 0)
        {
            preferedSize.width = titleLabelSize.width;
        }
        if (preferedSize.height <= 0)
        {
            preferedSize.height = titleLabelSize.height;
        }
        
        [backgroundSprite_ setContentSize:preferedSize];
    }
    
    // Set the content size
    CGRect maxRect = CGRectUnion([titleLabel_ boundingBox], [backgroundSprite_ boundingBox]);
    [self setContentSize:CGSizeMake(maxRect.size.width, maxRect.size.height)];
    
    [titleLabel_ setPosition:ccp (self.contentSize.width / 2, self.contentSize.height / 2)];
    [backgroundSprite_ setPosition:ccp (self.contentSize.width / 2, self.contentSize.height / 2)];
    
    // Make visible the background and the label
    [titleLabel_ setVisible:YES];
    [backgroundSprite_ setVisible:YES];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled])
    {
		return NO;
	}

    [self setHighlighted:YES];
    
    state_ = CCControlStateHighlighted;
    pushed_ = YES;
    
    [self sendActionsForControlEvents:CCControlEventTouchDown];
    
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isEnabled]
        || ![self isPushed]
        || [self isSelected])
    {
        if ([self isHighlighted])
        {
            [self setHighlighted:NO];
        }
        return;
    }
    
    BOOL isTouchMoveInside = [self isTouchInside:touch];
    if (isTouchMoveInside && ![self isHighlighted])
    {
        [self setHighlighted:YES];
        
        state_ = CCControlStateHighlighted;
        
        [self sendActionsForControlEvents:CCControlEventTouchDragEnter];
    } else if (isTouchMoveInside && [self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragInside];
    } else if (!isTouchMoveInside && [self isHighlighted])
    {
        [self setHighlighted:NO];
        
        state_ = CCControlStateNormal;
        
        [self sendActionsForControlEvents:CCControlEventTouchDragExit];
    } else if (!isTouchMoveInside && ![self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragOutside];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setHighlighted:NO];
    
    state_ = CCControlStateNormal;
    pushed_ = NO;
    
    if ([self isTouchInside:touch])
    {
        [self sendActionsForControlEvents:CCControlEventTouchUpInside];
    } else
    {
        [self sendActionsForControlEvents:CCControlEventTouchUpOutside];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setHighlighted:NO];
    
    state_ = CCControlStateNormal;
    pushed_ = NO;
    
    [self sendActionsForControlEvents:CCControlEventTouchCancel];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isMouseInside:event])
    {
        return NO;
    }

    [self setHighlighted:YES];

    state_ = CCControlStateHighlighted;
    pushed_ = YES;
    
    [self sendActionsForControlEvents:CCControlEventTouchDown];
    
    return YES;
}


- (BOOL)ccMouseDragged:(NSEvent *)event
{
	if (![self isEnabled]
        || ![self isPushed]
        || [self isSelected])
    {
        if ([self isHighlighted])
        {
            [self setHighlighted:NO];
        }
        return NO;
    }

    BOOL isMouseMoveInside = [self isMouseInside:event];
    if (isMouseMoveInside && ![self isHighlighted])
    {
        [self setHighlighted:YES];
        
        state_ = CCControlStateHighlighted;
        
        [self sendActionsForControlEvents:CCControlEventTouchDragEnter];
    } else if (isMouseMoveInside && [self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragInside];
    } else if (!isMouseMoveInside && [self isHighlighted])
    {
        [self setHighlighted:NO];
        
        state_ = CCControlStateNormal;
        
        [self sendActionsForControlEvents:CCControlEventTouchDragExit];
    } else if (!isMouseMoveInside && ![self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragOutside];
    }
    
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    [self setHighlighted:NO];
    
    state_ = CCControlStateNormal;
    pushed_ = NO;
    
    if ([self isMouseInside:event])
    {
        [self sendActionsForControlEvents:CCControlEventTouchUpInside];
    } else
    {
        [self sendActionsForControlEvents:CCControlEventTouchUpOutside];
    }
    
	return NO;
}

#endif

@end
