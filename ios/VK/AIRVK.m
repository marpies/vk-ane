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

void VKAddFunction( FRENamedFunction* array, const char* name, FREFunction function, uint32_t* index ) {
    array[(*index)].name = (const uint8_t*) name;
    array[(*index)].functionData = NULL;
    array[(*index)].function = function;
    (*index)++;
}

void VKContextInitializer( void* extData,
                                  const uint8_t* ctxType,
                                  FREContext ctx,
                                  uint32_t* numFunctionsToSet,
                                  const FRENamedFunction** functionsToSet ) {
    uint32_t numFunctions = 5;
    *numFunctionsToSet = numFunctions;
    
    FRENamedFunction* functionArray = (FRENamedFunction*) malloc( sizeof( FRENamedFunction ) * numFunctions );
    
    uint32_t index = 0;
    VKAddFunction( functionArray, "init", &vk_init, &index );
    VKAddFunction( functionArray, "auth", &vk_auth, &index );
    VKAddFunction( functionArray, "applicationOpenURL", &vk_applicationOpenURL, &index );
    VKAddFunction( functionArray, "logout", &vk_logout, &index );
    VKAddFunction( functionArray, "isLoggedIn", &vk_isLoggedIn, &index );
    
    *functionsToSet = functionArray;
    
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