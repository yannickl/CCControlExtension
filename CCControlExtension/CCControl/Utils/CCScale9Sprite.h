//
// Scale9Sprite.h
//
// Public domain. Use in anyway you see fit. No waranties of any kind express or implied.
// Based off work of Steve Oldmeadow and Jose Antonio Andújar Clavell
//
// Modification added by Yannick Loriot
// Modification added by Viktor Lidholt
//

#import "cocos2d.h"

/**
 * A 9-slice sprite for cocos2d.
 *
 * 9-slice scaling allows you to specify how scaling is applied
 * to specific areas of a sprite. With 9-slice scaling (3x3 grid),
 * you can ensure that the sprite does not become distorted when
 * scaled.
 *
 * @see http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCScale9Sprite.html
 */
@interface CCScale9Sprite : CCNode <CCRGBAProtocol>
{
@public
    CGSize              _originalSize;
    CGSize              _preferredSize;
    CGRect              _capInsets;
    
    float               _insetLeft;
    float               _insetTop;
    float               _insetRight;
    float               _insetBottom;
    
    // CCRGBAProtocol
    GLubyte             _opacity, _displayedOpacity, _realOpacity;
    ccColor3B           _color, _displayedColor, _realColor;
    BOOL                _opacityModifyRGB, _cascadeOpacityEnabled, _cascadeColorEnabled;
    
@protected
    CGRect              _spriteRect;
    BOOL                _spriteFrameRotated;
    CGRect              _capInsetsInternal;
    BOOL                _positionsAreDirty;
    
    CCSpriteBatchNode   *_scale9Image;
    CCSprite            *_topLeft;
    CCSprite            *_top;
    CCSprite            *_topRight;
    CCSprite            *_left;
    CCSprite            *_centre;
    CCSprite            *_right;
    CCSprite            *_bottomLeft;
    CCSprite            *_bottom;
    CCSprite            *_bottomRight;
    BOOL                _spritesGenerated;
}
/** @name Setting the Default Sizes */
/** Original sprite's size. */
@property (nonatomic, readonly) CGSize originalSize;
/** Preferred sprite's size. By default the preferred size is the original size. */
@property (nonatomic, assign) CGSize preferredSize;

/** @name 3x3 Grid Attributes */
/** 
 * The end-cap insets. 
 * On a non-resizeable sprite, this property is set to CGRectZero; the sprite 
 * does not use end caps and the entire sprite is subject to stretching. 
 */
@property(nonatomic, assign) CGRect capInsets;
/** Sets the left side inset */
@property(nonatomic, assign) float insetLeft;
/** Sets the top side inset */
@property(nonatomic, assign) float insetTop;
/** Sets the right side inset */
@property(nonatomic, assign) float insetRight;
/** Sets the bottom side inset */
@property(nonatomic, assign) float insetBottom;

/** @name RGBA Protocol Properties */
/** Conforms to CCRGBAProtocol protocol. */
@property (nonatomic, readwrite) GLubyte opacity;
/** Conforms to CCRGBAProtocol (v2.1) protocol. */
@property (nonatomic, readonly) GLubyte displayedOpacity;
/** Conforms to CCRGBAProtocol protocol. */
@property (nonatomic, readwrite) ccColor3B color;
/** Conforms to CCRGBAProtocol (v2.1) protocol. */
@property (nonatomic, readonly) ccColor3B displayedColor;
/** Conforms to CCRGBAProtocol protocol. */
@property (nonatomic, getter = doesOpacityModifyRGB) BOOL opacityModifyRGB;
/** Conforms to CCRGBAProtocol (v2.1) protocol. */
@property (nonatomic, getter = isCascadeColorEnabled) BOOL cascadeColorEnabled;
/** Conforms to CCRGBAProtocol (v2.1) protocol. */
@property (nonatomic, getter = isCascadeOpacityEnabled) BOOL cascadeOpacityEnabled;

#pragma mark Constructor - Initializers
/** @name Create 9-Scale Sprites */

/**
 * Initializes a 9-slice sprite with a texture file, a delimitation zone and
 * with the specified cap insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 * @param rect The rectangle that describes the sub-part of the texture that
 * is the whole image. If the shape is the whole texture, set this to the 
 * texture's full rect.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets;

/** 
 * Creates a 9-slice sprite with a texture file, a delimitation zone and
 * with the specified cap insets.
 *
 * @see initWithFile:rect:centerRegion:
 */
+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets;

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
 * Initializes a 9-slice sprite with a texture file and with the specified cap
 * insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithFile:(NSString *)file capInsets:(CGRect)capInsets;

/** 
 * Creates a 9-slice sprite with a texture file. The whole texture will be
 * broken down into a 3×3 grid of equal blocks.
 *
 * @see initWithFile:capInsets:
 */
+ (id)spriteWithFile:(NSString *)file capInsets:(CGRect)capInsets;

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
 * Initializes a 9-slice sprite with an sprite frame and with the specified 
 * cap insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrame The sprite frame object.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets;

/**
 * Creates a 9-slice sprite with an sprite frame and the centre of its zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrame:centerRegion:
 */
+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets;

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
 * Initializes a 9-slice sprite with an sprite frame name and with the specified 
 * cap insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrameName The sprite frame name.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets;

/**
 * Creates a 9-slice sprite with an sprite frame name and the centre of its
 * zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrameName:centerRegion:
 */
+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets;

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
/** @name Modifying the 3x3 Grid */

/**
 * Creates and returns a new sprite object with the specified cap insets.
 * You use this method to add cap insets to a sprite or to change the existing
 * cap insets of a sprite. In both cases, you get back a new image and the 
 * original sprite remains untouched.
 *
 * @param capInsets The values to use for the cap insets.
 */
- (CCScale9Sprite *)resizableSpriteWithCapInsets:(CGRect)capInsets;

/** @name Changing the Appearance */
/**
 * Sets the sprite frame used to display the 9-slice sprite.
 *
 * @param spriteFrame The new sprite frame.
 */
- (void)setSpriteFrame:(CCSpriteFrame *)spriteFrame;

@end
