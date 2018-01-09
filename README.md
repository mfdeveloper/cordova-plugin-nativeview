---
title: NativeView
description: Starts native view from a cordova app.
---

# cordova-plugin-nativeview

Start or Back to a UIViewController(_ios_) or Activity(_Android_) relative to your cordova app.

You can use this in a standalone project (basic cordova project), or into a existing native _Android/IOS_ application, like described in [Embed Cordova in native apps](https://cordova.apache.org/docs/en/latest/guide/hybrid/webviews/index.html)

> **OBS:** If you wish just **EXIT** from cordova app or back to native view (Android only), use: `navigator['app'].exitApp()`

## Installation
    
```bash
cordova plugin add cordova-plugin-nativeview --save

# using IONIC
ionic cordova plugin add cordova-plugin-nativeview --save
```

### Extra: Native app (_Android/IOS_ native code)

**ALL PLATFORMS**

Make sure that `config.xml` file contains the `<feature>` tag below:

```xml
<feature name="NativeView">
    <param name="android-package" value="br.com.mfdeveloper.cordova.NativeView" />
    <param name="onload" value="true" />
</feature>
```

**IOS**

* Copy the `config.xml` from your cordova project to root XCode project directory.
* Install [cocoapods](https://cocoapods.org/)
* Add this plugin like a [pod](https://guides.cocoapods.org/syntax/podfile.html) dependency:

```ruby
# Objective-C version (Default)
pod 'cordova-plugin-nativeview', '~> 0.0.2'

# Swift version (work in progress)
pod 'cordova-plugin-nativeview', :git => 'https://github.com/mfdeveloper/cordova-plugin-nativeview.git', :branch => 'swift'
```

**ANDROID**

Until here, this plugin is not registered on cloud. In future, this plugin will be on [jcenter](https://bintray.com/bintray/jcenter) and/or [mavencentral](https://search.maven.org/). By now, you need:

* From your cordova project:

    - Copy the content off `platforms/android/assets/www` folder to your android project (usually, `app/src/main/assets`).
      Or create a **gradle** task to do this.
    - Copy the `config.xml` to `src/main/res/xml` android project folder.

* Clone this repo, and copy the class: `src/android/NativeView.java` to your Android project

* Or create a `.jar` or a `.aar` that contains this class, and import like a [Android module dependency](https://developer.android.com/studio/projects/android-library.html#AddDependency)

* Build/Run your android project!

## Supported Platforms

- ![Android](icons/android.png) Android
- ![iOS](icons/ios.png) iOS

## Methods

## NativeView.show(string packageOrClassName, string className)

Shows a native view.


**ANDROID**

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
