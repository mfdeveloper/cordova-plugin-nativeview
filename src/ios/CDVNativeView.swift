import UIKit

enum InstantiateViewControllerError: Error  {
    case notFound(String)
    case nameNotDefined(String)
}

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
        var viewController: UIViewController? = nil
        
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
                
                viewController = self.tryInstantiateView(name: className)
                
                self.viewController.navigationController?.pushViewController(viewController!, animated: true)
            }
            
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        }else if className.characters.count > 0 {
            
            if Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") != nil
                && storyboardName.characters.count > 0 {
                
                let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
                
                viewController = storyboard.instantiateViewController(withIdentifier: className)
                
            }else{
                
                viewController = self.tryInstantiateView(name: className)
                
            }
            
            let appDelegate = UIApplication.shared.delegate as! CDVAppDelegate
            appDelegate.window.rootViewController = viewController
            
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        }else{
            do {
                return try self.raiseClassNameError()
            } catch InstantiateViewControllerError.notFound(let errorMessage) {
                print(errorMessage)
            }catch {
                print("The first param 'packageOrClass' is required")
            }
        }
        
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        
    }
    
    private func instantiateViewController(name: String) throws -> UIViewController {
        
        if Bundle.main.path(forResource: name, ofType: "nib") != nil {
            return UIViewController.init(nibName: name, bundle: nil)
        }
        
        throw InstantiateViewControllerError.notFound("The ViewController: \(name) was not found")
    }
    
    private func tryInstantiateView(name: String) -> UIViewController? {
        
        do {
            return try self.instantiateViewController(name: name)
        } catch InstantiateViewControllerError.notFound(let errorMessage) {
            print(errorMessage)
        }catch {
            print("An error happens when try instantiate the ViewController: \(name)")
        }
        
        return nil
    }
    
    private func raiseClassNameError() throws {
        throw InstantiateViewControllerError.nameNotDefined("The UIViewController name is required when the project don't have a navigationController. Please, pass a className by param in JS, like this: 'NativeView.show('MyUIViewController')");
    }
    
}
