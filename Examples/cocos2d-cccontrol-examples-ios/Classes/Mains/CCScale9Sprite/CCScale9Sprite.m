//
// Scale9Sprite.m
//
// Creates a 9-slice sprite.
//

#import "CCScale9Sprite.h"

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

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect centerRegion:(CGRect)centerRegion;
    
@end
    
@implementation CCScale9Sprite
@synthesize originalSize = originalSize_;
@synthesize preferedSize = preferedSize_;
@synthesize opacity = opacity_;
@synthesize color = color_;
@synthesize opacityModifyRGB = opacityModifyRGB_;

- (void)dealloc
{
    [topLeft release];
    [top release];
    [topRight release];
    [left release];
    [centre release];
    [right release];
    [bottomLeft release];
    [bottom release];
    [bottomRight release];
    [scale9Image release];
    
    [super dealloc];
}

#pragma mark Constructor - Initializers

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect centerRegion:(CGRect)centerRegion
{
    if ((self = [super init]))
    {
        NSAssert(batchnode, @"The batchnode must be not nil.");
        
        scale9Image = [batchnode retain];
        
        // If there is no given rect
        if (CGRectEqualToRect(rect, CGRectZero))
        {
            // Get the texture size as original
            CGSize textureSize = [[[scale9Image textureAtlas] texture] contentSize];
            
            rect = CGRectMake(0, 0, textureSize.width, textureSize.height);
        }
        
        // Set the given rect's size as original size
        originalSize_ = rect.size;
        preferedSize_ = originalSize_;
        anchorPoint_ = ccp(0.5f, 0.5f);
        
        // If there is no specified center region
        if (CGRectEqualToRect(centerRegion, CGRectZero))
        {
            // Apply the 3x3 grid format
            centerRegion = CGRectMake(rect.origin.x + originalSize_.width / 3, 
                                      rect.origin.y + originalSize_.height / 3, 
                                      originalSize_.width / 3,
                                      originalSize_.height / 3);
        }

        // Get the image edges
        float l = rect.origin.x;
        float t = rect.origin.y;
        float h = rect.size.height;
        float w = rect.size.width;
        
        //
        // Set up the image
        //
        
        // Centre
        centre = [[CCSprite alloc] initWithBatchNode:scale9Image rect:centerRegion];
        [scale9Image addChild:centre z:0 tag:pCentre];
        
        // Top
        top = [[CCSprite alloc]
               initWithBatchNode:scale9Image
               rect:CGRectMake(centerRegion.origin.x,
                               t,
                               centerRegion.size.width,
                               centerRegion.origin.y-t)
               ];
        [scale9Image addChild:top z:1 tag:pTop];
        
        // Bottom
        bottom = [[CCSprite alloc]
                  initWithBatchNode:scale9Image
                  rect:CGRectMake(centerRegion.origin.x,
                                  centerRegion.origin.y + centerRegion.size.height,
                                  centerRegion.size.width,
                                  h - (centerRegion.origin.y - t + centerRegion.size.height))
                  ];
        [scale9Image addChild:bottom z:1 tag:pBottom];
        
        // Left
        left = [[CCSprite alloc]
                initWithBatchNode:scale9Image
                rect:CGRectMake(l,
                                centerRegion.origin.y,
                                centerRegion.origin.x - l,
                                centerRegion.size.height)
                ];
        [scale9Image addChild:left z:1 tag:pLeft];
        
        // Right
        right = [[CCSprite alloc]
                 initWithBatchNode:scale9Image
                 rect:CGRectMake(centerRegion.origin.x + centerRegion.size.width,
                                 centerRegion.origin.y,
                                 w - (centerRegion.origin.x - l + centerRegion.size.width),
                                 centerRegion.size.height)
                 ];
        [scale9Image addChild:right z:1 tag:pRight];
        
        // Top left
        topLeft = [[CCSprite alloc]
                   initWithBatchNode:scale9Image
                   rect:CGRectMake(l,
                                   t,
                                   centerRegion.origin.x - l,
                                   centerRegion.origin.y - t)
                   ];
        [scale9Image addChild:topLeft z:2 tag:pTopLeft];
        
        // Top right
        topRight = [[CCSprite alloc]
                    initWithBatchNode:scale9Image
                    rect:CGRectMake(centerRegion.origin.x + centerRegion.size.width,
                                    t,
                                    w - (centerRegion.origin.x - l + centerRegion.size.width),
                                    centerRegion.origin.y - t)
                    ];
        [scale9Image addChild:topRight z:2 tag:pTopRight];
        
        // Bottom left
        bottomLeft = [[CCSprite alloc]
                      initWithBatchNode:scale9Image
                      rect:CGRectMake(l,
                                      centerRegion.origin.y + centerRegion.size.height,
                                      centerRegion.origin.x - l,
                                      h - (centerRegion.origin.y - t + centerRegion.size.height))
                      ];
        [scale9Image addChild:bottomLeft z:2 tag:pBottomLeft];
        
        // Bottom right
        bottomRight = [[CCSprite alloc]
                       initWithBatchNode:scale9Image
                       rect:CGRectMake(centerRegion.origin.x + centerRegion.size.width,
                                       centerRegion.origin.y + centerRegion.size.height,
                                       w - (centerRegion.origin.x - l + centerRegion.size.width),
                                       h - (centerRegion.origin.y - t + centerRegion.size.height))
                       ];
        [scale9Image addChild:bottomRight z:2 tag:pBottomRight];
        
        [self setContentSize:rect.size];
        [self addChild:scale9Image];
    }
    return self;
}

- (id)initWithFile:(NSString *)file rect:(CGRect)rect centerRegion:(CGRect)centerRegion
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithFile:file capacity:9];
    
    return [self initWithBatchNode:batchnode rect:rect centerRegion:centerRegion];
}

+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect centerRegion:(CGRect)centerRegion
{
    return [[[self alloc] initWithFile:file rect:rect centerRegion:centerRegion] autorelease];
}

- (id)initWithFile:(NSString *)file rect:(CGRect)rect
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:rect centerRegion:CGRectZero];
}
 
+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect
{
    return [[[self alloc] initWithFile:file rect:rect] autorelease];
}

- (id)initWithFile:(NSString *)file
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:CGRectZero];
}

+ (id)spriteWithFile:(NSString *)file
{
    return [[[self alloc] initWithFile:file] autorelease];
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame centerRegion:(CGRect)centerRegion
{
    NSAssert(spriteFrame != nil, @"Sprite frame must be not nil");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture capacity:9];

    return [self initWithBatchNode:batchnode rect:spriteFrame.rect centerRegion:centerRegion];
}

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame centerRegion:(CGRect)centerRegion
{
    return [[[self alloc] initWithSpriteFrame:spriteFrame centerRegion:centerRegion] autorelease];
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    NSAssert(spriteFrame != nil, @"Invalid spriteFrame for sprite");
    
    return [self initWithSpriteFrame:spriteFrame centerRegion:CGRectZero];
}

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    return [[[self alloc] initWithSpriteFrame:spriteFrame] autorelease];
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName centerRegion:(CGRect)centerRegion
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
    
    return [self initWithSpriteFrame:frame centerRegion:centerRegion];
}

+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName centerRegion:(CGRect)centerRegion
{
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName centerRegion:centerRegion] autorelease];
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    return [self initWithSpriteFrameName:spriteFrameName centerRegion:CGRectZero];
}

+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName
{
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName] autorelease];
}

#pragma mark Properties

- (void)setContentSize:(CGSize)size
{
    [super setContentSize:size];

    float sizableWidth = size.width - topLeft.contentSize.width - topRight.contentSize.width;
    float sizableHeight = size.height - topLeft.contentSize.height - bottomRight.contentSize.height;
    
    float horizontalScale = sizableWidth/centre.contentSize.width;
    float verticalScale = sizableHeight/centre.contentSize.height;
    
    centre.scaleX = horizontalScale;
    centre.scaleY = verticalScale;

    float rescaledWidth = centre.contentSize.width * horizontalScale;
    float rescaledHeight = centre.contentSize.height * verticalScale;

    float despx = size.width * 0.5f;
    float despy = size.height * 0.5f;

    // Position corners
    [topLeft setPosition:
     CGPointMake(-rescaledWidth/2 - topLeft.contentSize.width/2 +despx, rescaledHeight/2 + topLeft.contentSize.height*0.5 + despy)];
    [topRight setPosition:
     CGPointMake(rescaledWidth/2 + topRight.contentSize.width/2 +despx, rescaledHeight/2 + topRight.contentSize.height*0.5 + despy)];
    [bottomLeft setPosition:
     CGPointMake(-rescaledWidth/2 - bottomLeft.contentSize.width/2 + despx, -rescaledHeight/2 - bottomLeft.contentSize.height*0.5 + despy)];
    [bottomRight setPosition:
     CGPointMake(rescaledWidth/2 + bottomRight.contentSize.width/2 + despx, -rescaledHeight/2 + -bottomRight.contentSize.height*0.5 + despy)];
    
    // Scale and position borders
    top.scaleX = horizontalScale;
    [top setPosition:CGPointMake(0+despx,rescaledHeight/2 + topLeft.contentSize.height*0.5 + despy)];
    bottom.scaleX = horizontalScale;
    [bottom setPosition:CGPointMake(0+despx,-rescaledHeight/2 - bottomLeft.contentSize.height*0.5 + despy)];
    left.scaleY = verticalScale;
    [left setPosition:CGPointMake(-rescaledWidth/2 - topLeft.contentSize.width/2 +despx, 0 + despy)];
    right.scaleY = verticalScale;
    [right setPosition:CGPointMake(rescaledWidth/2 + topRight.contentSize.width/2 +despx, 0 + despy)];
    
    // Position center
    [centre setPosition:CGPointMake(despx, despy)];
}

#pragma mark Properties

- (void)setColor:(ccColor3B)color
{
    color_ = color;
    
    for (CCNode<CCRGBAProtocol> *child in scale9Image.children)
    {
        [child setColor:color];
    }
}

- (void)setOpacity:(GLubyte)opacity
{
    opacity_ = opacity;
    
    for (CCNode<CCRGBAProtocol> *child in scale9Image.children)
    {
        [child setOpacity:opacity];
    }
}

- (void)setOpacityModifyRGB:(BOOL)boolean
{
    opacityModifyRGB_ = boolean;
    
    for (CCNode<CCRGBAProtocol> *child in scale9Image.children)
    {
        [child setOpacityModifyRGB:boolean];
    }
}

@end
