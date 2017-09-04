---
title: File
description: Read/write files on the device.
---

# cordova-plugin-nativeview

Start or Back to a UIViewController(_ios_) or Activity(_Android_) relative to your cordova app.

You can use this in a standalone project (basic cordova project), or into a existing native _Android/IOS_ application, like descibed in [Embed Cordova in native apps](https://cordova.apache.org/docs/en/latest/guide/hybrid/webviews/index.html)

> **OBS:** If you wish just exit from cordova app or back to native view (Android only), use: `navigator['app'].exitApp()`

## Installation

    cordova plugin add cordova-plugin-nativeview --save

## Supported Platforms

- ![Android](icons/android.png) Android
- ![iOS](icons/ios.png) iOS

## Methods

## NativeView.show(string packageOrClassName, string className)

Shows a native view.


**Android**

```js

//  pass a package name and a activity by params
window.NativeView.show('com.mycompany', 'MyActivity');

```
**IOS**

```js

/*
*  Optionally, pass a storyboard name that contains
*  an UIViewController
*/
window.NativeView.show('MyStoryboard', 'MyUIViewController');

/*
*  Or, pass only the UIViewController name, if you don't
*  use storyboards in your project.
*/
window.NativeView.show('MyUIViewController');
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details