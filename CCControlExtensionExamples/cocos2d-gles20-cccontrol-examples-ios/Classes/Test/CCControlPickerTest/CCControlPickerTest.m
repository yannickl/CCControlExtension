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
@property (nonatomic, strong) NSArray   *source;

@end

@implementation CCControlPickerTest
@synthesize source  = _source;

- (void)dealloc
{
    [_source release];
    
    [super dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        CGSize screenSize       = [[CCDirector sharedDirector] winSize];
        self.source             = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", nil];
        
        CCSprite *background    = [CCSprite spriteWithFile:@"pickerBackground.png"];
        CCSprite *selection     = [CCSprite spriteWithFile:@"pickerSelection.png"];
        CCControlPicker *picker = [[CCControlPicker alloc] initWithForegroundSprite:background selectionSprite:selection];
        picker.backgroundNode   = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        picker.anchorPoint      = ccp (0.5f, 0.5f);
        picker.position         = ccp (screenSize.width / 2, screenSize.height / 2);
        picker.dataSource       = self;
        picker.delegate         = self;
        picker.looping          = NO;
        picker.swipeOrientation = CCControlPickerOrientationVertical;
        [self addChild:picker z:0];
	}
	return self;
}

#pragma mark - CCControlPicker DataSource Methods

- (NSUInteger)numberOfRowsInControlPicker:(CCControlPicker *)controlPicker
{
    return [_source count];
}

- (CCControlPickerRow *)controlPicker:(CCControlPicker *)controlPicker nodeForRow:(NSUInteger)row
{
    return [CCControlPickerRow rowWithTitle:[_source objectAtIndex:row]];
}

#pragma mark - CCControlPicker Delegate Methods

- (void)controlPicker:(CCControlPicker *)controlPicker didSelectRow:(NSUInteger)row
{
}

@end
