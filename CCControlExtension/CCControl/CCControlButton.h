/*
 * CCControlButton.h
 *
 * Copyright 2011 Yannick Loriot. All rights reserved.
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

#import "CCControl.h"

/** Define the button margin for Left/Right edge */
#define CCControlButtonMarginLR 8 // px
/** Define the button margin for Top/Bottom edge */
#define CCControlButtonMarginTB 2 // px

@class CCScale9Sprite;

/**
 * Button control for Cocos2D.
 *
 * A button intercepts touch events and sends an action message to a
 * target object when tapped. Methods for setting the target and action
 * are inherited from CCControl.
 *
 * @see http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlButton.html
 */
@interface CCControlButton : CCControl
{
@public    
    BOOL                                    _adjustBackgroundImage;
    BOOL                                    _zoomOnTouchDown;
    float                                   _marginLR, _marginTB;
    
    NSString                                *_currentTitle;
    ccColor3B                               _currentTitleColor;
    CCNode<CCLabelProtocol, CCRGBAProtocol> *_titleLabel;
    CCScale9Sprite                          *_backgroundSprite;
    CGSize                                  _preferredSize;
    
@protected
    BOOL                                    _pushed;
    
    NSMutableDictionary                     *_titleDispatchTable;
    NSMutableDictionary                     *_titleColorDispatchTable;
    NSMutableDictionary                     *_titleLabelDispatchTable;
    NSMutableDictionary                     *_backgroundSpriteDispatchTable;
    CGPoint                                 _labelAnchorPoint;
}
/** Adjust the background image. YES by default. If the property is set to NO, the 
 background will use the preferred size of the background image. */
@property (nonatomic, getter = doesAdjustBackgroundImage) BOOL adjustBackgroundImage;
/** The current title that is displayed on the button. */
@property(nonatomic, readonly, strong) NSString *currentTitle;
/** The current color used to display the title. */
@property(nonatomic, readonly, assign) ccColor3B currentTitleColor;
/** The current title label. */
@property (nonatomic, strong) CCNode<CCLabelProtocol,CCRGBAProtocol> *titleLabel;
/** The current background sprite. */
@property (nonatomic, strong) CCScale9Sprite *backgroundSprite;
/** The preferred size of the button, if label is larger it will be expanded. */
@property (nonatomic, assign) CGSize preferredSize;
/** Scale the button up when it is touched, default is YES. */
@property (nonatomic, assign) BOOL zoomOnTouchDown;
/** The anchorPoint of the label, default is (0.5,0.5) */
@property (nonatomic, assign) CGPoint labelAnchorPoint;
/** The margins. By default the values of marginLR and marginTB are,
 respectively, equals to CCControlButtonMarginLR and CCControlButtonMarginTB. */
@property (nonatomic, assign) float marginLR, marginTB;

#pragma mark Constructors - Initializers
/** @name Creating Buttons */

/** 
 * Initializes a button with a label in foreground and a sprite in background.
 * @param label            label, that is used as a foreground title.
 * @param backgroundsprite CCScale9Sprite, that is used as a background.
 */
- (id)initWithLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)label backgroundSprite:(CCScale9Sprite *)backgroundsprite;

/**
 * Creates a button with a label in foreground and a sprite in background.
 * @see initWithLabel:backgroundSprite:
 */
+ (id)buttonWithLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)label backgroundSprite:(CCScale9Sprite *)backgroundsprite;

/**
 * Initializes a button with a title, a font name and a font size for the label in foreground.
 * @param title     Title displayed on the button.
 * @param fontName  Font name to use to render the title.
 * @param fontSize  Font name to use to render the title.
 */
- (id)initWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(NSUInteger)fontsize;

/**
 * Creates a button with a title, a font name and a font size for the label in foreground.
 * @see buttonWithTitle:fontName:fontSize:
 */
+ (id)buttonWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(NSUInteger)fontsize;

/**
 * Initializes a button with a sprite in background.
 * @param backgroundsprite CCScale9Sprite, that is used as a background.
 */
- (id)initWithBackgroundSprite:(CCScale9Sprite *)backgroundsprite;

/**
 * Creates a button with a sprite in background.
 * @see initWithBackgroundSprite:
 */
+ (id)buttonWithBackgroundSprite:(CCScale9Sprite *)backgroundsprite;

#pragma mark - Public Methods

#pragma mark Configuring/Getting the Button Title
/** @name Configuring/Getting the Button Title */

/**
 * Returns the title used for a state.
 *
 * @param state The state that uses the title. Possible values are described in
 * "CCControlState".
 *
 * @return The title for the specified state.
 */
- (NSString *)titleForState:(CCControlState)state;

/**
 * Sets the title string to use for the specified state.
 * If a property is not specified for a state, the default is to use
 * the CCButtonStateNormal value.
 *
 * @param title The title string to use for the specified state.
 * @param state The state that uses the specified title. The values are described
 * in "CCControlState".
 */
- (void)setTitle:(NSString *)title forState:(CCControlState)state;

/**
 * Returns the title color used for a state.
 *
 * @param state The state that uses the specified color. The values are described
 * in "CCControlState".
 *
 * @return The color of the title for the specified state.
 */
- (ccColor3B)titleColorForState:(CCControlState)state;

/**
 * Sets the color of the title to use for the specified state.
 *
 * @param color The color of the title to use for the specified state.
 * @param state The state that uses the specified color. The values are described
 * in "CCControlState".
 */
- (void)setTitleColor:(ccColor3B)color forState:(CCControlState)state;

/**
 * Returns the title label used for a state.
 *
 * @param state The state that uses the title label. Possible values are described
 * in "CCControlState".
 */
- (CCNode<CCLabelProtocol, CCRGBAProtocol> *)titleLabelForState:(CCControlState)state;

/**
 * Sets the title label to use for the specified state.
 * If a property is not specified for a state, the default is to use
 * the CCButtonStateNormal value.
 *
 * @param title The title label to use for the specified state.
 * @param state The state that uses the specified title. The values are described
 * in "CCControlState".
 */
- (void)setTitleLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)label forState:(CCControlState)state;

/**
 * Sets the font of the label, changes the label to a CCLabelBMFont if neccessary.
 *
 * @param fntFile The name of the font to change to
 * @param state The state that uses the specified fntFile. The values are described
 * in "CCControlState".
 */
- (void)setTitleBMFont:(NSString*)fntFile forState:(CCControlState)state;

/**
 * Sets the font of the label, changes the label to a CCLabelTTF if neccessary.
 *
 * @param fntFile The name of the font to change to
 * @param state The state that uses the specified fntFile. The values are described
 * in "CCControlState".
 */
- (void)setTitleTTF:(NSString*)fontName forState:(CCControlState)state;

/**
 * Returns the name of the TTF font used by the label, or NULL if the
 * label is a CCLabelBMFont.
 *
 * @param state The state that uses the specified font. The values are described
 * in "CCControlState".
 */
- (NSString*) titleTTFForState:(CCControlState)state;


/**
 * Sets the font size of the label, will only work with ttf labels.
 *
 * @param fntFile The name of the font to change to
 * @param state The state that uses the specified fntFile. The values are described
 * in "CCControlState".
 */
- (void)setTitleTTFSize:(float)size forState:(CCControlState)state;

/**
 * Returns the sizer of the TTF font used by the label, or 0 if the
 * label is a CCLabelBMFont.
 *
 * @param state The state that uses the specified font. The values are described
 * in "CCControlState".
 */
- (float) titleTTFSizeForState:(CCControlState)state;

#pragma mark Configuring/Getting Button Background Presentation
/** @name Configuring/Getting Button Background Presentation */

/**
 * Returns the background sprite used for a state.
 *
 * @param state The state that uses the background sprite. Possible values are
 * described in "CCControlState".
 */
- (CCScale9Sprite *)backgroundSpriteForState:(CCControlState)state;

/**
 * Sets the background sprite to use for the specified button state.
 *
 * @param sprite The background sprite to use for the specified state.
 * @param state The state that uses the specified image. The values are described
 * in "CCControlState".
 */
- (void)setBackgroundSprite:(CCScale9Sprite *)sprite forState:(CCControlState)state;

/**
 * Sets the background spriteFrame to use for the specified button state.
 *
 * @param spriteFrame The background spriteFrame to use for the specified state.
 * @param state The state that uses the specified image. The values are described
 * in "CCControlState".
 */
- (void)setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state;

@end
