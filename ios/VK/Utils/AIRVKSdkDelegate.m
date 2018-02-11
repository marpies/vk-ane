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

#import "AIRVKSdkDelegate.h"
#import "AIRVK.h"
#import "AIRVKEvent.h"
#import <AIRExtHelpers/MPStringUtils.h>
#import "VKAccessTokenUtils.h"
#import "VKUserUtils.h"

static AIRVKSdkDelegate* vkDelegateSharedInstance = nil;

@implementation AIRVKSdkDelegate

+ (id) sharedInstance {
    if( vkDelegateSharedInstance == nil ) {
        vkDelegateSharedInstance = [[AIRVKSdkDelegate alloc] init];
    }
    return vkDelegateSharedInstance;
}

- (id) init {
    self = [super init];
    
    if( self != nil ) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id delegate = [[UIApplication sharedApplication] delegate];
            if( delegate == nil ) {
                return;
            }
            
            Class adobeDelegateClass = object_getClass( delegate );
            
            // Open URL iOS 9+
            if( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4 ) {
                SEL delegateSelector = @selector(application:openURL:options:);
                [self overrideDelegate:adobeDelegateClass method:delegateSelector withMethod:@selector(vkair_application:openURL:options:)];
            }
            // Open URL iOS 8 and older
            else {
                SEL delegateSelector = @selector(application:openURL:sourceApplication:annotation:);
                [self overrideDelegate:adobeDelegateClass method:delegateSelector withMethod:@selector(vkair_application:openURL:sourceApplication:annotation:)];
            }
        });
    }
    
    return self;
}

# pragma mark - Swizzled

- (BOOL) vkair_application:(UIApplication *) application openURL:(NSURL *) url options:(NSDictionary<NSString*,id> *) options {
    if( [self respondsToSelector:@selector(vkair_application:openURL:options:)] ) {
        [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
        return [self vkair_application:application openURL:url options:options];
    }
    return NO;
}

- (BOOL) vkair_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if( [self respondsToSelector:@selector(vkair_application:openURL:sourceApplication:annotation:)] ) {
        [VKSdk processOpenURL:url fromApplication:sourceApplication];
        return [self vkair_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return NO;
}

# pragma mark - Private

- (BOOL) overrideDelegate:(Class) delegateClass method:(SEL) delegateSelector withMethod:(SEL) swizzledSelector {
    Method originalMethod = class_getInstanceMethod(delegateClass, delegateSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(delegateClass,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
    
    if( didAddMethod ) {
        class_replaceMethod(delegateClass,
                            delegateSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return didAddMethod;
}

/**
 *
 * VKSdkDelegate
 *
 **/

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    [AIRVK log:[NSString stringWithFormat:@"AIRVKSdkDelegate::vkSdkAccessAuthorizationFinishedWithResult authState: %lu", (unsigned long)result.state]];
    if( result.error == nil ) {
        /* VKUser is not part of this result, it's available in 'vkSdkAuthorizationStateUpdatedWithResult' */
        NSString* tokenJSON = [MPStringUtils getJSONString:[VKAccessTokenUtils toJSON:result.token]];
        [AIRVK dispatchEvent:VK_AUTH_SUCCESS withMessage:tokenJSON];
    } else {
        // Even when cancelled
        [AIRVK dispatchEvent:VK_AUTH_ERROR withMessage:result.error.localizedDescription];
    }
}


- (void)vkSdkUserAuthorizationFailed {
    [AIRVK log:@"AIRVKSdkDelegate::vkSdkUserAuthorizationFailed"];
}


- (void)vkSdkAuthorizationStateUpdatedWithResult:(VKAuthorizationResult *)result {
    [AIRVK log:[NSString stringWithFormat:@"AIRVKSdkDelegate::vkSdkAuthorizationStateUpdatedWithResult result has user: %@", result.user]];
}


- (void)vkSdkAccessTokenUpdated:(VKAccessToken *)newToken oldToken:(VKAccessToken *)oldToken {
    [AIRVK log:@"AIRVKSdkDelegate::vkSdkAccessTokenUpdated"];
    NSString* tokenJSON = [MPStringUtils getJSONString:[VKAccessTokenUtils toJSON:newToken]];
    [AIRVK dispatchEvent:VK_TOKEN_UPDATE withMessage:tokenJSON];
}


- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [AIRVK log:@"AIRVKSdkDelegate::vkSdkTokenHasExpired"];
}

/**
 *
 * VKSdkUIDelegate
 *
 **/


- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [AIRVK log:@"AIRVKSdkDelegate::vkSdkShouldPresentViewController"];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController]presentViewController:controller animated:YES completion:nil];
}


- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    [AIRVK log:@"AIRVKSdkDelegate::vkSdkNeedCaptchaEnter"];
}


- (void)vkSdkWillDismissViewController:(UIViewController *)controller {
    [AIRVK log:@"AIRVKSdkDelegate::vkSdkWillDismissViewController"];
}


- (void)vkSdkDidDismissViewController:(UIViewController *)controller {
    [AIRVK log:@"AIRVKSdkDelegate::vkSdkDidDismissViewController"];
}

@end
