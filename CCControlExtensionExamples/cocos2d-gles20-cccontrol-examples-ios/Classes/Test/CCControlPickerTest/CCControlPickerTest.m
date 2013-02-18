/*
 * CCControlPickerTest.m
 *
 * Copyright (c) 2013 Yannick Loriot
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

#import "CCControlPickerTest.h"

@interface CCControlPickerTest ()
@property (nonatomic, strong) NSArray           *source;
@property (nonatomic, retain) CCLabelTTF        *displayValueLabel;
@property (nonatomic, strong) CCControlPicker   *picker;

- (CCControlPicker *)makeControlPicker;

@end

@implementation CCControlPickerTest
@synthesize source              = _source;
@synthesize displayValueLabel   = _displayValueLabel;
@synthesize picker              = _picker;
- (void)dealloc
{
    [_source            release];
    [_displayValueLabel release];
    [_picker            release];
    
    [super              dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        CGSize screenSize           = [[CCDirector sharedDirector] winSize];
        self.source                 = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", nil];
        
        CCNode *layer               = [CCNode node];
        layer.position              = ccp (screenSize.width / 2, screenSize.height / 2);
        [self addChild:layer z:1 tag:1];
        
        double layer_width = 0;
        
        // Add the black background for the text
        CCScale9Sprite *background  = [CCScale9Sprite spriteWithFile:@"buttonBackground.png"];
        background.contentSize      = CGSizeMake(80, 50);
        background.position         = ccp(layer_width + background.contentSize.width / 2.0f, 0);
        [layer addChild:background];
        
        layer_width += background.contentSize.width;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-Bold" fontSize:30];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        self.displayValueLabel      = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:30];
#endif
        _displayValueLabel.position = background.position;
        [layer addChild:_displayValueLabel];
        
        // Create the picker and add it to the layer
        self.picker                 = [self makeControlPicker];
        _picker.position            = ccp(layer_width + 10 + _picker.contentSize.width / 2, 0);
        [layer addChild:_picker];
        
        layer_width                 += _picker.contentSize.width;
        
        // Set the layer size
        layer.contentSize           = CGSizeMake(layer_width, 0);
        layer.anchorPoint           = ccp (0.5f, 0.5f);
	}
	return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [_picker selectRow:1 animated:YES];
}

#pragma mark - Public Methods
#pragma mark - Private Methods

- (CCControlPicker *)makeControlPicker
{
    CCSprite *pbackground       = [CCSprite spriteWithFile:@"pickerBackground.png"];
    CCSprite *pselection        = [CCSprite spriteWithFile:@"pickerSelection.png"];
    
    CCControlPicker *picker     = [[CCControlPicker alloc] initWithForegroundSprite:pbackground selectionSprite:pselection];
    picker.background           = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
    picker.anchorPoint          = ccp (0.5f, 0.5f);
    picker.dataSource           = self;
    picker.delegate             = self;
    picker.looping              = NO;
    picker.swipeOrientation     = CCControlPickerOrientationVertical;
    
    return [picker autorelease];
}

#pragma mark - CCControlPicker DataSource Methods

- (NSUInteger)numberOfRowsInControlPicker:(CCControlPicker *)controlPicker
{
    return [_source count];
}

- (CCControlPickerRow *)controlPicker:(CCControlPicker *)controlPicker nodeForRow:(NSUInteger)row
{
    CCControlPickerRow *rowNode = [CCControlPickerRow node];
    rowNode.textLabel.string    = [_source objectAtIndex:row];
    
    return rowNode;
}

#pragma mark - CCControlPicker Delegate Methods

- (CGSize)rowSizeForControlPicker:(CCControlPicker *)controlPicker
{
    return CGSizeMake(35, 45);
}

- (void)controlPicker:(CCControlPicker *)controlPicker didSelectRow:(NSUInteger)row
{
    _displayValueLabel.string   = [_source objectAtIndex:row];
}

@end
