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


Add this code snippet below to your `build.gradle` file

```groovy
allprojects {
    repositories {
        ...
        maven { url 'https://jitpack.io' }
    }
}

implementation ('com.github.mfdeveloper:cordova-plugin-nativeview:0.0.4')
```
> This dependency is added using [jitpack](https://jitpack.io)

Or add, the `NativeView` class directly to your android project:

* From your cordova project:

    - Copy the content off `platforms/android/assets/www` folder to your android project (usually, `app/src/main/assets`).
      Or create a **gradle** task to do this.
    - Copy the `config.xml` to `src/main/res/xml` android project folder.

* Clone this repo, and copy the class: `src/android/NativeView.java` to your Android project

* Or create a `.jar` or a `.aar` that contains this class, and import like a [Android module dependency](https://developer.android.com/studio/projects/android-library.html#AddDependency)

* Verify if the code snippet below is present in your `AndroidManifest.xml`. This is required to open a specific Activity from a [Intent](https://developer.android.com/reference/android/content/Intent.html) (using **[package + activityName]**)

```xml
<activity android:name=".MyActivity" >
    <intent-filter>
        <action android:name="com.mypackage.MyActivity" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</activity>
```
> If this filter not exists in `AndroidManifest.xml`, you will get this error: [No Activity found to handle Intent splash screen](https://stackoverflow.com/questions/15614561/android-content-activitynotfoundexception-no-activity-found-to-handle-intent-sp)

* Build/Run your android project!

## Supported Platforms

- ![Android](icons/android.png) Android
- ![iOS](icons/ios.png) iOS

## Methods

## NativeView.show(string packageOrClassName, string className)

Shows a native view.


**ANDROID**

```js

document.addEventListener("deviceready", function() {
    //  pass a package name and a activity by params
    cordova.plugins.NativeView.show('com.mycompany', 'MyActivity')
    .then(function() {
      
      /**
       * Do something when open the activity.
       * This code here will be executed in paralell,
       * not after open.
       */
    }).catch(function(error) {
        
        /**
         * error.success => Will be "false"
         * error.name => Exception type from the captured error 
         * error.message => A exception message
         */
    });
}, false);

```
**IOS**

```js

/*
*  Optionally, pass a storyboard name that contains
*  an UIViewController
*/
document.addEventListener("deviceready", function() {
    cordova.plugins.NativeView.show('MyStoryboard', 'MyUIViewController')
    .then(function() {
      
      /**
       * Do something when open the activity.
       * This code here will be executed in paralell,
       * not after open.
       */
    });

    /*
     *  Or, pass only the UIViewController name, if you don't
     *  use storyboards in your project.
     */
     cordova.plugins.NativeView.show('MyUIViewController');

     /*
     * Or just call the "show()" method without params.
     * This plugin will check whether exists a *"NavigationController" 
     * in your project, and execute
     * "[popViewControllerAnimated: Yes]" method. Else, will be throw a
     * exception
     * 
     */
     cordova.plugins.NativeView.show();

}, false);
```

**IONIC**

Replace `document.addEventListener` event to `this.platform.ready().then(...)` service method. See [IONIC Platform documentation](https://ionicframework.com/docs/api/platform/Platform/)
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## TODO

- Better catch IOS exception from JS
