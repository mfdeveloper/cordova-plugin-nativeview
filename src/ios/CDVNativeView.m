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
          @"IO_EXCEPTION": ^{
              return CDVCommandStatus_IO_EXCEPTION;
          },
          @"CLASS_NOT_FOUND_EXCEPTION": ^{
              return CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION;
          },
          @"PARAM_INVALID_EXCEPTION": ^{
              return CDVCommandStatus_ERROR;
          },
          @"INSTANTIATION_EXCEPTION": ^{
              return CDVCommandStatus_INSTANTIATION_EXCEPTION;
          },
          @"NOT_FOUND_EXCEPTION": ^{
              return CDVCommandStatus_NO_RESULT;
          }
       };
   }
    return self;
}
- (void)show:(CDVInvokedUrlCommand*)command {
    
    CDVPluginResult *pluginResult;
    
    @try {
        NSString *viewControllerName;
        NSString *storyboardName;
        NSString *message;
        
        // Handling arguments
        if ([command.arguments count] == 1) {
            
            NSString *firstParam = [command argumentAtIndex: 0];
            
            if ([self isValidURI: firstParam]) {
                // Open app with valid uri name
                [self openAPP:firstParam];
                
            } else if ([firstParam containsString:@"Storyboard"]) {
                // Init viewController from Storyboard with initial view Controlleror or user defined viewControllerName
                [self instantiateViewController:nil fromStoryboard:firstParam];
                
            } else if ([firstParam containsString:@"Controller"]) {
                // Init viewController with or without xib
                [self instantiateViewController:firstParam];
                
            } else {
                message = [[NSString alloc] initWithFormat:@"%@ invalid. Must contain a Storyboard / Controller / URI valid in name", firstParam];
                @throw [[NSException alloc] initWithName:@"IO_EXCEPTION" reason:message userInfo:nil];
            }
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            
        } else if ([command.arguments count] == 2) {
            
            // first param is Storyboard
            storyboardName = [command argumentAtIndex: 0];
            
            // second param is ViewController and/or storyboardId
            viewControllerName = [command argumentAtIndex: 1];
            
            // Init viewController from Storyboard with initial view Controlleror or user defined viewControllerName
            [self instantiateViewController:viewControllerName fromStoryboard:storyboardName];
            
        } else {
            message = [[NSString alloc] initWithFormat:@"An UIViewController name or Storyboard name or URI valid name is required at least. Please, pass in the first param in JS, like this: 'NativeView.show('MyViewController') or NativeView.show('MyStoryboard') or NativeView.show('MyStoryboard', 'MyViewController') or NativeView.show('instagram://')"];
            @throw [[NSException alloc] initWithName:@"CLASS_NOT_FOUND_EXCEPTION" reason:message userInfo:nil];
        }
    } @catch (NSException *e) {
        NSLog(@"%@", e.reason);
        
        typedef CDVCommandStatus (^CaseBlock)(void);
        
        CaseBlock c = self.resultExceptions[e.name];
        
        CDVCommandStatus exceptionType = c ? c() : CDVCommandStatus_ERROR;
        pluginResult = [CDVPluginResult resultWithStatus:exceptionType messageAsString:e.reason];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) instantiateViewController:(NSString *)viewControllerName {
    
    NSString *message;
    
    if (viewControllerName && viewControllerName.length > 0) {
        
        UIViewController *destinyViewController = nil;
        
        // Call preInitializeViewControllerWithName if exists in self.viewController
        SEL selector = NSSelectorFromString(@"preInitializeViewControllerWithName:");
        
        if ([self.viewController respondsToSelector:selector]) {
            
            SuppressPerformSelectorLeakWarning(
               destinyViewController = [self.viewController performSelector:selector withObject:viewControllerName];
            );
        }
        
        // if not performSelector, call automatically the viewController
        if (!destinyViewController) {
            @try {
                if ([[NSBundle mainBundle] pathForResource:viewControllerName ofType:@"nib"]) {
                    // Initialize with nib/xib
                    destinyViewController = [[UIViewController alloc] initWithNibName:viewControllerName bundle:nil];
                } else {
                    // Initialize without nib/xib
                    Class viewController = NSClassFromString(viewControllerName);
                    id anInstance = [[viewController alloc] init];
                    destinyViewController = anInstance;
                }
            } @catch(NSException *e) {
                message = [[NSString alloc] initWithFormat:@"%@ and/or its own xib does not exist. \nDetail: %@", viewControllerName, e.reason];
                @throw [[NSException alloc] initWithName:@"CLASS_NOT_FOUND_EXCEPTION" reason:message userInfo:nil];
            }
        }
        
        // Call destinyViewController from current viewController
        [self.viewController.navigationController pushViewController:destinyViewController animated:YES];
        
    } else {
        message = [[NSString alloc] initWithFormat:@"UIViewController with name %@ was not found", viewControllerName];
        @throw [[NSException alloc] initWithName:@"PARAM_INVALID_EXCEPTION" reason:message userInfo:nil];
    }
}

- (void) instantiateViewController:(NSString *)viewControllerName fromStoryboard:(NSString *)storyboardName {
    
    NSString *message;
    
    if (storyboardName && storyboardName.length > 0) {
        
        UIViewController *destinyViewController = nil;
        
        // Call preInitializeViewControllerWithName:fromStoryBoardName if exists in self.viewController
        SEL selector = NSSelectorFromString(@"preInitializeViewControllerWithName:fromStoryBoardName:");
        
        if ([self.viewController respondsToSelector:selector]) {
            
            SuppressPerformSelectorLeakWarning(
                destinyViewController = [self.viewController performSelector:selector withObject:viewControllerName withObject:storyboardName];
           );
        }
        
        // if not performSelector, call automatically the viewController from storyboard
        if (!destinyViewController) {
            // initialize a storyboard automatically from viewControllerName or default initialViewController property
            @try {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
                
                if (viewControllerName && viewControllerName.length > 0) {
                    message = [[NSString alloc] initWithFormat:@"Identity -> Storyboard ID: %@ not found in storyboard %@", viewControllerName, storyboardName];
                    // if pass a viewControllerName, initializate the storyboard with viewControllerName initial
                    destinyViewController = [storyboard instantiateViewControllerWithIdentifier:viewControllerName];
                } else {
                    message = [[NSString alloc] initWithFormat:@"Storyboard -> ViewController -> 'is Initial View Controller' not check in storyboard %@", storyboardName];
                    // if not pass a viewControllerName, initializate the storyboard with default inicialViewController property
                    destinyViewController = [storyboard instantiateInitialViewController];
                }
            } @catch (NSException *e) {
                NSString *detailMessage = [[NSString alloc] initWithFormat:@"%@ \nDetail: %@", message, e.reason];
                @throw [[NSException alloc] initWithName:@"INSTANTIATION_EXCEPTION" reason:detailMessage userInfo:nil];
            }
        }
        
        // Call destinyViewController from current viewController
        [self.viewController.navigationController pushViewController:destinyViewController animated:YES];
        
    } else {
        message = [[NSString alloc] initWithFormat:@"Storyboard %@ was not found", storyboardName];
        @throw [[NSException alloc] initWithName:@"PARAM_INVALID_EXCEPTION" reason:message userInfo:nil];
    }
}
    
- (void)checkIfAppInstalled:(CDVInvokedUrlCommand*)command {
    
    CDVPluginResult *pluginResult;
    
    NSString *uri = [command.arguments objectAtIndex:0];
    
    if (![self isValidURI: uri]) {
        NSString *message = [[NSString alloc] initWithFormat:@"uri param invalid: %@", uri];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:uri]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:(true)];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:(false)];
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (bool) isValidURI:(NSString *)uri {
    if (uri != nil && [uri containsString:@"://"]) { // TODO: Replace for regular expression
        return true;
    }
    return false;
}

- (void) openAPP:(NSString *)uriValue {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) { // ios >= 10
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uriValue] options:@{} completionHandler:^(BOOL opened) {
            if (!opened) {
                NSLog(@"APP with uri %@ not found.", uriValue);
            } else {
                NSLog(@"APP with uri %@ opened", uriValue);
            }
        }];
    } else { // ios < 10 (Will be depreciated)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uriValue]];
    }
}

@end
