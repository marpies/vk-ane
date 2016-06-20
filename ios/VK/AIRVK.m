/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "VKSdk.h"
#import "AIRVK.h"
#import "AIRVKSdkDelegate.h"
#import "Functions/InitFunction.h"
#import "Functions/AuthFunction.h"
#import "Functions/ApplicationOpenURLFunction.h"
#import "Functions/IsLoggedInFunction.h"
#import "Functions/LogoutFunction.h"
#import "Functions/RequestFunction.h"
#import "Functions/ShareFunction.h"
#import "Functions/GetSDKVersion.h"

static BOOL airVKLogEnabled = NO;
FREContext airVKExtContext = nil;
static NSString* airVKAuthPermissionsKey = @"vkAuthPermissions";

@implementation AIRVK

+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void) dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( airVKExtContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void) log:(const NSString*) message {
    if( airVKLogEnabled ) {
        NSLog( @"[iOS-VK] %@", message );
    }
}

+ (void) showLogs:(BOOL) showLogs {
    airVKLogEnabled = showLogs;
}

+ (void) storeAuthPermissions:(NSArray*) permissions {
    /* Store last used auth permissions */
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:permissions forKey:airVKAuthPermissionsKey];
    [defaults synchronize];
}

+ (NSArray*) getAuthPermissions {
    /* Retrieve last used auth permissions */
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:airVKAuthPermissionsKey];
}

@end

/**
 *
 *
 * Context initialization
 *
 *
 **/

FRENamedFunction vk_extFunctions[] = {
    { (const uint8_t*) "init",               0, vk_init },
    { (const uint8_t*) "auth",               0, vk_auth },
    { (const uint8_t*) "applicationOpenURL", 0, vk_applicationOpenURL },
    { (const uint8_t*) "logout",             0, vk_logout },
    { (const uint8_t*) "request",            0, vk_request },
    { (const uint8_t*) "share",              0, vk_share },
    { (const uint8_t*) "isLoggedIn",         0, vk_isLoggedIn },
    { (const uint8_t*) "sdkVersion",         0, vk_sdkVersion }
};

void VKContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet ) {
    *numFunctionsToSet = sizeof( vk_extFunctions ) / sizeof( FRENamedFunction );
    
    *functionsToSet = vk_extFunctions;
    
    airVKExtContext = ctx;
}

void VKContextFinalizer( FREContext ctx ) {
    VKSdk* vk = [VKSdk instance];
    if( vk != nil ) {
        [vk unregisterDelegate:[AIRVKSdkDelegate sharedInstance]];
        [vk setUiDelegate:nil];
    }
}

void VKInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &VKContextInitializer;
    *ctxFinalizerToSet = &VKContextFinalizer;
}

void VKFinalizer( void* extData ) { }