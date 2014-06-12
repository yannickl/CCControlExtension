//
// Scale9Sprite.m
//
// Creates a 9-slice sprite.
//

#import "CCScale9Sprite.h"
#import "ARCMacro.h"

enum positions
{
    pCentre = 0,
    pTop,
    pLeft,
    pRight,
    pBottom,
    pTopRight,
    pTopLeft,
    pBottomRight,
    pBottomLeft
};

@interface CCScale9Sprite ()

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect capInsets:(CGRect)capInsets;
- (void)updateWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect rotated:(BOOL)rotated capInsets:(CGRect)capInsets;
- (void)updatePosition;

@end

@implementation CCScale9Sprite
@synthesize originalSize  = _originalSize;
@synthesize capInsets     = _capInsets;
@synthesize insetTop      = _insetTop;
@synthesize insetLeft     = _insetLeft;
@synthesize insetBottom   = _insetBottom;
@synthesize insetRight    = _insetRight;
@synthesize preferredSize = _preferredSize;

// CCRGBAProtocol (v2.1)
@synthesize opacity               = _opacity;
@synthesize displayedOpacity      = _displayedOpacity;
@synthesize color                 = _color;
@synthesize displayedColor        = _displayedColor;
@synthesize opacityModifyRGB      = _opacityModifyRGB;
@synthesize cascadeColorEnabled   = _cascadeColorEnabled;
@synthesize cascadeOpacityEnabled = _cascadeOpacityEnabled;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_topLeft);
    SAFE_ARC_RELEASE(_top);
    SAFE_ARC_RELEASE(_topRight);
    SAFE_ARC_RELEASE(_left);
    SAFE_ARC_RELEASE(_centre);
    SAFE_ARC_RELEASE(_right);
    SAFE_ARC_RELEASE(_bottomLeft);
    SAFE_ARC_RELEASE(_bottom);
    SAFE_ARC_RELEASE(_bottomRight);
    SAFE_ARC_RELEASE(_scale9Image);
    
    SAFE_ARC_SUPER_DEALLOC();
}

#pragma mark Constructor - Initializers

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect rotated:(BOOL)rotated capInsets:(CGRect)capInsets
{
    if ((self = [super init])) {
        if (batchnode) {
            [self updateWithBatchNode:batchnode rect:rect rotated:rotated capInsets:capInsets];
            self.anchorPoint = ccp(0.5f, 0.5f);
        }
        _positionsAreDirty = YES;
    }
    return self;
}

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    return [self initWithBatchNode:batchnode rect:rect rotated:NO capInsets:capInsets];
}

- (id)initWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithFile:file capacity:9];
    
    return [self initWithBatchNode:batchnode rect:rect capInsets:capInsets];
}

+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithFile:file rect:rect capInsets:capInsets]);
}

- (id)initWithFile:(NSString *)file rect:(CGRect)rect
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:rect capInsets:CGRectZero];
}

+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithFile:file rect:rect]);
}

- (id)initWithFile:(NSString *)file capInsets:(CGRect)capInsets
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:CGRectZero capInsets:capInsets];
}

+ (id)spriteWithFile:(NSString *)file capInsets:(CGRect)capInsets
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithFile:file capInsets:capInsets]);
}

- (id)initWithFile:(NSString *)file
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:CGRectZero];
}

+ (id)spriteWithFile:(NSString *)file
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithFile:file]);
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets
{
    NSAssert(spriteFrame != nil, @"Sprite frame must be not nil");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture capacity:9];
    
    return [self initWithBatchNode:batchnode rect:spriteFrame.rect rotated:spriteFrame.rotated capInsets:capInsets];
}

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithSpriteFrame:spriteFrame capInsets:capInsets]);
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    NSAssert(spriteFrame != nil, @"Invalid spriteFrame for sprite");
    
    return [self initWithSpriteFrame:spriteFrame capInsets:CGRectZero];
}

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithSpriteFrame:spriteFrame]);
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
    
    return [self initWithSpriteFrame:frame capInsets:capInsets];
}

+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithSpriteFrameName:spriteFrameName capInsets:capInsets]);
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    return [self initWithSpriteFrameName:spriteFrameName capInsets:CGRectZero];
}

+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithSpriteFrameName:spriteFrameName]);
}

- (id)init
{
    return [self initWithBatchNode:NULL rect:CGRectZero capInsets:CGRectZero];
}

- (void) updateWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect rotated:(BOOL)rotated capInsets:(CGRect)capInsets
{
    GLubyte opacity = opacity;
    ccColor3B color = _color;
    
    // Release old sprites
    [self removeAllChildrenWithCleanup:YES];
    
    SAFE_ARC_RELEASE(_centre);
    SAFE_ARC_RELEASE(_top);
    SAFE_ARC_RELEASE(_topLeft);
    SAFE_ARC_RELEASE(_topRight);
    SAFE_ARC_RELEASE(_left);
    SAFE_ARC_RELEASE(_right);
    SAFE_ARC_RELEASE(_bottomLeft);
    SAFE_ARC_RELEASE(_bottom);
    SAFE_ARC_RELEASE(_bottomRight);
    
    if (_scale9Image != batchnode) {
        SAFE_ARC_RELEASE(_scale9Image);
        _scale9Image = SAFE_ARC_RETAIN(batchnode);
    }
    
    [_scale9Image removeAllChildrenWithCleanup:YES];
    
    _capInsets          = capInsets;
    _spriteFrameRotated = rotated;
    
    // If there is no given rect
    if (CGRectEqualToRect(rect, CGRectZero)) {
        // Get the texture size as original
        CGSize textureSize = [[[_scale9Image textureAtlas] texture] contentSize];
        rect               = CGRectMake(0, 0, textureSize.width, textureSize.height);
    }
    
    // Set the given rect's size as original size
    _spriteRect        = rect;
    _originalSize      = rect.size;
    _preferredSize     = _originalSize;
    _capInsetsInternal = capInsets;
    
    // Get the image edges
    float l = rect.origin.x;
    float t = rect.origin.y;
    float h = rect.size.height;
    float w = rect.size.width;
    
    // If there is no specified center region
    if (CGRectEqualToRect(_capInsetsInternal, CGRectZero)) {
        // Apply the 3x3 grid format
        if (rotated) {
            _capInsetsInternal = CGRectMake(l+h/3, t+w/3, w/3, h/3);
        }
        else {
            _capInsetsInternal  = CGRectMake(l+w/3, t+h/3, w/3, h/3);
        }
    }
    
    // Set up the images
    if (rotated) {
        // Sprite is rotated
        _centre      = [[CCSprite alloc] initWithTexture:_scale9Image.texture rect:_capInsetsInternal rotated:YES];
        _bottom      = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(l,
                                                                    _capInsetsInternal.origin.y,
                                                                    _capInsetsInternal.size.width,
                                                                    _capInsetsInternal.origin.x - l)
                                                 rotated:rotated];
        _top         = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.height,
                                                                    _capInsetsInternal.origin.y,
                                                                    _capInsetsInternal.size.width,
                                                                    h - _capInsetsInternal.size.height - (_capInsetsInternal.origin.x - l))
                                                 rotated:rotated];
        _right       = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x,
                                                                    _capInsetsInternal.origin.y+_capInsetsInternal.size.width,
                                                                    w - (_capInsetsInternal.origin.y-t)-_capInsetsInternal.size.width,
                                                                    _capInsetsInternal.size.height)
                                                 rotated:rotated];
        _left        = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x,
                                                                    t,
                                                                    _capInsetsInternal.origin.y - t,
                                                                    _capInsetsInternal.size.height)
                                                 rotated:rotated];
        _topRight    = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.height,
                                                                    _capInsetsInternal.origin.y + _capInsetsInternal.size.width,
                                                                    w - (_capInsetsInternal.origin.y-t)-_capInsetsInternal.size.width,
                                                                    h - _capInsetsInternal.size.height - (_capInsetsInternal.origin.x - l))
                                                 rotated:rotated];
        _topLeft     = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.height,
                                                                    t,
                                                                    _capInsetsInternal.origin.y - t,
                                                                    h - _capInsetsInternal.size.height - (_capInsetsInternal.origin.x - l))
                                                 rotated:rotated];
        _bottomRight = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(l,
                                                                    _capInsetsInternal.origin.y + _capInsetsInternal.size.width,
                                                                    w - (_capInsetsInternal.origin.y-t)-_capInsetsInternal.size.width,
                                                                    _capInsetsInternal.origin.x - l)
                                                 rotated:rotated];
        _bottomLeft  = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(l,
                                                                    t,
                                                                    _capInsetsInternal.origin.y - t,
                                                                    _capInsetsInternal.origin.x - l)
                                                 rotated:rotated];
    }
    else {
        // Sprite is not rotated
        _centre      = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:_capInsetsInternal
                                                 rotated:rotated];
        _top         = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x,
                                                                    t,
                                                                    _capInsetsInternal.size.width,
                                                                    _capInsetsInternal.origin.y - t)
                                                 rotated:rotated];
        _bottom      = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x,
                                                                    _capInsetsInternal.origin.y + _capInsetsInternal.size.height,
                                                                    _capInsetsInternal.size.width,
                                                                    h - (_capInsetsInternal.origin.y - t + _capInsetsInternal.size.height))
                                                 rotated:rotated];
        _left        = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(l,
                                                                    _capInsetsInternal.origin.y,
                                                                    _capInsetsInternal.origin.x - l,
                                                                    _capInsetsInternal.size.height)
                                                 rotated:rotated
                        ];
        _right       = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.width,
                                                                    _capInsetsInternal.origin.y,
                                                                    w - (_capInsetsInternal.origin.x - l + _capInsetsInternal.size.width),
                                                                    _capInsetsInternal.size.height)
                                                 rotated:rotated];
        _topLeft     = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(l,
                                                                    t,
                                                                    _capInsetsInternal.origin.x - l,
                                                                    _capInsetsInternal.origin.y - t)
                                                 rotated:rotated];
        _topRight    = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.width,
                                                                    t,
                                                                    w - (_capInsetsInternal.origin.x - l + _capInsetsInternal.size.width),
                                                                    _capInsetsInternal.origin.y - t)
                                                 rotated:rotated];
        _bottomLeft  = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(l,
                                                                    _capInsetsInternal.origin.y + _capInsetsInternal.size.height,
                                                                    _capInsetsInternal.origin.x - l,
                                                                    h - (_capInsetsInternal.origin.y - t + _capInsetsInternal.size.height))
                                                 rotated:rotated];
        _bottomRight = [[CCSprite alloc] initWithTexture:_scale9Image.texture
                                                    rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.width,
                                                                    _capInsetsInternal.origin.y + _capInsetsInternal.size.height,
                                                                    w - (_capInsetsInternal.origin.x - l + _capInsetsInternal.size.width),
                                                                    h - (_capInsetsInternal.origin.y - t + _capInsetsInternal.size.height))
                                                 rotated:rotated];
    }
    
    // Add images as children of scale9Image
    [_scale9Image addChild:_centre z:0 tag:pCentre];
    [_scale9Image addChild:_top z:1 tag:pTop];
    [_scale9Image addChild:_bottom z:1 tag:pBottom];
    [_scale9Image addChild:_left z:1 tag:pLeft];
    [_scale9Image addChild:_right z:1 tag:pRight];
    [_scale9Image addChild:_topLeft z:2 tag:pTopLeft];
    [_scale9Image addChild:_topRight z:2 tag:pTopRight];
    [_scale9Image addChild:_bottomLeft z:2 tag:pBottomLeft];
    [_scale9Image addChild:_bottomRight z:2 tag:pBottomRight];
    
    [self setContentSize:rect.size];
    [self addChild:_scale9Image];
    
    if (_spritesGenerated) {
        // Restore color and opacity
        self.opacity = opacity;
        self.color = color;
    }
    
    _spritesGenerated = YES;
}

#pragma mark Properties

- (void)setContentSize:(CGSize)size
{
    [super setContentSize:size];
    
    _positionsAreDirty  = YES;
}

- (void)updatePosition
{
    CGSize size = self.contentSize;
    
    float sizableWidth  = size.width - _topLeft.contentSize.width - _topRight.contentSize.width;
    float sizableHeight = size.height - _topLeft.contentSize.height - _bottomRight.contentSize.height;
    
    float scaleLeftFactor   = 1;
    float scaleCenterFactor = (sizableWidth / _centre.contentSize.width);
    float scaleRightFactor  = 1;
    float scaleTopFactor    = 1;
    float scaleMiddleFactor = (sizableHeight / _centre.contentSize.height);
    float scaleBottomFactor = 1;

    if (sizableWidth < 0 || sizableHeight < 0) {
        float topProportion    =  (_originalSize.height - _capInsetsInternal.origin.y - _capInsetsInternal.size.height) / _originalSize.height;
        float bottomProportion = _capInsetsInternal.origin.y / _originalSize.height;
        float leftProportion   = _capInsetsInternal.origin.x / _originalSize.width;
        float rightProportion  = (_originalSize.width - _capInsetsInternal.origin.x - _capInsetsInternal.size.width) / _originalSize.width;
        
        if (sizableWidth < 0) {
            scaleLeftFactor   = (size.width * topProportion) / _left.contentSize.width;
            scaleCenterFactor = (size.width * (1.0f - leftProportion - rightProportion)) / _centre.contentSize.width;
            scaleRightFactor  = (size.width * rightProportion) / _right.contentSize.width;
        }
        
        if (sizableHeight < 0) {
            scaleTopFactor    = (size.height * topProportion) / _top.contentSize.height;
            scaleMiddleFactor = (size.height * (1.0f - topProportion - bottomProportion)) / _centre.contentSize.height;
            scaleBottomFactor = (size.height * bottomProportion) / _bottom.contentSize.height;
        }
    }

    // Computes the sizes
    float centerWidth  = _centre.contentSize.width * scaleCenterFactor;
    float leftWidth    = _left.contentSize.width * scaleLeftFactor;
    float middleHeight = _centre.contentSize.height * scaleMiddleFactor;
    float bottomHeight = _bottom.contentSize.height * scaleBottomFactor;

    // Apply the scales
    _topLeft.scaleX     = scaleLeftFactor;
    _topLeft.scaleY     = scaleTopFactor;
    _top.scaleX         = scaleCenterFactor;
    _top.scaleY         = scaleTopFactor;
    _topRight.scaleX    = scaleRightFactor;
    _topRight.scaleY    = scaleTopFactor;
    _left.scaleX        = scaleLeftFactor;
    _left.scaleY        = scaleMiddleFactor;
    _centre.scaleX      = scaleCenterFactor;
    _centre.scaleY      = scaleMiddleFactor;
    _right.scaleX       = scaleRightFactor;
    _right.scaleY       = scaleMiddleFactor;
    _bottomLeft.scaleX  = scaleLeftFactor;
    _bottomLeft.scaleY  = scaleBottomFactor;
    _bottom.scaleX      = scaleCenterFactor;
    _bottom.scaleY      = scaleBottomFactor;
    _bottomRight.scaleX = scaleRightFactor;
    _bottomRight.scaleY = scaleBottomFactor;
    
    // Set anchor points
    _bottomLeft.anchorPoint  = ccp(0,0);
    _bottomRight.anchorPoint = ccp(0,0);
    _topLeft.anchorPoint     = ccp(0,0);
    _topRight.anchorPoint    = ccp(0,0);
    _left.anchorPoint        = ccp(0,0);
    _right.anchorPoint       = ccp(0,0);
    _top.anchorPoint         = ccp(0,0);
    _bottom.anchorPoint      = ccp(0,0);
    _centre.anchorPoint      = ccp(0,0);
    
    // Set positions
    _bottomLeft.position  = ccp(0,0);
    _bottomRight.position = ccp(leftWidth + centerWidth, 0);
    _topLeft.position     = ccp(0, bottomHeight + middleHeight);
    _topRight.position    = ccp(leftWidth + centerWidth, bottomHeight + middleHeight);
    _left.position        = ccp(0, bottomHeight);
    _right.position       = ccp(leftWidth + centerWidth, bottomHeight);
    _bottom.position      = ccp(leftWidth, 0);
    _top.position         = ccp(leftWidth, bottomHeight + middleHeight);
    _centre.position      = ccp(leftWidth, bottomHeight);
}

- (void)setPreferredSize:(CGSize)preferredSize
{
    self.contentSize = preferredSize;
    _preferredSize   = preferredSize;
}

#pragma mark CCRGBAProtocol

- (void)setColor:(ccColor3B)color
{
    _color = color;
    
    for (CCNode<CCRGBAProtocol> *child in _scale9Image.children) {
        [child setColor:color];
    }
}

- (void)setOpacity:(GLubyte)opacity
{
    _opacity = opacity;
    
    for (CCNode<CCRGBAProtocol> *child in _scale9Image.children) {
        [child setOpacity:opacity];
    }
}

- (void)setOpacityModifyRGB:(BOOL)boolean
{
    _opacityModifyRGB = boolean;
    
    for (CCNode<CCRGBAProtocol> *child in _scale9Image.children) {
        [child setOpacityModifyRGB:boolean];
    }
}

#if COCOS2D_VERSION >= 0x00020100

- (void)updateDisplayedOpacity:(GLubyte)parentOpacity
{
	_displayedOpacity = _realOpacity * parentOpacity/255.0;
    
    if (_cascadeOpacityEnabled) {
        id<CCRGBAProtocol> item;
        
        CCARRAY_FOREACH(self.children, item) {
            if ([item conformsToProtocol:@protocol(CCRGBAProtocol)]) {
                [item updateDisplayedOpacity:_displayedOpacity];
            }
        }
    }
}

- (void)updateDisplayedColor:(ccColor3B)parentColor
{
	_displayedColor.r = _realColor.r * parentColor.r/255.0;
	_displayedColor.g = _realColor.g * parentColor.g/255.0;
	_displayedColor.b = _realColor.b * parentColor.b/255.0;
    
    if (_cascadeColorEnabled) {
        id<CCRGBAProtocol> item;
        
        CCARRAY_FOREACH(self.children, item) {
            if ([item conformsToProtocol:@protocol(CCRGBAProtocol)]) {
                [item updateDisplayedColor:_displayedColor];
            }
        }
    }
}

#endif

#pragma mark Properties

- (void)setSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture capacity:9];
    [self updateWithBatchNode:batchnode rect:spriteFrame.rect rotated:spriteFrame.rotated capInsets:CGRectZero];
    
    // Reset insets
    _insetLeft   = 0;
    _insetTop    = 0;
    _insetRight  = 0;
    _insetBottom = 0;
}

- (void)setCapInsets:(CGRect)capInsets
{
    CGSize contentSize = self.contentSize;
    [self updateWithBatchNode:_scale9Image rect:_spriteRect rotated:_spriteFrameRotated capInsets:capInsets];
    [self setContentSize:contentSize];
}

- (void) updateCapInset_
{
    CGRect insets;
    
    if (_insetLeft == 0 && _insetTop == 0 && _insetRight == 0 && _insetBottom == 0) {
        insets = CGRectZero;
    }
    else {
        if (_spriteFrameRotated) {
            insets = CGRectMake(_spriteRect.origin.x + _insetBottom,
                                _spriteRect.origin.y + _insetLeft,
                                _spriteRect.size.width - _insetRight - _insetLeft,
                                _spriteRect.size.height - _insetTop - _insetBottom);
        }
        else {
            insets = CGRectMake(_spriteRect.origin.x + _insetLeft,
                                _spriteRect.origin.y + _insetTop,
                                _spriteRect.size.width - _insetLeft - _insetRight,
                                _spriteRect.size.height - _insetTop - _insetBottom);
        }
    }
    [self setCapInsets:insets];
}

- (void) setInsetLeft:(float)insetLeft
{
    _insetLeft = insetLeft;
    [self updateCapInset_];
}

- (void) setInsetTop:(float)insetTop
{
    _insetTop = insetTop;
    [self updateCapInset_];
}

- (void) setInsetRight:(float)insetRight
{
    _insetRight = insetRight;
    [self updateCapInset_];
}

- (void) setInsetBottom:(float)insetBottom
{
    _insetBottom = insetBottom;
    [self updateCapInset_];
}

#pragma mark -
#pragma mark CCScale9Sprite Public Methods

- (CCScale9Sprite *)resizableSpriteWithCapInsets:(CGRect)capInsets
{
    return SAFE_ARC_AUTORELEASE([[CCScale9Sprite alloc] initWithBatchNode:_scale9Image rect:_spriteRect capInsets:capInsets]);
}

#pragma mark -
#pragma mark Overridden

- (void)visit
{
    if (_positionsAreDirty) {
        [self updatePosition];
        
        _positionsAreDirty = NO;
    }
    
    [super visit];
}

@end
