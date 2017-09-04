import UIKit

///
/// IOS implementation for Native view actions from cordova apps
///
/// - Author: @mfdeveloper on 29/08/17.
///
@objc(CDVNativeView)
class CDVNativeView: CDVPlugin {
    
    override func pluginInitialize() {
        NSLog("%@", "NativeViewPlugin initialized");
    }
    
    /**
        Show a native view from a cordova app.
        If exists a navigationController associated with your cordova
        UIViewController, back to your main view.

        - Parameters:
            - command: Get arguments and callback status from JS
    */
    func show(_ command: CDVInvokedUrlCommand) {
        
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        var className = command.argument(at: 0) as? String ?? ""
        var storyboardName = ""
        
        if command.arguments.count > 1 {
            
            let secondParam = command.argument(at: 1);
            
            if secondParam != nil {
                storyboardName = className
                className = secondParam as? String ?? ""
            }
            
        }
        
        if self.viewController.navigationController != nil {
            
            if (self.viewController.navigationController?.viewControllers.count)! > 1 {
                self.viewController.navigationController?.popViewController(animated: true)
            }else{
                self.viewController.navigationController?.pushViewController(UIViewController.init(nibName: className, bundle: nil), animated: true)
            }
            
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        }else{
            
            let viewController: UIViewController
            
            if Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") != nil
                && storyboardName.characters.count > 0 {
                
                let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
                
                viewController = storyboard.instantiateViewController(withIdentifier: className)
                
            }else{
                viewController = UIViewController.init(nibName: className, bundle: nil)
            }
            
            let appDelegate = UIApplication.shared.delegate as! CDVAppDelegate
            appDelegate.window.rootViewController = viewController
            
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        }
        
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        
    }

}
