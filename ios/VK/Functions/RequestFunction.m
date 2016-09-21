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

#import "RequestFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPStringUtils.h>
#import "AIRVK.h"
#import "VKSdk.h"
#import "AIRVKEvent.h"

NSString* parseRequestParameters( FREObject params, NSMutableDictionary* vkParameters );

FREObject vk_request( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [AIRVK log:@"vk_request"];
    
    int requestId = [MPFREObjectUtils getInt:argv[2]];
    
    NSMutableDictionary* vkParameters = [NSMutableDictionary dictionary];
    NSString* errorMessage = parseRequestParameters( argv[1], vkParameters );
    /* Send request if there's no error parsing the parameters */
    if( errorMessage == nil ) {
        NSString* method = [MPFREObjectUtils getNSString:argv[0]];
        VKRequest* request = [VKRequest requestWithMethod:method parameters:vkParameters];
        [request executeWithResultBlock:^(VKResponse *response) {
            /* Can be an array OR dictionary */
            id originalResponse = response.json;
            NSMutableDictionary* responseJSON = [NSMutableDictionary dictionary];
            responseJSON[@"response"] = originalResponse;
            /* The response is a dictionary, check for 'response' key */
            if( [originalResponse isKindOfClass:[NSDictionary class]] ) {
                if( originalResponse[@"response"] != nil ) {
                    responseJSON[@"response"] = originalResponse[@"response"];
                }
            }
            /* Put the requestId to the response, read as listenerID in AS3 */
            responseJSON[@"listenerID"] = [NSNumber numberWithInt:requestId];
            [AIRVK log:[NSString stringWithFormat:@"VKRequest::onSuccess %@", responseJSON]];
            [AIRVK dispatchEvent:VK_REQUEST_SUCCESS withMessage:[MPStringUtils getJSONString:responseJSON]];
        } errorBlock:^(NSError *error) {
            [AIRVK log:[NSString stringWithFormat:@"VKRequest::onError %@", error.localizedDescription]];
            [AIRVK dispatchEvent:VK_REQUEST_ERROR withMessage:[MPStringUtils getEventErrorJSONString:requestId errorMessage:error.localizedDescription]];
        }];
    }
    /* Or dispatch error */
    else {
        [AIRVK log:[NSString stringWithFormat:@"Error parsing request parameters %@", errorMessage]];
        [AIRVK dispatchEvent:VK_REQUEST_ERROR withMessage:[MPStringUtils getEventErrorJSONString:requestId errorMessage:errorMessage]];
    }
    
    return nil;
}

NSString* parseRequestParameters( FREObject params, NSMutableDictionary* vkParameters ) {
    if( params != nil ) {
        uint32_t length;
        FREGetArrayLength( params, &length );
        NSString* key = nil;
        for( uint32_t i = 0; i < length; i++ ) {
            FREObject param;
            FREGetArrayElementAt( params, i, &param );
            /* Get key */
            if( i % 2 == 0 ) {
                key = [MPFREObjectUtils getNSString:param];
            }
            /* Get value */
            else {
                BOOL unsupportedType = NO;
                NSObject* value = nil;
                /* Get value type */
                FREObjectType type;
                FREGetObjectType( param, &type );
                switch( type ) {
                    case FRE_TYPE_NUMBER:
                        value = [NSNumber numberWithDouble:[MPFREObjectUtils getDouble:param]];
                        break;
                    case FRE_TYPE_STRING:
                        value = [MPFREObjectUtils getNSString:param];
                        break;
                    case FRE_TYPE_ARRAY:
                        value = [MPFREObjectUtils getNSArray:param];
                        break;
                    default:
                        unsupportedType = YES;
                        break;
                }
                /* Parameter value is of unsupported type */
                if( unsupportedType ) {
                    /* Return error message */
                    return [NSString stringWithFormat:@"Parameter value for key %@ cannot be evaluated", key];
                } else {
                    vkParameters[key] = value;
                }
            }
        }
    }
    /* No error */
    return nil;
}