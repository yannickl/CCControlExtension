/*
 * CCControlPicker.h
 *
 * Copyright 2013 Yannick Loriot. All rights reserved.
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
 * Swipe orientation.
 */
typedef enum
{
    CCControlPickerOrientationVertical,
    CCControlPickerOrientationHorizontal
} CCControlPickerOrientation;

@protocol CCControlPickerDataSource;
@protocol CCControlPickerDelegate;

/**
 * Picker control for Cocos2D.
 *
 * The CCControlPicker class implements objects, called control pickers, that
 * use a spinning-wheel or slot-machine metaphor to show one set of values.
 * Users select values by rotating the wheels so that the desired row of values
 * aligns with a selection indicator.
 *
 * @see http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlPicker.html
 */
@interface CCControlPicker : CCControl

#pragma mark Contructors - Initializers
/** @name Create Pickers */

/**
 * @abstract Initializes a picker by only defining the foreground sprite (with no
 * selection indicator).
 * @param foregroundSprite foreground sprite which defines the area of the picker.
 * @see initWithForegroundSprite:selectionSprite:
 */
- (id)initWithForegroundSprite:(CCSprite *)foregroundSprite;

/**
 * @abstract Creates a picker by only defining the foreground sprite (with no
 * selection indicator).
 * @see initWithForegroundSprite:
 */
+ (id)pickerWithForegroundSprite:(CCSprite *)foregroundSprite;

/**
 * @abstract Creates a picker by only defining the foreground filename (with no
 * selection indicator).
 * @see pickerWithForegroundSprite:
 */
+ (id)pickerWithForegroundFile:(NSString *)foregroundFile;

/**
 * @abstract Initializes a picker by defining the foreground and the selection sprites.
 * @param foregroundSprite foreground sprite which defines the area of the picker.
 * @param selectionSprite  selection indicator sprite.
 */
- (id)initWithForegroundSprite:(CCSprite *)foregroundSprite selectionSprite:(CCSprite *)selectionSprite;

/**
 * @abstract Creates a picker by defining the foreground and the selection sprites.
 * @see initWithForegroundSprite:selectionSprite:
 */
+ (id)pickerWithForegroundSprite:(CCSprite *)foregroundSprite selectionSprite:(CCSprite *)selectionSprite;

/**
 * @abstract Creates a picker by defining the foreground and the selection filenames.
 * @see pickerWithForegroundSprite:selectionSprite:
 */
+ (id)pickerWithForegroundFile:(NSString *)foregroundFile selectionFile:(NSString *)selectionFile;

#pragma mark - Properties
#pragma mark Changing the Picker’s Appearance
/** @name Changing the Picker’s Appearance */

/**
 * @abstract Contains the node that is drawn on the background of the picker.
 * @discussion The node you specify should fit within the bounding rectangle of
 * the foreground sprite. If it does not, the node will be clip.
 *
 * This default value of this property is nil.
 */
@property (nonatomic, strong) CCNode    *background;

#pragma mark Getting the Dimensions of the Control Picker
/** @name Getting the Dimensions of the Control Picker */
/**
 * @abstract Returns the size of a row.
 * @return The size of rows.
 * @discussion A picker control fetches the value of this property by
 * calling the rowHeightInControlPicker: delegate methods, and caches
 * it. The default value is CCControlPickerDefaultRowHeight.
 */
- (CGSize)rowSize;

/**
 * @abstract Returns the number of rows.
 * @return The number of rows.
 * @discussion A picker control fetches the value of this property
 * from the data source and and caches it. The default value is zero.
 */
- (NSUInteger)numberOfRows;

#pragma mark Managing the Behavior of the Control Picker
/** @name Managing the Behavior of the Control Picker */

/**
 * @abstract The swipe orientation of the picker.
 * @discussion The orientation constrains the swipe direction.
 * E.g if the orientation is set to CCControlPickerOrientationVertical
 * the element can move in vertical only.
 * 
 * The default value for this property is CCControlPickerOrientationVertical.
 */
@property (nonatomic, assign) CCControlPickerOrientation swipeOrientation;

/**
 * @abstract The looping vs. nonlooping state of the picker.
 * @discussion If YES, the picker will display the data source as a
 * loop. I.e that when the end of the source is reached the picker
 * will display the first element.
 *
 * The default value for this property is NO.
 */
@property (nonatomic, getter = isLooping) BOOL looping;

#pragma mark Specifying the Delegate
/** @name Specifying the Delegate */
/**
 * @abstract The delegate for the control picker.
 * @discussion The delegate must adopt the CCControlPickerDelegate protocol
 * and implement the required methods to respond to new selections or
 * deselections.
 */
@property(nonatomic, assign) id<CCControlPickerDelegate> delegate;

#pragma mark Specifying the Data Source
/** @name Specifying the Data Source */
/**
 * @abstract The data source for the control picker.
 * @discussion The data source must adopt the CCControlPickerDataSource
 * protocol and implement the required methods to return the number of
 * rows in each component.
 */
@property(nonatomic, assign) id<CCControlPickerDataSource> dataSource;

#pragma mark - Public Methods
#pragma mark Reloading the Control Picker
/** @name Reloading the Control Picker */

/**
 * Reloads the component of the picker control.
 */
- (void)reloadComponent;

#pragma mark Selecting Rows in the Control Picker
/** @name Selecting Rows in the Control Picker */

/**
 * Selects a row in the picker control.
 * @param row A zero-indexed number identifying a row of component.
 * @param animated YES to animate the selection by spinning the wheel
 * (component) to the new value; if you specify NO, the new selection
 * is shown immediately.
 */
- (void)selectRow:(NSUInteger)row animated:(BOOL)animated;

/**
 * Returns the index of the selected row.
 * @return A zero-indexed number identifying the selected row , or -1
 * if no row is selected.
 * @see selectRow:animated:
 */
- (NSInteger)selectedRow;

@end

#pragma mark - CCControlPickerRowDelegate

/**
 * The CCControlPickerRowDelegate class allows the receiver to respond to the
 * CCControlPicker's events. By implementing these methods you can improve the
 * user experience with appropriate visuals.
 */
@protocol CCControlPickerRowDelegate <NSObject>

@required

#pragma mark Responding to Control Picker Events
/** @name Responding to Control Picker Events */

/**
 * @abstract Notifies the row that enters under the selection node.
 * @discussion You can implement this method to perform additional tasks
 * associated with presenting the view.
 */
- (void)rowDidHighlighted;

/**
 * @abstract Notifies the row that leaves the selection node.
 * @discussion You can implement this method to perform additional tasks
 * associated with presenting the view.
 */
- (void)rowDidDownplayed;

/**
 * @abstract Notifies the row that will be selected.
 * @discussion You can implement this method to perform additional tasks
 * associated with presenting the view.
 */
- (void)rowWillBeSelected;

/**
 * @abstract Notifies the row that is selected.
 * @discussion You can implement this method to perform additional tasks
 * associated with presenting the view.
 */
- (void)rowDidSelected;

@end

#pragma mark - CCControlPickerRowNode

/**
 * The CCControlPickerRow class implements the row node representation for
 * the CCControlPicker.
 *
 * A row node implements some methods and callbacks to make the
 * CCControlPicker customization more easier.
 *
 * @see http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlPickerRow.html
 */
@interface CCControlPickerRow : CCNode <CCControlPickerRowDelegate>

#pragma mark Contructors - Initializers
/** @name Create Picker' Rows */

/** Initializes a simple row node with the content title. */
- (id)initWithTitle:(NSString *)title;
/** Creates a simple row node with the content title. */
+ (id)rowWithTitle:(NSString *)title;

#pragma mark Managing Text as Row Content
/** @name Managing Text as Row Content */

/**
 * @abstract Returns the label used for the main textual content of 
 * the control picker row. (read-only)
 * @discussion Holds the main label of the row. CCControlPickerRow
 * adds an appropriate label when you create the row.
 */
@property (nonatomic, readonly) CCLabelTTF  *textLabel;

#pragma mark Managing Row Size
/** @name Managing Row Size */

/**
 * @abstract Called when the size must resize.
 * @param size The size that the row should fit.
 * @discussion The method is called by the CCControlPicker when its needed.
 * The control picker uses the size defined by the rowSizeForControlPicker:
 * method of the CCControlPickerDelegate.
 *
 * You have to override this method to layout your cell correctly.<br />
 * (*do not forget to call the super [super fitRowInSize:size])*
 */
- (void)fitRowInSize:(CGSize)size;

@end

#pragma mark - CCControlPickerDataSource

/**
 * The CCControlPickerDataSource protocol must be adopted by an object
 * that mediates between a CCControlPicker object and your application’s
 * data model for that control picker. The data source provides the control
 * picker with the number of components, and the number of rows in the
 * component, for displaying the control picker data.
 * Both methods in this protocol are required.
 */
@protocol CCControlPickerDataSource <NSObject>

@required

#pragma mark Providing Counts for the Control Picke
/** @name Providing Counts for the Control Picker */

/**
 * Called by the picker control when it needs the number of rows. (required)
 * @param controlPicker The picker control requesting the data.
 * @return The number of rows.
 */
- (NSUInteger)numberOfRowsInControlPicker:(CCControlPicker *)controlPicker;

#pragma mark Setting the Content of Component Rows
/** @name Setting the Content of Component Rows */

/**
 * @abstract Called by the picker control when it needs the node to use for a given row.
 * @param controlPicker An object representing the control picker requesting the data.
 * @param row A zero-indexed number identifying a row of component. Rows are
 * numbered top-to-bottom.
 * @return The node to use as the visual representation of the indicated row.
 */
- (CCControlPickerRow *)controlPicker:(CCControlPicker *)controlPicker nodeForRow:(NSUInteger)row;

@end

#pragma mark - CCControlPickerDelegate

/**
 * The delegate of a CCControlPicker object must adopt this protocol and
 * implement at least some of its methods to provide the control picker with
 * the data it needs to construct itself.
 *
 * Typically the delegate implements optional methods to respond to new 
 * selections or deselections of component rows.
 *
 * See CCControlPicker Class Reference for a discussion of components, rows,
 * row content, and row selection.
 */
@protocol CCControlPickerDelegate <NSObject>

@optional

#pragma mark Setting the Dimensions of the Control Picker's row
/** @name Setting the Dimensions of the Control Picker's row */

/**
 * @abstract Called by the control picker when it needs the row size to use for drawing 
 * row content.
 * @param controlPicker The control picker requesting this information.
 * @return A CGSize indicating the size of the row in points.
 */
- (CGSize)rowSizeForControlPicker:(CCControlPicker *)controlPicker;

#pragma mark Responding to Row Selection
/** @name Responding to Row Selection */
/**
 * @abstract Called by the control picker when the user selects a row.
 * @param controlPicker An object representing the control picker view 
 * requesting the data.
 * @param row A zero-indexed number identifying a row of component.
 * Rows are numbered top-to-bottom.
 * @discussion To determine what value the user selected, the delegate
 * uses the row index to access the value at the corresponding position
 * in the array used to construct the component.
 */
- (void)controlPicker:(CCControlPicker *)controlPicker didSelectRow:(NSUInteger)row;

@end;
