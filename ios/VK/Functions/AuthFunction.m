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

#import "AuthFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "VKSdk.h"
#import "AIRVK.h"

FREObject vk_auth( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    NSArray* permissions = [MPFREObjectUtils getNSArray:argv[0]];
    [AIRVK log:[NSString stringWithFormat:@"vk_auth with permissions %@", permissions]];
    [VKSdk authorize:permissions];
    return nil;
}