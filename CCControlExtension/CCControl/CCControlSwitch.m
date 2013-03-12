/*
 * CCControlSwitch.m
 *
 * Copyright 2012 Yannick Loriot. All rights reserved.
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

#import "CCControlSwitch.h"
#import "ARCMacro.h"
#import "ccControlShaders.h"

#pragma mark CCControlSwitchSprite - Interface 

@interface CCControlSwitchSprite : CCSprite
{
@public
    CGFloat                                 _sliderXPosition;
    CGFloat                                 _onPosition;
    CGFloat                                 _offPosition;
    
    CCTexture2D                             *_maskTexture;
    GLuint                                  _textureLocation;
    GLuint                                  _maskLocation;
    
    CCSprite                                *_onSprite;
    CCSprite                                *_offSprite;
    CCSprite                                *_thumbSprite;
    CCNode<CCLabelProtocol, CCRGBAProtocol> *_onLabel;
    CCNode<CCLabelProtocol, CCRGBAProtocol> *_offLabel;
}
/** Contains the position (in x-axis) of the slider inside the receiver. */
@property (nonatomic, assign) CGFloat                                   sliderXPosition;
@property (nonatomic, assign) CGFloat                                   onPosition;
@property (nonatomic, assign) CGFloat                                   offPosition;

@property (nonatomic, strong) CCTexture2D                               *maskTexture;
@property (nonatomic, assign) GLuint                                    textureLocation;
@property (nonatomic, assign) GLuint                                    maskLocation;

@property (nonatomic, strong) CCSprite                                  *onSprite;
@property (nonatomic, strong) CCSprite                                  *offSprite;
@property (nonatomic, strong) CCSprite                                  *thumbSprite;
@property (nonatomic, strong) CCNode<CCLabelProtocol, CCRGBAProtocol>   *onLabel;
@property (nonatomic, strong) CCNode<CCLabelProtocol, CCRGBAProtocol>   *offLabel;

#pragma mark Contructors Initializers

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel;

#pragma mark Public Methods

/** Updates the layout using the current state value. */
- (void)needsLayout;

@end

#pragma mark - CCControlSwitch Implementation

@interface CCControlSwitch ()
/** Sprite which represents the view. */
@property (nonatomic, strong) CCControlSwitchSprite *switchSprite;
@property (nonatomic, assign) CGFloat               initialTouchXPosition;
@property (nonatomic, getter = hasMoved) BOOL       moved;

@end

@implementation CCControlSwitch
@synthesize switchSprite            = _switchSprite;
@synthesize initialTouchXPosition   = _initialTouchXPosition;
@synthesize moved                   = _moved;
@synthesize on                      = _on;
@synthesize onThumbTintColor        = _onThumbTintColor;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_switchSprite);
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite
{
    return [self initWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite onLabel:nil offLabel:nil];
}

+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite]);
}

+ (id)switchWithMaskFile:(NSString *)maskFile onFile:(NSString *)onFile offFile:(NSString *)offFile thumbFile:(NSString *)thumbFile
{
    // Prepare the mask for the switch
    CCSprite *maskSprite   = [CCSprite spriteWithFile:maskFile];
    
    // Prepare the on sprite for the switch
    CCSprite *onSprite      = [CCSprite spriteWithFile:onFile];
    
    // Prepare the off sprite for the switch
    CCSprite *offSprite     = [CCSprite spriteWithFile:offFile];
    
    // Prepare the thumb sprite for the switch
    CCSprite *thumbSprite   = [CCSprite spriteWithFile:thumbFile];
    
    return [self switchWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite];
}

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel
{
    if ((self = [super init]))
    {
        NSAssert(maskSprite,    @"Mask must not be nil.");
        NSAssert(onSprite,      @"onSprite must not be nil.");
        NSAssert(offSprite,     @"offSprite must not be nil.");
        NSAssert(thumbSprite,   @"thumbSprite must not be nil.");
        
        _onThumbTintColor           = ccGRAY;
        _on                         = YES;

        _switchSprite               = [[CCControlSwitchSprite alloc] initWithMaskSprite:maskSprite 
                                                                               onSprite:onSprite
                                                                              offSprite:offSprite 
                                                                            thumbSprite:thumbSprite 
                                                                                onLabel:onLabel 
                                                                               offLabel:offLabel];
        _switchSprite.position      = ccp (_switchSprite.contentSize.width / 2, _switchSprite.contentSize.height / 2);
        [self addChild:_switchSprite];
        
        self.ignoreAnchorPointForPosition  = NO;
        self.anchorPoint            = ccp (0.5f, 0.5f);
        self.contentSize            = [_switchSprite contentSize];
    }
    return self;
}

+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel
{
    return SAFE_ARC_AUTORELEASE([[self alloc] initWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite onLabel:onLabel offLabel:offLabel]);
}

+ (id)switchWithMaskFile:(NSString *)maskFile onFile:(NSString *)onFile offFile:(NSString *)offFile thumbFile:(NSString *)thumbFile onTitle:(NSString *)onTitle offTitle:(NSString *)offTitle
{
    // Prepare the mask for the switch
    CCSprite *maskSprite   = [CCSprite spriteWithFile:maskFile];
    
    // Prepare the on sprite for the switch
    CCSprite *onSprite      = [CCSprite spriteWithFile:onFile];
    
    // Prepare the off sprite for the switch
    CCSprite *offSprite     = [CCSprite spriteWithFile:offFile];
    
    // Prepare the thumb sprite for the switch
    CCSprite *thumbSprite   = [CCSprite spriteWithFile:thumbFile];
    
    // Prepare the on title for the switch
    CCLabelTTF *onLabel     = [CCLabelTTF labelWithString:onTitle fontName:@"Arial-BoldMT" fontSize:16];
    
    // Prepare the off title for the switch
    CCLabelTTF *offLabel    = [CCLabelTTF labelWithString:offTitle fontName:@"Arial-BoldMT" fontSize:16];
    
    return [self switchWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite onLabel:onLabel offLabel:offLabel];
}

#pragma mark Properties

- (void)setOn:(BOOL)isOn
{
    [self setOn:isOn animated:NO];
}

- (void)setOn:(BOOL)isOn animated:(BOOL)animated
{
    _on                     = isOn;

    double internalOffset   = (isOn) ? _switchSprite.onPosition : _switchSprite.offPosition;
    
    if (animated)
    {
        [_switchSprite runAction:
         [CCActionTween actionWithDuration:0.2f 
                                       key:@"sliderXPosition" 
                                      from:_switchSprite.sliderXPosition
                                        to:internalOffset]];
    } else
    {
        _switchSprite.sliderXPosition   = internalOffset;
    }

    
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled                            = enabled;

    _switchSprite.opacity               = (enabled) ? 255.0f : 128.0f;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];                      // Get the touch position
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];  // Convert the position to GL space
    touchLocation           = [self convertToNodeSpace:touchLocation];                  // Convert to the node space of this class
    
    return touchLocation;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
        return NO;
    
    _moved                          = NO;
    
    CGPoint location                = [self locationFromTouch:touch];
    
    _initialTouchXPosition          = location.x - _switchSprite.sliderXPosition;
    
    _switchSprite.thumbSprite.color = _onThumbTintColor;
    [_switchSprite needsLayout];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location    = [self locationFromTouch:touch];
    location            = ccp (location.x - _initialTouchXPosition, 0);
    
    _moved              = YES;
    
    [_switchSprite setSliderXPosition:location.x];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location   = [self locationFromTouch:touch];
    
    _switchSprite.thumbSprite.color  = ccWHITE;
    
    if ([self hasMoved])
    {
        [self setOn:!(location.x < _switchSprite.contentSize.width / 2) animated:YES];
    } else
    {
        [self setOn:![self isOn] animated:YES];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self ccTouchEnded:touch withEvent:event];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (CGPoint)locationFromEvent:(NSEvent *)event
{
    CGPoint eventLocation   = [[CCDirector sharedDirector] convertEventToGL:event];
    eventLocation           = [self convertToNodeSpace:eventLocation];
    
    return eventLocation;
}

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isMouseInside:event]
        || ![self isEnabled]
        || ![self visible]
        || ![self hasVisibleParents])
        return NO;
    
    self.selected                   = YES;
    _moved                          = NO;
    
    CGPoint location                = [self locationFromEvent:event];
    
    _initialTouchXPosition          = location.x - _switchSprite.sliderXPosition;
    
    _switchSprite.thumbSprite.color = _onThumbTintColor;
    [_switchSprite needsLayout];
    
    return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self isSelected])
        return NO;
    
    CGPoint location    = [self locationFromEvent:event];
    location            = ccp (location.x - _initialTouchXPosition, 0);
    
    _moved              = YES;
    
    [_switchSprite setSliderXPosition:location.x];
    
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    if (![self isEnabled]
        || ![self isSelected])
        return NO;
    
    _selected                       = NO;
    
    CGPoint location                = [self locationFromEvent:event];
    
    _switchSprite.thumbSprite.color = ccWHITE;
    
    if ([self hasMoved])
    {
        [self setOn:!(location.x < _switchSprite.contentSize.width / 2) animated:YES];
    } else
    {
        [self setOn:![self isOn] animated:YES];
    }
    
    return NO;
}

#endif

@end

#pragma mark - CCControlSwitchSprite Implementation

@implementation CCControlSwitchSprite
@synthesize maskTexture         = _maskTexture;
@synthesize textureLocation     = _textureLocation;
@synthesize maskLocation        = _maskLocation;
@synthesize onSprite            = _onSprite;
@synthesize offSprite           = _offSprite;
@synthesize thumbSprite         = _thumbSprite;
@synthesize onLabel             = _onLabel;
@synthesize offLabel            = _offLabel;
@synthesize sliderXPosition     = _sliderXPosition;
@synthesize onPosition          = _onPosition;
@synthesize offPosition         = _offPosition;

- (void)dealloc
{
    SAFE_ARC_RELEASE(_onSprite);
    SAFE_ARC_RELEASE(_offSprite);
    SAFE_ARC_RELEASE(_thumbSprite);
    SAFE_ARC_RELEASE(_onLabel);
    SAFE_ARC_RELEASE(_offLabel);
    SAFE_ARC_RELEASE(_maskTexture);
    
    SAFE_ARC_SUPER_DEALLOC();
}

- (id)init
{
    NSAssert(NO, @"Use 'initWithMaskFile:onSprite:offSprite:thumbSprite:onLabel:onLabeloffLabel:' initialazer instead of 'init'");
    return nil;
}

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel
{
    if ((self = [super initWithTexture:[maskSprite texture]]))
    {
        // Sets the default values
        _onPosition             = 0;
        _offPosition            = -onSprite.contentSize.width + thumbSprite.contentSize.width / 2;
        _sliderXPosition        = _onPosition;
        
        self.onSprite           = onSprite;
        self.offSprite          = offSprite;
        self.thumbSprite        = thumbSprite;
        self.onLabel            = onLabel;
        self.offLabel           = offLabel;
        
        [self addChild:thumbSprite];
        
        // Set up the mask with the Mask shader
        self.maskTexture        = [maskSprite texture];
      
        // Position Texture Color shader
        CCGLProgram *tProgram   = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert
                                                             fragmentShaderByteArray:ccControlSwitchMask_frag];
        self.shaderProgram      = tProgram;
        SAFE_ARC_RELEASE(tProgram);
#if COCOS2D_VERSION >= 0x00020100
        GLuint program          = [self.shaderProgram program];
#else
        GLuint program          = self.shaderProgram->program_;
#endif
        CHECK_GL_ERROR_DEBUG();
        
        [self.shaderProgram addAttribute:kCCAttributeNamePosition   index:kCCVertexAttrib_Position];
        [self.shaderProgram addAttribute:kCCAttributeNameColor      index:kCCVertexAttrib_Color];
        [self.shaderProgram addAttribute:kCCAttributeNameTexCoord   index:kCCVertexAttrib_TexCoords];
        CHECK_GL_ERROR_DEBUG();
        
        [self.shaderProgram link];
        CHECK_GL_ERROR_DEBUG();
        
        [self.shaderProgram updateUniforms];
        CHECK_GL_ERROR_DEBUG();                
        
        self.textureLocation    = glGetUniformLocation(program, "u_texture");
        self.maskLocation       = glGetUniformLocation(program, "u_mask");
        CHECK_GL_ERROR_DEBUG();
        
        self.contentSize        = [_maskTexture contentSize];
        
        [self needsLayout];
    }
    return self;
}

- (void)draw
{
    CC_NODE_DRAW_SETUP();
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
#if COCOS2D_VERSION >= 0x00020100
    [self.shaderProgram setUniformsForBuiltins];
#else
    [self.shaderProgram setUniformForModelViewProjectionMatrix];
#endif
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D, [self.texture name] );
    glUniform1i(_textureLocation, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture( GL_TEXTURE_2D, [_maskTexture name] );
    glUniform1i(_maskLocation, 1);
    
    ccV3F_C4B_T2F_Quad current_quad = [self quad];
    #define kQuadSize sizeof(current_quad.bl)
    long offset = (long)&current_quad;
    
    // vertex
    NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
    // texCoods
    diff = offsetof( ccV3F_C4B_T2F, texCoords);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
    // color
    diff = offsetof( ccV3F_C4B_T2F, colors);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);    
    glActiveTexture(GL_TEXTURE0);
}

- (void)needsLayout
{
    _onSprite.position      = ccp(_onSprite.contentSize.width / 2 + _sliderXPosition,
                                                            _onSprite.contentSize.height / 2);
    _offSprite.position     = ccp(_onSprite.contentSize.width + _offSprite.contentSize.width / 2 + _sliderXPosition,
                                                            _offSprite.contentSize.height / 2);
    _thumbSprite.position   = ccp(_onSprite.contentSize.width + _sliderXPosition,
                                                            _maskTexture.contentSize.height / 2);
    
    if (_onLabel)
    {
        _onLabel.position   = ccp(_onSprite.position.x - _thumbSprite.contentSize.width / 6,
                                  _onSprite.contentSize.height / 2);
    }
    if (_offLabel)
    {
        _offLabel.position  = ccp(_offSprite.position.x + _thumbSprite.contentSize.width / 6,
                                  _offSprite.contentSize.height / 2);
    }
    
    CCRenderTexture *rt     = [CCRenderTexture renderTextureWithWidth:_maskTexture.contentSize.width
                                                               height:_maskTexture.contentSize.height];
    
    [rt                 begin];
    [self.onSprite      visit];        
    [self.offSprite     visit]; 
    
    if (_onLabel)
    {
        [_onLabel       visit];
    }
    if (_offLabel)
    {
        [_offLabel      visit];
    }
    
    [rt                 end];

    self.texture            = rt.sprite.texture;
    self.flipY              = YES;
}

- (void)setSliderXPosition:(CGFloat)sliderXPosition
{
    if (sliderXPosition <= _offPosition)
    {
        // Off
        sliderXPosition = _offPosition;
    } else if (sliderXPosition >= _onPosition)
    {
        // On
        sliderXPosition = _onPosition;
    }
    
    _sliderXPosition    = sliderXPosition;
    
    [self needsLayout];
}

- (CGFloat)onSideWidth
{
    return _onSprite.contentSize.width;
}

- (CGFloat)offSideWidth
{
    return _offSprite.contentSize.height;
}

@end
