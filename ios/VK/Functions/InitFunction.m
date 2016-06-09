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

#import "AIRVK.h"
#import "InitFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "VKSdk.h"
#import "AIRVKSdkDelegate.h"

FREObject vk_init( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [AIRVK showLogs:[MPFREObjectUtils getBOOL:argv[1]]];
    [AIRVK log:@"vk_init"];
    
    NSString* appId = [MPFREObjectUtils getNSString:argv[0]];
    VKSdk* vk = [VKSdk initializeWithAppId:appId];
    [vk registerDelegate:[AIRVKSdkDelegate sharedInstance]];
    [vk setUiDelegate:[AIRVKSdkDelegate sharedInstance]];
    
    /* Attempt to wake session with last known auth permissions */
    NSArray* permissions = [AIRVK getAuthPermissions];
    [VKSdk wakeUpSession:permissions completeBlock:^(VKAuthorizationState state, NSError *error) {
        /* No need to auth again */
        if( state == VKAuthorizationAuthorized ) {
            [AIRVK log:@"vk::wakeUpSession VKAuthorizationAuthorized"];
        }
        /* All good, we can proceed to auth */
        else if( state == VKAuthorizationInitialized ) {
            [AIRVK log:@"vk::wakeUpSession VKAuthorizationInitialized"];
        }
        /* Error, try again later */
        else if( state == VKAuthorizationError || error != nil ) {
            [AIRVK log:@"vk::wakeUpSession VKAuthorizationError"];
        }
    }];
    
    return nil;
}