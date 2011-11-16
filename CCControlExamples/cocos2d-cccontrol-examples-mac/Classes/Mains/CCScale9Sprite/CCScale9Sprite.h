//
// Scale9Sprite.h
//
// Public domain. Use in anyway you see fit. No waranties of any kind express or implied.
// Based off work of Steve Oldmeadow and Jose Antonio Andújar Clavell
//
// 2011/11/14: Modified by Yannick Loriot
//

#import "cocos2d.h"

/**
 * A 9-slice sprite for cocos2d.
 */
@interface CCScale9Sprite : CCNode <CCRGBAProtocol>
{
@public
    CGSize originalSize_;
    CGSize preferedSize_;
    
@protected
    CCSpriteBatchNode *scale9Image;
    CCSprite *topLeft;
    CCSprite *top;
    CCSprite *topRight;
    CCSprite *left;
    CCSprite *centre;
    CCSprite *right;
    CCSprite *bottomLeft;
    CCSprite *bottom;
    CCSprite *bottomRight;
    
    // texture RGBA
    GLubyte opacity_;
    ccColor3B color_;
    BOOL opacityModifyRGB_;
}
/** Original sprite's size. */
@property (nonatomic, readonly) CGSize originalSize;
/** Prefered sprite's size. By default the prefered size is the original size. */
@property (nonatomic, assign) CGSize preferedSize;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, readwrite) GLubyte opacity;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, readwrite) ccColor3B color;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, getter = doesOpacityModifyRGB) BOOL opacityModifyRGB;

#pragma mark Constructor - Initializers

/**
 * Initializes a 9-slice sprite with a texture file, a delimitation zone and
 * the centre of this zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 * @param rect The rectangle that describes the sub-part of the texture that
 * is the whole image. If the shape is the whole texture, set this to the 
 * texture's full rect.
 * @param centerRegion Defines the inside part of the 9-slice. This part will
 * scale X and Y. The top and bottom borders scale X only. The left and right
 * borders scale Y only. The four outside corners do not scale at all.
 */
- (id)initWithFile:(NSString *)file rect:(CGRect)rect centerRegion:(CGRect)centerRegion;

/** 
 * Creates a 9-slice sprite with a texture file, a delimitation zone and
 * the centre of this zone.
 *
 * @see initWithFile:rect:centerRegion:
 */
+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect centerRegion:(CGRect)centerRegion;

/**
 * Initializes a 9-slice sprite with a texture file and a delimitation zone. The
 * texture will be broken down into a 3×3 grid of equal blocks.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 * @param rect The rectangle that describes the sub-part of the texture that
 * is the whole image. If the shape is the whole texture, set this to the 
 * texture's full rect.
 */
- (id)initWithFile:(NSString *)file rect:(CGRect)rect;

/** 
 * Creates a 9-slice sprite with a texture file and a delimitation zone. The
 * texture will be broken down into a 3×3 grid of equal blocks.
 *
 * @see initWithFile:rect:
 */
+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect;

/**
 * Initializes a 9-slice sprite with a texture file. The whole texture will be
 * broken down into a 3×3 grid of equal blocks.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 */
- (id)initWithFile:(NSString *)file;

/** 
 * Creates a 9-slice sprite with a texture file. The whole texture will be
 * broken down into a 3×3 grid of equal blocks.
 *
 * @see initWithFile:
 */
+ (id)spriteWithFile:(NSString *)file;

/**
 * Initializes a 9-slice sprite with an sprite frame and the centre of its
 * zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrame The sprite frame object.
 * @param centerRegion Defines the inside part of the 9-slice. This part will
 * scale X and Y. The top and bottom borders scale X only. The left and right
 * borders scale Y only. The four outside corners do not scale at all.
 */
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame centerRegion:(CGRect)centerRegion;

/**
 * Creates a 9-slice sprite with an sprite frame and the centre of its zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrame:centerRegion:
 */
+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame centerRegion:(CGRect)centerRegion;

/**
 * Initializes a 9-slice sprite with an sprite frame.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrame The sprite frame object.
 */
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame;

/**
 * Creates a 9-slice sprite with an sprite frame.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrame:
 */
+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame;

/**
 * Initializes a 9-slice sprite with an sprite frame name and the centre its 
 * zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrameName The sprite frame name.
 * @param centerRegion Defines the inside part of the 9-slice. This part will
 * scale X and Y. The top and bottom borders scale X only. The left and right
 * borders scale Y only. The four outside corners do not scale at all.
 */
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName centerRegion:(CGRect)centerRegion;

/**
 * Creates a 9-slice sprite with an sprite frame name and the centre of its
 * zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrameName:centerRegion:
 */
+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName centerRegion:(CGRect)centerRegion;

/**
 * Initializes a 9-slice sprite with an sprite frame name.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrameName The sprite frame name.
 */
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName;

/**
 * Creates a 9-slice sprite with an sprite frame name.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrameName:
 */
+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName;

#pragma mark Public Methods

@end
