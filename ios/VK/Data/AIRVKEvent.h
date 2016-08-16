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

#ifndef AIRVKEvent_h
#define AIRVKEvent_h

#import <Foundation/Foundation.h>

static NSString* const VK_AUTH_ERROR = @"vkAuthError";
static NSString* const VK_AUTH_SUCCESS = @"vkAuthSuccess";
static NSString* const VK_TOKEN_UPDATE = @"vkTokenUpdate";
static NSString* const VK_REQUEST_SUCCESS = @"vkRequestSuccess";
static NSString* const VK_REQUEST_ERROR = @"vkRequestError";
static NSString* const VK_SHARE_COMPLETE = @"vkShareComplete";
static NSString* const VK_SHARE_CANCEL = @"vkShareCancel";

#endif /* AIRVKEvent_h */
