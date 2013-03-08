CCControlExtension
=================
CCControlExtension is an open-source library which provides a lot of convenient control objects for __Cocos2D v2.x__ for iPhone and Mac such as buttons, sliders or many more... ([see the exhaustive list](#available-control-list))

All these controls are subclasses of CCControl, which is inspired by the UIControl API from the UIKit of CocoaTouch. The main goal of CCControl is to simplify the creation of control objects in Cocos2D by providing an interface and a base implementation ala UIKit. I.e that this class manages the target-action pair registration and dispatches them to their targets when events occur.
The CCControl extensions also uses the power of blocks to dispatch the events in addition to the target/action pair. 

*Note: The CCControlExtension's classes are ARC compatibles (e.g for use with Kobold2D)*

*Note2: the version for __Cocos2D v1.1__ is available in the [master branch](https://github.com/YannickL/CCControlExtension/tree/master)*

![](http://github.com/YannickL/CCControlExtension/raw/master/screenshots/cccontrolextension.png)

Available Control List
====================

  * [Button](http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlButton.html):
Intercepts touch events and sends an action message to a target object when tapped.
  * [Colour Picker](http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlColourPicker.html):
It's a very useful control tool to preview and test color values.
  * [Picker](http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlPicker.html):
Use a spinning-wheel or slot-machine metaphor to show one set of values.
  * [Potentiometer](http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlPotentiometer.html):
Use a circular representation to show and select a single value from a continuous range of value.
  * [Slider](http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlSlider.html):
Use a linear representation to show and select a single value from a continuous range of values.
  * [Stepper](http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlStepper.html):
User interface for incrementing or decrementing a value.
  * [Switch](http://yannickloriot.com/library/ios/cccontrolextension/Classes/CCControlSwitch.html):
Useful to create and manage On/Off buttons, like for example, in the option menus for volume as example.

How to use it
====================
- Include the CCControlExtension folder into your project
- In the needed files include this header:

        #import "CCControlExtension.h"

The `CCControlExtension.h` includes all the already controls.
There are various [examples][] to understand how the controls works and to use pre-made visual for each of them.

For more informations you can check [my blog][] and the [api documentation][].
  
Getting started with the source
===================== 
The project already include a version of Cocos2D for its examples, so you just need to download the source like the following instructions:

```
    git clone git@github.com:YannickL/CCControlExtension.git

    # to get latest stable source from master branch, use this command:
    cd CCControlExtension
    git checkout master-v2

    # to update the sources
    git pull
```

Build & Runtime Requirements
====================

  * Xcode 4.2 or newer (LLVM 3.0 or newer)
  * iOS 4.0 or newer for iOS games
  * Mac OS X 10.6 or newer for Mac games

License (MIT)
====================
As well as Cocos2D for iPhone, CCControlExtension is licensed under the MIT License:

Copyright (c) 2013 - Yannick Loriot and contributors
(see each file to see the different copyright owners)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
You can download *cocos2d-for-iphone* here: https://github.com/cocos2d/cocos2d-iphone

[my blog]: http://yannickloriot.com/2013/02/the-control-extension-for-cocos2d/
[examples]: https://github.com/YannickL/CCControlExtension/tree/master-v2/CCControlExtensionExamples
[api documentation]: http://yannickloriot.com/library/ios/cccontrolextension/
