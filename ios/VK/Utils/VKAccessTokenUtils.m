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

#import "VKAccessTokenUtils.h"

@implementation VKAccessTokenUtils

+ (NSDictionary*) toJSON:(VKAccessToken*) token {
    NSMutableDictionary* json = [NSMutableDictionary dictionary];
    [self addValue:token.accessToken forKey:@"accessToken" toDictionary:json];
    [self addValue:token.userId forKey:@"userId" toDictionary:json];
    [self addValue:token.secret forKey:@"secret" toDictionary:json];
    [self addValue:token.permissions forKey:@"permissions" toDictionary:json];
    [self addValue:token.email forKey:@"email" toDictionary:json];
    json[@"expiresIn"] = [NSNumber numberWithInteger:token.expiresIn];
    json[@"created"] = [NSNumber numberWithInteger:token.created];
    json[@"httpsRequired"] = [NSNumber numberWithBool:token.httpsRequired];
    return json;
}

+ (void) addValue:(NSObject*) value forKey:(NSString*) key toDictionary:(NSMutableDictionary*) dictionary {
    if( value != nil ) {
        dictionary[key] = value;
    }
}

@end
