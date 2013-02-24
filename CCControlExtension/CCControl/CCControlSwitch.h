/*
 * CCControlSwitch.h
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

#import "CCControl.h"

/**
 * CCControlSwitch is a switch control for Cocos2D.
 *
 * The CCControlSwitch class is useful to create and manage On/Off buttons,
 * like for example, in the option menus for volume as example.
 *
 * The CCControlSwitch class declares a property and a method to control its
 * on/off state. As with CCControlSlider, when the user manipulates the 
 * switch control (“flips” it) a CCControlEventValueChanged event is
 * generated, which results in the control (if properly configured) sending
 * an action message.
 *
 * @see http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlSwitch.html
 */
@interface CCControlSwitch : CCControl

#pragma mark Contructors - Initializers
/** @name Creating Switches */

/**
 * Initializes a switch with a mask sprite, on/off sprites for on/off states and a thumb sprite.
 * @param maskSprite The sprite used as mask to hide on/off sprites.
 * @param onSprite The sprite displayed when the switch is in the on position.
 * @param offSprite The sprite displayed when the switch is in the off position.
 * @param thumbSprite The sprite used for the thumb.
 */
- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite;

/** 
 * Creates a switch with a mask sprite, on/off sprites for on/off states and a thumb sprite.
 *
 * @see initWithMaskSprite:onSprite:offSprite:thumbSprite:
 */
+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite;

/**
 * Creates a switch with a mask, the on/off and a thumb filenames.
 *
 * @see switchWithMaskSprite:onSprite:offSprite:thumbSprite:
 */
+ (id)switchWithMaskFile:(NSString *)maskFile onFile:(NSString *)onFile offFile:(NSString *)offFile thumbFile:(NSString *)thumbFile;

/** 
 * Initializes a switch with a mask sprite, on/off sprites for on/off states, a thumb sprite and an on/off labels.
 * @param maskSprite The sprite used as mask to hide on/off sprites.
 * @param onSprite The sprite displayed when the switch is in the on position.
 * @param offSprite The sprite displayed when the switch is in the off position.
 * @param thumbSprite The sprite used for the thumb.
 * @param onLabel The label displayed over the onSprite when the switch is in the on position.
 * @param offLabel The label displayed over the offSprite when the switch is in the off position.
 */
- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel;

/**
 * Creates a switch with a mask sprite, on/off sprites for on/off states, a thumb sprite and an on/off labels.
 *
 * @see initWithMaskSprite:onSprite:offSprite:thumbSprite:onLabel:offLabel:
 */
+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel;

/**
 * Creates a switch with a mask, the on/off and a thumb filenames and the on/off titles.
 *
 * @see switchWithMaskSprite:onSprite:offSprite:thumbSprite:onLabel:offLabel:
 */
+ (id)switchWithMaskFile:(NSString *)maskFile onFile:(NSString *)onFile offFile:(NSString *)offFile thumbFile:(NSString *)thumbFile onTitle:(NSString *)onTitle offTitle:(NSString *)offTitle;

#pragma mark - Properties
#pragma mark Setting the Off/On State
/** @name Setting the Off/On State */

/**
 * @abstract A Boolean value that determines the off/on state of the switch.
 * @discussion This property allows you to retrieve and set (without animation)
 * a value determining whether the CCControlSwitch object is on or off.
 */
@property (nonatomic, getter = isOn) BOOL on;

/**
 * @abstract Set the state of the switch to On or Off, optionally animating the
 * transition.
 *
 * @param isOn YES if the switch should be turned to the On position; NO if it 
 * should be turned to the Off position. If the switch is already in the 
 * designated position, nothing happens.
 * @param animated YES to animate the “flipping” of the switch; otherwise NO.
 * @discussion Setting the switch to either position does result in an action
 * message being sent.
 */
- (void)setOn:(BOOL)isOn animated:(BOOL)animated;

#pragma mark Customizing the Appearance of the Switch
/** @name Customizing the Appearance of the Switch */

/**
 * @abstract The color used to tint the appearance of the thumb when the switch
 * is pushed.
 * @discussion The default color is ccGRAY.
 */
@property(nonatomic, assign) ccColor3B onThumbTintColor;

#pragma mark - Public Methods

@end
