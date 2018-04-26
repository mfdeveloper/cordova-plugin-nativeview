//
//  CDVNativeView.m
//
//  Created by Michel Felipe on 05/09/17.
//
//

#import "CDVNativeView.h"
#import <UIKit/UIKit.h>

@interface CDVNativeView (hidden)

-(UIViewController *) instantiateViewControllerWithName: (NSString*) name;
-(UIViewController *) tryInstantiateViewWithName: (NSString*) name;

@end

@implementation CDVNativeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.resultExceptions = @{
          @"IoException": ^{
              return CDVCommandStatus_IO_EXCEPTION;
          },
          @"NotFoundException": ^{
              return CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION;
          },
          @"ParamInvalidException": ^{
              return CDVCommandStatus_ERROR;
          },
          @"InstantiationException": ^{
              return CDVCommandStatus_INSTANTIATION_EXCEPTION;
          },
          @"NoResultException": ^{
              return CDVCommandStatus_NO_RESULT;
          },
          @"ParamsTypeException": ^{
              return CDVCommandStatus_INVALID_ACTION;
          }
       };
   }
    return self;
}
- (void)show:(CDVInvokedUrlCommand*)command {
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    
    NSString* className = [command argumentAtIndex: 0];
    NSString* storyboardName = @"";
    
    UIViewController *viewController = nil;
    
    if ([command.arguments count] > 1) {
        
        NSString* secondParam = [command argumentAtIndex: 1];
        
        if (secondParam != nil) {
            storyboardName = className;
            className = secondParam != nil ? secondParam : @"";
        }
        
        if ([self isValidURI: uri]) {
            // Open app with valid uri name
            [self openAPP:uri withCommand: command];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else if (viewControllerName != nil || storyboardName != nil) {
            // Init viewController from Storyboard with initial view Controlleror or user defined viewControllerName
            [self instantiateViewController:viewControllerName fromStoryboard:storyboardName];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
    } @catch (NSException *e) {
        NSLog(@"[%@]: %@", e.name, e.reason);
        
        typedef CDVCommandStatus (^CaseBlock)(void);
        
        CaseBlock c = self.resultExceptions[e.name];
        
        CDVCommandStatus exceptionType = c ? c() : CDVCommandStatus_ERROR;
        NSDictionary* error = @{
            @"success": @NO,
            @"name": e.name,
            @"message": e.reason
        };
        
        pluginResult = [CDVPluginResult resultWithStatus:exceptionType messageAsDictionary:error];
    }
    
    if ([self.viewController navigationController] != nil) {
        
        if ([self.viewController.navigationController.viewControllers count] > 1) {
            [self.viewController.navigationController popViewControllerAnimated: YES];
        }else{
            
            viewController = [self instantiateViewControllerWithName: className];
            
            [self.viewController.navigationController pushViewController:viewController animated:YES];
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    }else if (className.length > 0 ){
        
        if ([[NSBundle mainBundle] pathForResource:storyboardName ofType: @"storyboardc"] != nil
            && storyboardName.length > 0) {
                
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
            
            viewController = [storyboard instantiateViewControllerWithIdentifier:className];
            
            }else{
                
                viewController = [self tryInstantiateViewWithName: className];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"[%@]: %@", e.name, e.reason);
        
        CDVAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = viewController;
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }else{
        @try {
            [self raiseClassNameError];
        } @catch(InstantiateViewControllerError* e) {
            NSLog(@"%@", e.reason);
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId ];
}

- (UIViewController*) instantiateViewControllerWithName: (NSString*) name {
    
    if ([[NSBundle mainBundle] pathForResource:name ofType: @"nib"]) {
        return [[UIViewController  alloc] initWithNibName: name bundle: nil];
    }else{
        
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString *storyboardName = [mainBundle objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
        
        if (storyboardName != nil) {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            return [storyboard instantiateViewControllerWithIdentifier:name];
        }
    }
    
    NSString* message = [[NSString alloc] initWithFormat:@"The ViewController: %@ was not found", name];
    @throw [[InstantiateViewControllerError alloc] initWithName: @"notFound" reason: message userInfo: nil];
}

- (UIViewController*) tryInstantiateViewWithName:(NSString *)name {
    
    @try {
        return [self instantiateViewControllerWithName: name];
    } @catch (InstantiateViewControllerError* e) {
        NSLog(@"%@", e.reason);
    }
    
    return nil;
}

- (void) raiseClassNameError {
    
    NSString* message = [[NSString alloc] initWithFormat:@"The UIViewController name is required when the project don't have a navigatioController. Please, pass a className by param in JS, like this: 'NativeView.show('MyUIViewController')"];
    @throw [[InstantiateViewControllerError alloc] initWithName: @"nameNotDefined" reason: message userInfo: nil];
}

@end
