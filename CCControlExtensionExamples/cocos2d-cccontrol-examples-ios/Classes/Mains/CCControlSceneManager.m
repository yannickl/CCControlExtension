/*
 * CCControlSceneManager.m
 *
 * Copyright (c) 2011 Yannick Loriot
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

#import "CCControlSceneManager.h"

#import "CCControlScene.h"

@interface CCControlSceneManager ()
/** Control scene id. */
@property (nonatomic, assign) NSInteger currentControlSceneId;
/** List of control scene's names. */
@property (nonatomic, retain) NSArray *controlScenes;

@end

@implementation CCControlSceneManager
@synthesize currentControlSceneId, controlScenes;

static CCControlSceneManager *sharedInstance = nil;

- (void)dealloc
{
    [controlScenes release], controlScenes = nil;
    
    if (sharedInstance)
    {
        [sharedInstance release];
    }
    
    [super dealloc];
}

#pragma mark Constructors - Initializers

- (id)init
{
    if ((self = [super init]))
    {
        currentControlSceneId = 0;
        
        controlScenes = [[NSArray alloc] initWithObjects:
                         @"CCControlSliderTest",
                         @"CCControlColourPickerTest",
                         @"CCControlSwitchTest",
                         @"CCControlStepperTest",
                         @"CCControlButtonTest_Event",
                         @"CCControlButtonTest_HelloVariableSize",
                         @"CCControlButtonTest_Styling",
                         @"CCControlPotentiometerTest",
                         @"CCControlPickerTest",
                         nil];
    }
    return self;
}

+ (CCControlSceneManager *)sharedControlSceneManager
{
    @synchronized (self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

#pragma mark -
#pragma mark CCControlSceneManager Public Methods

- (CCScene *)nextControlScene
{
	currentControlSceneId = (currentControlSceneId + 1) % [controlScenes count];
    
	return [self currentControlScene];
}

- (CCScene *)previousControlScene
{
	currentControlSceneId = currentControlSceneId - 1;
    if (currentControlSceneId < 0)
    {
        currentControlSceneId = [controlScenes count] - 1;
    }
    
	return [self currentControlScene];
}

- (CCScene *)currentControlScene
{
	NSString *controlSceneName = [controlScenes objectAtIndex:currentControlSceneId];
    
    Class nextControlScene = NSClassFromString(controlSceneName);
	return [nextControlScene sceneWithTitle:controlSceneName];
}

#pragma mark CCControlSceneManager Private Methods

@end
