[![npm version](https://badge.fury.io/js/cordova-plugin-nativeview.svg)](https://badge.fury.io/js/cordova-plugin-nativeview)
[![](https://jitpack.io/v/mfdeveloper/cordova-plugin-nativeview.svg)](https://jitpack.io/#mfdeveloper/cordova-plugin-nativeview)

---
title: NativeView
description: Starts native view or another app, from a cordova app.
---

# cordova-plugin-nativeview

Start an UIViewController(_IOS_) or Activity(_Android_) relative to your cordova app, or an external app (based in [cordova plugin startapp](https://github.com/mfdeveloper/com.lampa.startapp) cordova plugin)

You can use this in a standalone project (basic cordova project), or into an existing native _Android/IOS_ application, like described in [Embed Cordova in native apps](https://cordova.apache.org/docs/en/latest/guide/hybrid/webviews/index.html)

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
pod 'cordova-plugin-nativeview', '~> 1.0.7'

# Swift version (needs update to latest Objective-c implementations)
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

implementation ('com.github.mfdeveloper:cordova-plugin-nativeview:1.0.7')
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

### NativeView.show(packageOrClassName: string, className: string)

OR

### NativeView.show(params: object)

> Shows a native view.


### ANDROID

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

    // Preferably, pass the Package and Activity in a json
    cordova.plugins.NativeView.show({
        packageName: 'com.mycompany',
        className: 'MyActivity',
    });

}, false);

```
### IOS


 - Pass `Storyboard` name and `storyboard id`

```js
document.addEventListener("deviceready", function() {

    /*
     * The first param is a storyboard name, and
     * the second param is a storyboardId 
     * (conventionally the same name of the ViewController class name)
     */
    cordova.plugins.NativeView.show('MyStoryboard', 'MyUIViewController')
    .then(function() {
      
      /**
       * Do something when open the activity.
       * This code here will be executed in paralell,
       * not after open.
       */
    });

    // Preferably, pass the ViewController and Storyboard in a json
    cordova.plugins.NativeView.show({
        storyboardName: 'MyStoryboard',
        viewControllerName: 'MyUIViewController'
    });

}, false);

```

- Pass only the `ViewController` class/xib name

```js
/*
*  Or, pass only the UIViewController name, if you don't
*  use storyboards in your project. This plugin try instantiate
*  from a ".xib" file. If not exists, try instantiate just by
*  UIViewController class.
* 
*  By convention, your ViewController class/xib needs contains 'Controller' 
*  string in any part of the name 
* .
*/
cordova.plugins.NativeView.show('MyUIViewController');

// Preferably, pass the ViewController in a json
cordova.plugins.NativeView.show({
    viewControllerName: 'MyUIViewController'
});
```

- Pass only the `Storyboard` name

```js
/*
*  Or, pass only the Storyboard name. If you don't pass a 
*  ViewController class name in second param, the 
*  "rootViewController" of your storyboard will be
*  instantiated. 
* 
*  By convention, your Storyboard name needs contains 'Storyboard' 
*  string in any part of the name
*/
cordova.plugins.NativeView.show('MyStorboard');

// Preferably, pass the Storyboard in a json
cordova.plugins.NativeView.show({
    storyboardName: 'MyStorboard'
});
````

### NativeView.checkIfAppInstalled(uri: string)

OR

### NativeView.checkIfAppInstalled(params: { uri: string })

> Verify if another app that responds to a `uri` is installed on device.

```js

cordova.plugins.NativeView.checkIfAppInstalled('another-app://custom-host')
.then(function() {
    console.log('The app is INSTALLED!');
}).catch(function(error) {
    console.log("The app is NOT INSTALLED!");
    throw error;
});

// Preferably, pass the uri in a json
cordova.plugins.NativeView.show({
    uri: 'another-app://custom-host'
});
```

### NativeView.showMarket(marketId: string)

OR

### NativeView.showMarket(params: { marketId: string })

> Open the store (Apple Store/Google Play) app installed in your device, or in a browser.

### ANDROID

```js

// Pass a app package on Android (found this on Google Play)
cordova.plugins.NativeView.showMarket('my.company.other.app');

// Preferably, pass the marketId in a json
cordova.plugins.NativeView.show({
    marketId: 'my.company.other.app'
});
```

### IOS

```js

// Pass a app id from the Apple Store
cordova.plugins.NativeView.showMarket('idxyz1?mt=x');

// Preferably, pass the marketId in a json
cordova.plugins.NativeView.showMarket({
    marketId: 'idxyz1?mt=x'
});
```

### NativeView.getBuildVariant(params: { catchError: boolean })

> Get the current Android build variant configured in 

### ANDROID (ONLY)

```js

/*
* Pass the param "catchError", and use the `catch()` method to verify an 
* error (if happens)
*
* Otherwise, this method will return the variant like a string,
* or null if not found.
*
* This is useful if you need show a NativeView by environment
*/
cordova.plugins.NativeView.getBuildVariant({
    catchError: true
}).then(function(value) {
    console.log('My environment is: ' + value);
}).catch(function(error) {
    if (!error.success && error.message) {
        console.log(error.message);
    }
});

/* Optionally, don't pass any parameter and get the Build Variant 
 * value, or NULL
 */
cordova.plugins.NativeView.getBuildVariant()
.then(function(value) {
    console.log('My environment is: ' + value);
});
```

### IONIC

Replace `document.addEventListener` event to `this.platform.ready().then(...)` service method. See [IONIC Platform documentation](https://ionicframework.com/docs/api/platform/Platform/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## TODO

- [x] Better catch IOS exception from JS
- [ ] Update `Swift` implementation
- [ ] Add cordova integration tests
 