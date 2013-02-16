/*
 * CCControlSlider
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

/**
 * Slider control for Cocos2D.
 *
 * A CCControlSlider object is a visual control used to select a single
 * value from a continuous range of values. An indicator, or thumb, notes
 * the current value of the slider and can be moved by the user to change 
 * the setting.
 *
 * @see http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlSlider.html
 */
@interface CCControlSlider : CCControl 
{  
@public
	float       _value;
    float       _minimumValue;
    float       _maximumValue;
    
@protected
	// Weak links to children
	CCSprite    *_thumbSprite;
    CCSprite    *_progressSprite;
	CCSprite    *_backgroundSprite;
}

#pragma mark Contructors - Initializers
/** @name Creating Sliders */

/** 
 * Creates slider with a background filename, a progress filename and a 
 * thumb image filename.
 *
 * @see sliderWithBackgroundSprite:progressSprite:thumbSprite:
 */
+ (id)sliderWithBackgroundFile:(NSString *)bgFile progressFile:(NSString *)progressFile thumbFile:(NSString *)thumbFile;

/** 
 * Creates a slider with a given background sprite and a progress bar and a
 * thumb item.
 *
 * @see initWithBackgroundSprite:progressSprite:thumbSprite:
 */
+ (id)sliderWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)pogressSprite thumbSprite:(CCSprite *)thumbSprite;

/** 
 * Initializes a slider with a background sprite, a progress bar and a thumb
 * item.
 *
 * @param backgroundSprite  CCSprite, that is used as a background.
 * @param progressSprite    CCSprite, that is used as a progress bar.
 * @param thumbSprite       CCSprite, that is used as a thumb.
 */
- (id)initWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)progressSprite thumbSprite:(CCSprite *)thumbSprite;

#pragma mark - Properties
#pragma mark Accessing the Slider’s Value
/** @name Accessing the Slider’s Value */
/**
 * @abstract Contains the receiver’s current value.
 * @discussion Setting this property causes the receiver to redraw itself
 * using the new value. To render an animated transition from the current
 * value to the new value, you should use the setValue:animated: method
 * instead.
 *
 * If you try to set a value that is below the minimum or above the maximum
 * value, the minimum or maximum value is set instead. The default value of
 * this property is 0.0.
 */
@property (nonatomic, assign) float value;

/**
 * @abstract Sets the receiver’s current value, allowing you to animate the
 * change visually.
 *
 * @param value The new value to assign to the value property.
 * @param animated Specify YES to animate the change in value when the
 * receiver is redrawn; otherwise, specify NO to draw the receiver with the
 * new value only. Animations are performed asynchronously and do not block
 * the calling thread.
 * @discussion If you try to set a value that is below the minimum or above
 * the maximum value, the minimum or maximum value is set instead. The
 * default value of this property is 0.0.
 * @see value
 */
- (void)setValue:(float)value animated:(BOOL)animated;

#pragma mark Accessing the Slider’s Value Limits
/** @name Accessing the Slider’s Value Limits */
/**
 * @abstract Contains the minimum value of the receiver.
 * @discussion If you change the value of this property, and the current
 * value of the receiver is below the new minimum, the current value is
 * adjusted to match the new minimum value automatically.
 *
 * The default value of this property is 0.0.
 */
@property (nonatomic, assign) float minimumValue;
/**
 * @abstract Contains the maximum value of the receiver.
 * @discussion If you change the value of this property, and the current
 * value of the receiver is above the new maximum, the current value is
 * adjusted to match the new maximum value automatically.
 *
 * The default value of this property is 1.0.
 */
@property (nonatomic, assign) float maximumValue;

#pragma mark Customizing the Appearance of the Slider
/** @name Customizing the Appearance of the Slider */

/**
 * @abstract The color used to tint the appearance of the thumb when the slider
 * is pushed.
 * @discussion The default color is ccGRAY.
 */
@property(nonatomic, assign) ccColor3B onThumbTintColor;

#pragma mark - Public Methods

@end  
