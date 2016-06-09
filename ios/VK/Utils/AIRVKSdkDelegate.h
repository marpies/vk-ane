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

#import <Foundation/Foundation.h>
#import "VKSdk.h"

@interface AIRVKSdkDelegate : NSObject <VKSdkDelegate, VKSdkUIDelegate>

+ (id) sharedInstance;

/**
 *
 * VKSdkDelegate
 *
 **/

/**
 Notifies about authorization was completed, and returns authorization result with new token or error.
 
 @param result contains new token or error, retrieved after VK authorization.
 */
- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result;

/**
 Notifies about access error. For example, this may occurs when user rejected app permissions through VK.com
 */
- (void)vkSdkUserAuthorizationFailed;

/**
 Notifies about authorization state was changed, and returns authorization result with new token or error.
 
 If authorization was successfull, also contains user info.
 
 @param result contains new token or error, retrieved after VK authorization
 */
- (void)vkSdkAuthorizationStateUpdatedWithResult:(VKAuthorizationResult *)result;

/**
 Notifies about access token has been changed
 
 @param newToken new token for API requests
 @param oldToken previous used token
 */
- (void)vkSdkAccessTokenUpdated:(VKAccessToken *)newToken oldToken:(VKAccessToken *)oldToken;

/**
 Notifies about existing token has expired (by timeout). This may occurs if you requested token without no_https scope.
 
 @param expiredToken old token that has expired.
 */
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken;

/**
 *
 * VKSdkUIDelegate
 *
 **/

/**
 Pass view controller that should be presented to user. Usually, it's an authorization window.
 
 @param controller view controller that must be shown to user
 */
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller;

/**
 Calls when user must perform captcha-check.
 If you implementing this method by yourself, call -[VKError answerCaptcha:] method for captchaError with user entered answer.
 
 @param captchaError error returned from API. You can load captcha image from <b>captchaImg</b> property.
 */
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError;

/**
 * Called when a controller presented by SDK will be dismissed.
 */
- (void)vkSdkWillDismissViewController:(UIViewController *)controller;

/**
 * Called when a controller presented by SDK did dismiss.
 */
- (void)vkSdkDidDismissViewController:(UIViewController *)controller;

@end
