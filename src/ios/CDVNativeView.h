//
//  CDVNativeView.h
//
//  Created by Michel Felipe on 05/09/17.
//
//

// Reference: https://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
#define SuppressPerformSelectorLeakWarning(Stuff) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        Stuff; \
        _Pragma("clang diagnostic pop") \
    } while (0)

#import <Cordova/CDV.h>

@interface CDVNativeView : CDVPlugin

@property (strong, nonatomic) NSDictionary *resultExceptions;

- (void)show:(CDVInvokedUrlCommand*)command;
- (void)checkIfAppInstalled:(CDVInvokedUrlCommand*)command;
- (void)showMarket:(CDVInvokedUrlCommand*)command;

@end
