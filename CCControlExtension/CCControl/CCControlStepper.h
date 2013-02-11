/*
 * CCControlStepper.h
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

typedef enum
{
    kCCControlStepperPartMinus,
    kCCControlStepperPartPlus,
    kCCControlStepperPartNone,
} CCControlStepperPart;

/**
 * CCControlStepper is a stepper control provides a user interface for 
 * incrementing or decrementing a value.
 */
@interface CCControlStepper : CCControl
{
@public
    double                  _value;
    BOOL                    _continuous;
    BOOL                    _autorepeat;
    BOOL                    _wraps;
    double                  _minimumValue;
    double                  _maximumValue;
    double                  _stepValue;
        
@protected
    // Weak links to childrens
	CCSprite                *_minusSprite;
    CCSprite                *_plusSprite;
    CCLabelTTF              *_minusLabel;
    CCLabelTTF              *_plusLabel;
    
    BOOL                    _touchInsideFlag;
    CCControlStepperPart    _touchedPart;
    NSInteger               _autorepeatCount;
}
/** @name Accessing the Stepper’s Value */
/** The numeric value of the stepper. */
@property (nonatomic) double value;

/** @name Configuring the Stepper */
/** The continuous vs. noncontinuous state of the stepper. */
@property (nonatomic, getter=isContinuous) BOOL continuous;
/** The automatic vs. nonautomatic repeat state of the stepper. */
@property (nonatomic) BOOL autorepeat;
/** The wrap vs. no-wrap state of the stepper. */
@property (nonatomic) BOOL wraps;
/** The lowest possible numeric value for the stepper. */
@property (nonatomic) double minimumValue;
/** The highest possible numeric value for the stepper. */
@property (nonatomic) double maximumValue;
/** The step, or increment, value for the stepper. */
@property (nonatomic) double stepValue;

#pragma mark Contructors - Initializers
/** @name Creating Steppers */

/**
 * Initializes a stepper with a minus and plus sprites.
 */
- (id)initWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite;

/**
 * Creates a stepper with a minus and plus sprites.
 *
 * @see initWithMinusSprite:plusSprite:
 */
+ (id)stepperWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite;

#pragma mark - Public Methods

@end
