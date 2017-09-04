// Type definitions for NativeView
// Project: https://github.com/mfdeveloper/cordova-plugin-nativeview
// Definitions by: Michel Felipe <https://github.com/mfdeveloper> 
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped

interface NativeView {
  
    /**
     * Shows the native view.
     * 
     * Define the `packageOrClass` param to a package (Android) or a 
     * storyboard/classname (IOS)
     * 
     * ```ts
     * 
     * //Android
     * NativeView.show('com.mycompany', 'MyActivity')
     * 
     * //IOS
     * NativeView.show('MyStoryboard', 'MyUIViewController');
     * ```
     * 
     * @param packageOrClass
     * @param className 
     * @param success 
     * @param error 
     */
    show(packageOrClass: string, className: string, success: Function, error: Function): void;
  }
  
  declare var NativeView: NativeView;