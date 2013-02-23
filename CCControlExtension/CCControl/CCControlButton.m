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
#import "ARCMacro.h"

enum
{
	kZoomActionTag = 0xCCCB0001,
};

@interface CCControlButton ()
/** Flag to know if the button is currently pushed.  */
@property (nonatomic, getter = isPushed) BOOL pushed;
/** Table of correspondence between the state and its title. */
@property (nonatomic, strong) NSMutableDictionary *titleDispatchTable;
/** Table of correspondence between the state and its title color. */
@property (nonatomic, strong) NSMutableDictionary *titleColorDispatchTable;
/** Table of correspondence between the state and its title label. */
@property (nonatomic, strong) NSMutableDictionary *titleLabelDispatchTable;
/** Table of correspondence between the state and the background sprite. */
@property (nonatomic, strong) NSMutableDictionary *backgroundSpriteDispatchTable;

@end

@implementation CCControlButton
@synthesize pushed                          = _pushed;
@synthesize titleLabel                      = _titleLabel;
@synthesize backgroundSprite                = _backgroundSprite;
@synthesize titleDispatchTable              = _titleDispatchTable;
@synthesize titleColorDispatchTable         = _titleColorDispatchTable;
@synthesize titleLabelDispatchTable         = _titleLabelDispatchTable;
@synthesize backgroundSpriteDispatchTable   = _backgroundSpriteDispatchTable;
@synthesize adjustBackgroundImage           = _adjustBackgroundImage;
@synthesize currentTitle                    = _currentTitle;
@synthesize currentTitleColor               = _currentTitleColor;
@synthesize zoomOnTouchDown                 = _zoomOnTouchDown;
@synthesize preferredSize                   = _preferredSize;
@synthesize marginLR                        = _marginLR;
@synthesize marginTB                        = _marginTB;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_backgroundSpriteDispatchTable);
    SAFE_ARC_RELEASE(_titleLabelDispatchTable);
    SAFE_ARC_RELEASE(_titleColorDispatchTable);
    SAFE_ARC_RELEASE(_titleDispatchTable);
    SAFE_ARC_RELEASE(_backgroundSprite);
    SAFE_ARC_RELEASE(_titleLabel);
    SAFE_ARC_RELEASE(_currentTitle);
    
    SAFE_ARC_SUPER_DEALLOC();
}

#pragma mark -
#pragma mark CCButton - Initializers

- (id)init
{
    return [self initWithLabel:[CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:12]
              backgroundSprite:SAFE_ARC_AUTORELEASE([[CCScale9Sprite alloc] init])];
}

- (id)initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)label backgroundSprite:(CCScale9Sprite *)backgroundsprite
{
    if ((self = [super init]))
    {
        NSAssert(label, @"Label must not be nil.");
        NSAssert(backgroundsprite, @"Background sprite must not be nil.");
        NSAssert([backgroundsprite isKindOfClass:[CCScale9Sprite class]], @"The background sprite must be kind of 'CCScale9Sprite' class.");
        
        self.pushed                         = NO;
        self.zoomOnTouchDown                = YES;
        
        // Adjust the background image by default
        self.adjustBackgroundImage          = YES;
        self.preferredSize                  = CGSizeZero;
        
        // Set the default anchor point
        self.ignoreAnchorPointForPosition   = NO;
        self.anchorPoint                    = ccp (0.5f, 0.5f);
        
        // Set the nodes    
        self.titleLabel                     = label;
        self.backgroundSprite               = backgroundsprite;
        
        // Initialize the button state tables
        self.titleDispatchTable             = [NSMutableDictionary dictionary];
        self.titleColorDispatchTable        = [NSMutableDictionary dictionary];
        self.titleLabelDispatchTable        = [NSMutableDictionary dictionary];
        self.backgroundSpriteDispatchTable  = [NSMutableDictionary dictionary];
        
        // Set the default color and opacity
        self.color                          = ccc3(255.0f, 255.0f, 255.0f);
        self.opacity                        = 255.0f;
        self.opacityModifyRGB               = YES;
        
        // Initialize the dispatch table
        [self setTitle:[label string]               forState:CCControlStateNormal];
        [self setTitleColor:[label color]           forState:CCControlStateNormal];
        [self setTitleLabel:label                   forState:CCControlStateNormal];
        [self setBackgroundSprite:backgroundsprite  forState:CCControlStateNormal];
        
        self.labelAnchorPoint               = ccp (0.5f, 0.5f);
        
        self.marginLR                       = CCControlButtonMarginLR;
        self.marginTB                       = CCControlButtonMarginTB;
        
        // Layout update
        [self needsLayout];
    }
    return self;
}

+ (id)buttonWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)label backgroundSprite:(CCScale9Sprite *)backgroundsprite
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithLabel:label backgroundSprite:backgroundsprite]);
}

- (id)initWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(NSUInteger)fontsize
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:fontName fontSize:fontsize];
    
    return [self initWithLabel:label backgroundSprite:[CCScale9Sprite node]];
}

+ (id)buttonWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(NSUInteger)fontsize
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithTitle:title fontName:fontName fontSize:fontsize]);
}

/** Initializes a button with a sprite in background. */
- (id)initWithBackgroundSprite:(CCScale9Sprite *)sprite
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:30];
    
    return [self initWithLabel:label backgroundSprite:sprite];
}

+ (id)buttonWithBackgroundSprite:(CCScale9Sprite *)sprite
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithBackgroundSprite:sprite]);
}

#pragma mark Properties

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted        = highlighted;
    
    CCAction *action    = [self getActionByTag:kZoomActionTag];
    if (action)
    {
        [self stopAction:action];
    }
    
    [self needsLayout];
    
    if (_zoomOnTouchDown)
    {
        float scaleValue        = (highlighted && [self isEnabled] && ![self isSelected]) ? 1.1f : 1.0f;
        CCAction *zoomAction    = [CCScaleTo actionWithDuration:0.05f scale:scaleValue];
        zoomAction.tag          = kZoomActionTag;
        [self runAction:zoomAction];
    }
}

- (void)setAdjustBackgroundImage:(BOOL)adjustBackgroundImage
{
    _adjustBackgroundImage = adjustBackgroundImage;
    
    [self needsLayout];
}

- (void)setPreferredSize:(CGSize)preferredSize
{
    if (preferredSize.width == 0 && preferredSize.height == 0)
    {
        _adjustBackgroundImage  = YES;
    }
    else
    {
        _adjustBackgroundImage = NO;
    
        for (id key in _backgroundSpriteDispatchTable)
        {
            CCScale9Sprite* sprite = [_backgroundSpriteDispatchTable objectForKey:key];
            [sprite setPreferredSize:preferredSize];
        }
    }
    
    _preferredSize   = preferredSize;
    
    [self needsLayout];
}

- (void) setLabelAnchorPoint:(CGPoint)labelAnchorPoint
{
    _labelAnchorPoint = labelAnchorPoint;
    
    _titleLabel.anchorPoint = labelAnchorPoint;
}

- (CGPoint) labelAnchorPoint
{
    return _labelAnchorPoint;
}

#pragma mark -
#pragma mark CCButton Public Methods

- (NSString *)titleForState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    NSString *title = [_titleDispatchTable objectForKey:stateNumber];
    
    if (title)
    {
        return title;
    }
    
    return [_titleDispatchTable objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
}

- (void)setTitle:(NSString *)title forState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    [_titleDispatchTable removeObjectForKey:stateNumber];
    
    if (title)
    {
        [_titleDispatchTable setObject:title forKey:stateNumber];
    }
    
    // If the current state if equal to the given state we update the layout
    if (_state == state)
    {
        [self needsLayout];
    }
}

- (ccColor3B)titleColorForState:(CCControlState)state
{
    NSNumber *stateNumber   = [NSNumber numberWithLong:state];
    
    ccColor3B returnColor;
    NSValue *colorValue     = [_titleColorDispatchTable objectForKey:stateNumber];
    
    if (colorValue)
    {
        [colorValue getValue:&returnColor];
        
        return returnColor;
    }
    
    colorValue = [_titleColorDispatchTable objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
    [colorValue getValue:&returnColor];
    
    return returnColor;
}

- (void)setTitleColor:(ccColor3B)color forState:(CCControlState)state
{
    NSNumber *stateNumber   = [NSNumber numberWithLong:state];
    
    NSValue *colorValue     = [NSValue valueWithBytes:&color objCType:@encode(ccColor3B)];
    
    [_titleColorDispatchTable removeObjectForKey:stateNumber];
    [_titleColorDispatchTable setObject:colorValue forKey:stateNumber];
    
    // If the current state if equal to the given state we update the layout
    if (_state == state)
    {
        [self needsLayout];
    }
}

- (CCNode<CCLabelProtocol,CCRGBAProtocol> *)titleLabelForState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    CCNode<CCLabelProtocol,CCRGBAProtocol> *titleLabel = [_titleLabelDispatchTable objectForKey:stateNumber];
    
    if (titleLabel)
    {
        return titleLabel;
    }
    
    return [_titleLabelDispatchTable objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
}

- (void)setTitleLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol> *)label forState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    CCNode<CCLabelProtocol,CCRGBAProtocol> *previousLabel = [_titleLabelDispatchTable objectForKey:stateNumber];
    if (previousLabel)
    {
        [self removeChild:previousLabel cleanup:YES];
        [_titleLabelDispatchTable removeObjectForKey:stateNumber];
    }
    
    [_titleLabelDispatchTable setObject:label forKey:stateNumber];
    [label setVisible:NO];
    [label setAnchorPoint:ccp (0.5f, 0.5f)];
    [self addChild:label z:1];
    
    // If the current state if equal to the given state we update the layout
    if (_state == state)
    {
        [self needsLayout];
    }
}

- (void)setTitleBMFont:(NSString*)fntFile forState:(CCControlState)state
{
    NSString* title = [self titleForState:state];
    if (!title) title = @"";
    
    [self setTitleLabel:[CCLabelBMFont labelWithString:title fntFile:fntFile] forState:state];
}

- (NSString*)titleBMFontForState:(CCControlState)state
{
    CCNode<CCLabelProtocol>* label = [self titleLabelForState:state];
    if ([label isKindOfClass:[CCLabelBMFont class]])
    {
        CCLabelBMFont* bmLabel = (CCLabelBMFont *)label;
        return [bmLabel fntFile];
    } else
    {
        return @"";
    }
}

- (void)setTitleTTF:(NSString *)fontName forState:(CCControlState)state
{
    NSString* title = [self titleForState:state];
    if (!title) title = @"";
    
    [self setTitleLabel:[CCLabelTTF labelWithString:title fontName:fontName fontSize:12] forState:state];
}

- (NSString*) titleTTFForState:(CCControlState)state
{
    CCNode<CCLabelProtocol>* label = [self titleLabelForState:state];
    if (!label) return NULL;
    if ([label isKindOfClass:[CCLabelTTF class]])
    {
        CCLabelTTF* labelTTF = (CCLabelTTF*)label;
        return [labelTTF fontName];
    }
    return NULL;
}

- (void) setTitleTTFSize:(float)size forState:(CCControlState)state
{
    CCNode<CCLabelProtocol>* label = [self titleLabelForState:state];
    if (label && [label isKindOfClass:[CCLabelTTF class]])
    {
        CCLabelTTF* labelTTF = (CCLabelTTF*)label;
        [labelTTF setFontSize:size];
    }
}

- (float) titleTTFSizeForState:(CCControlState)state
{
    CCNode<CCLabelProtocol>* label = [self titleLabelForState:state];
    if (label && [label isKindOfClass:[CCLabelTTF class]])
    {
        CCLabelTTF* labelTTF = (CCLabelTTF*)label;
        return [labelTTF fontSize];
    }
    return 0;
}

- (CCScale9Sprite *)backgroundSpriteForState:(CCControlState)state
{
    NSNumber *stateNumber = [NSNumber numberWithLong:state];
    
    CCScale9Sprite *backgroundSprite = [_backgroundSpriteDispatchTable objectForKey:stateNumber];
    
    if (backgroundSprite)
    {
        return backgroundSprite;
    }
    
    return [_backgroundSpriteDispatchTable objectForKey:[NSNumber numberWithInt:CCControlStateNormal]];
}

- (void)setBackgroundSprite:(CCScale9Sprite *)sprite forState:(CCControlState)state
{
    CGSize oldPreferredSize = _preferredSize;
    
    NSNumber *stateNumber                       = [NSNumber numberWithLong:state];
    
    CCScale9Sprite *previousBackgroundSprite    = [_backgroundSpriteDispatchTable objectForKey:stateNumber];
    if (previousBackgroundSprite)
    {
        [self removeChild:previousBackgroundSprite cleanup:YES];
        [_backgroundSpriteDispatchTable removeObjectForKey:stateNumber];
    }
    
    [_backgroundSpriteDispatchTable setObject:sprite forKey:stateNumber];
    [sprite setVisible:NO];
    [self addChild:sprite];
    
    if (_preferredSize.width != 0 || _preferredSize.height != 0)
    {
        if (CGSizeEqualToSize(oldPreferredSize, _preferredSize))
        {
            // Force update of preferred size
            [sprite setPreferredSize:CGSizeMake(oldPreferredSize.width+1, oldPreferredSize.height+1)];
        }
        
        [sprite setPreferredSize:_preferredSize];
    }
    
    // If the current state if equal to the given state we update the layout
    if (_state == state)
    {
        [self needsLayout];
    }
}

- (void)setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state
{
    CCScale9Sprite* sprite = [CCScale9Sprite spriteWithSpriteFrame:spriteFrame];
    [self setBackgroundSprite:sprite forState:state];
}

- (void)setMarginLR:(float)marginLR
{
    _marginLR   = marginLR;
    [self needsLayout];
}

- (void)setMarginTB:(float)marginTB
{
    _marginTB   = marginTB;
    [self needsLayout];
}

#pragma mark CCButton Private Methods

- (void)needsLayout
{
    // Hide the background and the label
    _titleLabel.visible         = NO;
    _backgroundSprite.visible   = NO;
    
    // Update anchor points of all labels
    self.labelAnchorPoint = _labelAnchorPoint;
    
    // Update the label to match with the current state
    if (_currentTitle)
    {
        SAFE_ARC_RELEASE(_currentTitle);
    }
    _currentTitle               = SAFE_ARC_RETAIN([self titleForState:_state]);
    _currentTitleColor          = [self titleColorForState:_state];
    
    self.titleLabel             = [self titleLabelForState:_state];
    if (_currentTitle)
    {
        _titleLabel.string          = _currentTitle;
    }
    _titleLabel.color           = _currentTitleColor;
    _titleLabel.position        = ccp (self.contentSize.width / 2, self.contentSize.height / 2);
    
    // Update the background sprite
    self.backgroundSprite       = [self backgroundSpriteForState:_state];
    _backgroundSprite.position  = ccp (self.contentSize.width / 2, self.contentSize.height / 2);

    // Get the title label size
    CGSize titleLabelSize       = [_titleLabel boundingBox].size;
    
    // Adjust the background image if necessary
    if ([self doesAdjustBackgroundImage])
    {
        // Add the margins
        [_backgroundSprite setContentSize:
         CGSizeMake(titleLabelSize.width + _marginLR * 2, titleLabelSize.height + _marginTB * 2)];
    } else
    {
        CGSize preferredSize     = [_backgroundSprite preferredSize];

        if (preferredSize.width <= 0)
        {
            preferredSize.width = titleLabelSize.width;
        }
        if (preferredSize.height <= 0)
        {
            preferredSize.height = titleLabelSize.height;
        }
        
        [_backgroundSprite setContentSize:preferredSize];
    }
    
    // Set the content size
    CGRect maxRect              = CGRectUnion([_titleLabel boundingBox], [_backgroundSprite boundingBox]);
    self.contentSize            = CGSizeMake(maxRect.size.width, maxRect.size.height);
    
    _titleLabel.position        = ccp (self.contentSize.width / 2, self.contentSize.height / 2);
    _backgroundSprite.position  = ccp (self.contentSize.width / 2, self.contentSize.height / 2);
    
    // Make visible the background and the label
    _titleLabel.visible         = YES;
    _backgroundSprite.visible   = YES;
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
    {
		return NO;
	}
    
    _state              = CCControlStateHighlighted;
    _pushed             = YES;
    self.highlighted    = YES;
    
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
        _state = CCControlStateHighlighted;
        
        [self setHighlighted:YES];
        
        [self sendActionsForControlEvents:CCControlEventTouchDragEnter];
    } else if (isTouchMoveInside && [self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragInside];
    } else if (!isTouchMoveInside && [self isHighlighted])
    {
        _state = CCControlStateNormal;
        
        [self setHighlighted:NO];
        
        [self sendActionsForControlEvents:CCControlEventTouchDragExit];
    } else if (!isTouchMoveInside && ![self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragOutside];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _state              = CCControlStateNormal;
    _pushed             = NO;
    self.highlighted    = NO;
    
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
    _state              = CCControlStateNormal;
    _pushed             = NO;
    self.highlighted    = NO;
    
    [self sendActionsForControlEvents:CCControlEventTouchCancel];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isMouseInside:event]
        || ![self visible]
        || ![self hasVisibleParents])
    {
        return NO;
    }
    
    _state              = CCControlStateHighlighted;
    _pushed             = YES;
    self.highlighted    = YES;
    
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
        _state = CCControlStateHighlighted;
        
        [self setHighlighted:YES];
        
        [self sendActionsForControlEvents:CCControlEventTouchDragEnter];
    } else if (isMouseMoveInside && [self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragInside];
    } else if (!isMouseMoveInside && [self isHighlighted])
    {
        _state = CCControlStateNormal;
        
        [self setHighlighted:NO];
        
        [self sendActionsForControlEvents:CCControlEventTouchDragExit];
    } else if (!isMouseMoveInside && ![self isHighlighted])
    {
        [self sendActionsForControlEvents:CCControlEventTouchDragOutside];
    }
    
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    _state              = CCControlStateNormal;
    _pushed             = NO;
    self.highlighted    = NO;
    
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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSArray* chunks = [key componentsSeparatedByString:@"|"];
    if ([chunks count] == 2)
    {
        NSString* keyChunk = [chunks objectAtIndex:0];
        int state = [[chunks objectAtIndex:1] intValue];
        
        if ([keyChunk isEqualToString:@"title"])
        {
            [self setTitle:value forState:state];
        }
        else if ([keyChunk isEqualToString:@"backgroundSpriteFrame"])
        {
            [self setBackgroundSpriteFrame:value forState:state];
        }
        else if ([keyChunk isEqualToString:@"titleColor"])
        {
            ccColor3B c;
            [value getValue:&c];
            [self setTitleColor:c forState:state];
        }
        else if ([keyChunk isEqualToString:@"titleBMFont"])
        {
            [self setTitleBMFont:value forState:state];
        }
        else if ([keyChunk isEqualToString:@"titleTTF"])
        {
            NSLog(@"setTitleTTF: %@ forState:%d", value, state);
            
            [self setTitleTTF:value forState:state];
        }
        else if ([keyChunk isEqualToString:@"titleTTFSize"])
        {
            [self setTitleTTFSize:[value floatValue] forState:state];
        }
        else
        {
            [super setValue:value forUndefinedKey:key];
        }
    }
    else
    {
        [super setValue:value forUndefinedKey:key];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSArray* chunks = [key componentsSeparatedByString:@"|"];
    if ([chunks count] == 2)
    {
        NSString* keyChunk = [chunks objectAtIndex:0];
        int state = [[chunks objectAtIndex:1] intValue];
        
        if ([keyChunk isEqualToString:@"title"])
        {
            return [self titleForState:state];
        }
        else if ([keyChunk isEqualToString:@"titleColor"])
        {
            ccColor3B c = [self titleColorForState:state];
            return [NSValue value:&c withObjCType:@encode(ccColor3B)];
        }
        else if ([keyChunk isEqualToString:@"titleBMFont"])
        {
            return [self titleBMFontForState:state];
        }
        else if ([keyChunk isEqualToString:@"titleTTF"])
        {
            return [self titleTTFForState:state];
        }
        else if ([keyChunk isEqualToString:@"titleTTFSize"])
        {
            return [NSNumber numberWithFloat:[self titleTTFSizeForState:state]];
        }
        else
        {
            return [super valueForUndefinedKey:key];
        }
    }
    else
    {
        return [super valueForUndefinedKey:key];
    }
}

@end
