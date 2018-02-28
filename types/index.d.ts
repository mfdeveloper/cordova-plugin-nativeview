// Type definitions for NativeView
// Project: https://github.com/mfdeveloper/cordova-plugin-nativeview
// Definitions by: Michel Felipe <https://github.com/mfdeveloper> 
interface CordovaPlugins {
  NativeView: NativeView
}

interface ResultView {
  success: boolean;
  name?: string;
  message?: string;
}
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
   * cordova.plugins.NativeView.show('com.mycompany', 'MyActivity')
   * .then(() => {
   *    // Do something
   * });
   * 
   * //IOS
   * cordova.plugins.NativeView.show('MyStoryboard', 'MyUIViewController')
   * .then(() => {
   *    // Do something
   * });
   * 
   * //OR Back to previous View (IOS only)
   * cordova.plugins.NativeView.show().then(() => {
   *    // Do something
   * });
   * 
   * ```
   * 
   * @param packageOrClass Package or class name of view to open
   * @param className Class name of view to open
   * @param success [Optional] Callback when success, if you don't want use promise "then()"
   * @param error [Optional] Callback when error happens, if you don't want use promise "catch()"
   */
  show(packageOrClass?: string, className?: string, success?: Function, error?: Function): Promise<ResultView | void>;
}