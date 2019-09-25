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
    
    CDVPluginResult *pluginResult;
    
    @try {
        
        NSString *viewControllerName;
        NSString *storyboardName;
        NSString *uri;
        NSString *message;
        NSString *firstParam;
        
        NSMutableDictionary* config = [command.arguments objectAtIndex:0];
        
        if ([config isKindOfClass:[NSMutableDictionary class]]) {
            
            viewControllerName = [config objectForKey:@"viewControllerName"];
            storyboardName = [config objectForKey:@"storyboardName"];
            uri = [config objectForKey:@"uri"];
            
        } else if ([config isKindOfClass:[NSString class]]) {
            
            if ([command.arguments count] == 1) {
                
                firstParam = [command argumentAtIndex: 0];
                
                if ([self isValidURI: firstParam]) {
                    // Open app with valid uri name
                    [self openAPP:firstParam withCommand: command];
                    
                } else if ([firstParam containsString:@"Storyboard"]) {
                    // Init viewController from Storyboard with initial view Controller or user defined viewControllerName
                    [self instantiateViewController:nil fromStoryboard:firstParam];
                    
                } else if ([firstParam containsString:@"Controller"]) {
                    // Init viewController with or without xib
                    [self instantiateViewController:firstParam];
                    
                } else {
                    message = [[NSString alloc] initWithFormat:@"%@ invalid. Must contain a Storyboard / Controller / URI valid in name", firstParam];
                    @throw [[NSException alloc] initWithName:@"IoException" reason:message userInfo:nil];
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                return;
                
            }else if ([command.arguments count] == 2) {
                
                // first param is Storyboard
                storyboardName = [command argumentAtIndex: 0];
                
                // second param is ViewController and/or storyboardId
                viewControllerName = [command argumentAtIndex: 1];
                
            }else{
                message = [[NSString alloc] initWithFormat:@"An UIViewController name or Storyboard name or URI valid name is required at least. Please, pass in the first param in JS, like this: 'NativeView.show('MyViewController') or NativeView.show('MyStoryboard') or NativeView.show('MyStoryboard', 'MyViewController') or NativeView.show('instagram://')"];
                @throw [[NSException alloc] initWithName:@"NotFoundException" reason:message userInfo:nil];
            }

        }else{
            @throw [[NSException alloc] initWithName:@"ParamsTypeException" reason:@"The params of show() method needs be a string or a json" userInfo:nil];
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
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showMarket:(CDVInvokedUrlCommand*)command {
    
    NSMutableDictionary* config = [command.arguments objectAtIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CDVPluginResult *pluginResult;
        NSString *appId;
        
        if ([config isKindOfClass:[NSMutableDictionary class]]) {
            appId = [config objectForKey:@"marketId"];
        }else if([config isKindOfClass:[NSString class]]) {
            appId = (NSString *) config;
        }
        
        if (appId && [appId isKindOfClass:[NSString class]] && [appId length] > 0) {
            NSString *url = [NSString stringWithFormat:@"itms://itunes.apple.com/app/%@", appId];
            
            [self openAPP:url withCommand: command];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            NSDictionary* error = @{
                @"success": @NO,
                @"name": @"ParamInvalidException",
                @"message": @"Invalid application id: the parameter 'marketId' is invalid"
            };
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsDictionary:error];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    });
}

- (void)checkIfAppInstalled:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult;
    NSString *uri;
    
    @try {
        NSMutableDictionary* config = [command.arguments objectAtIndex:0];
        
        if ([config isKindOfClass:[NSMutableDictionary class]]) {
            uri = [config objectForKey:@"uri"];
            
            if (uri == nil) {
                @throw [[NSException alloc] initWithName:@"ParamsTypeException" reason:@"The 'uri' key is required" userInfo:nil];
            }
        }else if ([config isKindOfClass:[NSString class]]) {
            uri = (NSString *) config;
        }else{
            @throw [[NSException alloc] initWithName:@"ParamsTypeException" reason:@"The params of checkIfAppInstalled() method needs be a string or a json" userInfo:nil];
        }
        
        if (![self isValidURI: uri]) {
            NSString *message = [[NSString alloc] initWithFormat:@"uri param invalid: %@", uri];
            NSDictionary* error = @{
                @"success": @NO,
                @"name": @"ParamInvalidException",
                @"message": message
            };
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error];
        } else {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:uri]]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:(true)];
            }
            else {
                NSString *message = [[NSString alloc] initWithFormat:@"The app that responds to URI: %@ was not found", uri];
                NSDictionary* error = @{
                    @"success": @NO,
                    @"name": @"NotFoundException",
                    @"message": message
                };
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION messageAsDictionary:error];
            }
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
    } @finally {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId ];
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
                @throw [[NSException alloc] initWithName:@"NotFoundException" reason:message userInfo:nil];
            }
        }
        
        // Call destinyViewController from current viewController
        if (self.viewController.navigationController) {
            [self.viewController.navigationController pushViewController:destinyViewController animated:YES];
        } else {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:destinyViewController];
            self.viewController.view.window.rootViewController = nav;
        }
        
    } else {
        message = [[NSString alloc] initWithFormat:@"UIViewController with name %@ was not found", viewControllerName];
        @throw [[NSException alloc] initWithName:@"ParamInvalidException" reason:message userInfo:nil];
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
                @throw [[NSException alloc] initWithName:@"NotFoundException" reason:detailMessage userInfo:nil];
            }
        }
        
        // Call destinyViewController from current viewController
        if (self.viewController.navigationController) {
            [self.viewController.navigationController pushViewController:destinyViewController animated:YES];
        } else {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:destinyViewController];
            self.viewController.view.window.rootViewController = nav;
        }
        
    } else {
        message = [[NSString alloc] initWithFormat:@"Storyboard %@ was not found", storyboardName];
        @throw [[NSException alloc] initWithName:@"ParamInvalidException" reason:message userInfo:nil];
    }
}

- (bool) isValidURI:(NSString *)uri {
    if (uri != nil && [uri containsString:@"://"]) { // TODO: Replace for regular expression
        return true;
    }
    return false;
}

- (void) openAPP:(NSString *)uriValue withCommand:(CDVInvokedUrlCommand*) command {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) { // ios >= 10
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uriValue] options:@{} completionHandler:^(BOOL opened) {
            
            CDVPluginResult *pluginResult;
            
            if (!opened) {
                NSString* message = @"APP with uri %@ not found.";
                NSLog(message, uriValue);
                
                NSDictionary* error = @{
                    @"success": @NO,
                    @"name": @"InstantiationException",
                    @"message": [[NSString alloc] initWithFormat:message, uriValue]
                };
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_INSTANTIATION_EXCEPTION messageAsDictionary:error];
            } else {
                NSString* message = @"APP with uri %@ opened.";
                NSLog(message, uriValue);
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSString alloc] initWithFormat:message, uriValue]];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
        }];
    } else { // ios < 10 (Will be depreciated)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uriValue]];
    }
}

@end
