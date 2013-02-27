/*
 * CCControlColourPicker.h
 *
 * Copyright 2012 Stewart Hamilton-Arrandale.
 * http://creativewax.co.uk
 *
 * Modified in 2012/2013 by Yannick Loriot.
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
#import "CCColourUtils.h"

/** Defines the possible arrow directions. */
typedef enum
{
    CCControlColourPickerArrowDirectionTop,
    CCControlColourPickerArrowDirectionBottom,
    CCControlColourPickerArrowDirectionRight,
    CCControlColourPickerArrowDirectionLeft
} CCControlColourPickerArrowDirection;

@class CCControlSaturationBrightnessPicker;
@class CCControlHuePicker;

/**
 * Colour Picker control for Cocos2D.
 *
 * The color picker is a very useful control tool to preview 
 * and test color values.
 *
 * @see http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlColourPicker.html
 */
@interface CCControlColourPicker : CCControl
{
@public
    CCSprite                            *_arrow;
    CCControlColourPickerArrowDirection _arrowDirection;
    
@protected
    HSV                                 _hsv;
    
    CCControlSaturationBrightnessPicker *_colourPicker;
    CCControlHuePicker                  *_huePicker;
}
#pragma mark - Constuctors - Initializers
/** @name Create ColourPickers */

/**
 * Initializes a colour picker by given its differents component names (without arrow).
 * @param hueBackgroundFile the hue color wheel filename
 * @param tintBackgroundFile the background filename for the tint/shade representation.
 * @param tintOverlayFile the overlay filename for the tint/shade representation.
 * @param pickerFile filename for the hue and the tint pickers.
 * @see initWithHueFile:tintBackgroundFile:tintOverlayFile:pickerFile:arrowFile:
 */
- (id)initWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile;

/**
 * Creates a colour picker by given its differents component names.
 * @see initWithHueFile:tintBackgroundFile:tintOverlayFile:pickerFile:
 */
+ (id)colourPickerWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile;

/**
 * Initializes a colour picker by given its differents component names.
 * @param hueBackgroundFile the hue color wheel filename
 * @param tintBackgroundFile the background filename for the tint/shade representation.
 * @param tintOverlayFile the overlay filename for the tint/shade representation.
 * @param pickerFile filename for the hue and the tint pickers.
 * @param arrowFile file for the arrow which represents the attachement direction.
 */
- (id)initWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile arrowFile:(NSString *)arrowFile;

/**
 * Creates a colour picker by given its differents component names.
 * @see initWithHueFile:tintBackgroundFile:tintOverlayFile:pickerFile:arrowFile:
 */
+ (id)colourPickerWithHueFile:(NSString *)hueBackgroundFile tintBackgroundFile:(NSString *)tintBackgroundFile tintOverlayFile:(NSString *)tintOverlayFile pickerFile:(NSString *)pickerFile arrowFile:(NSString *)arrowFile;

#pragma mark - Properties

#pragma mark Managing the Arrow of the Colour Picker
/** @name Managing the Arrow of the Colour Picker */

/**
 * @abstract Contains the sprite to represent the attachment as arrow shape.
 * @discussion By default there is no arrow.
 * @see initWithHueFile:tintBackgroundFile:tintOverlayFile:pickerFile:arrowFile:
 */
@property (nonatomic, strong) CCSprite *arrow;

/**
 * @abstract The arrow direction/orientation.
 * @discussion By default the arrow direction is set to CCControlColourPickerArrowDirectionRight.
 */
@property (nonatomic, assign) CCControlColourPickerArrowDirection arrowDirection;

#pragma mark Getting the Color
/** @name Getting the Color */

/** The current color of the picker. */
@property (nonatomic, readwrite) ccColor3B color;

#pragma mark - Public Methods

@end
