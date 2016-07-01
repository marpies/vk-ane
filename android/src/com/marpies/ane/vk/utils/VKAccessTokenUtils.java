/*
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

package com.marpies.ane.vk.utils;

import com.vk.sdk.VKAccessToken;
import com.vk.sdk.VKScope;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class VKAccessTokenUtils {

	public static String toJSON( VKAccessToken token ) {
		if( token.userId == null ) return null;

		JSONObject json = new JSONObject();
		addValueForKey( token.userId, "userId", json );
		addValueForKey( token.accessToken, "accessToken", json );
		addValueForKey( token.secret, "secret", json );
		addValueForKey( token.email, "email", json );
		addValueForKey( token.expiresIn, "expiresIn", json );
		addValueForKey( token.created, "created", json );
		addValueForKey( token.httpsRequired, "httpsRequired", json );
		/* Loop through all permissions and see which one are part of this token */
		List<String> allPermissions = VKScope.parseVkPermissionsFromInteger( Integer.MAX_VALUE );	// Get all permissions
		JSONArray activePermissions = new JSONArray();
		/* VKAcessToken's scope may be null, however, it's not
		 * accessible directly so we have to wrap it in try-catch block */
		try {
			for( String permission : allPermissions ) {
				if( token.hasScope( permission ) ) {
					activePermissions.put( permission );
				}
			}
		} catch( Exception e ) {
			// VKAccessToken's 'scope' is null, thus no permissions
		}
		addValueForKey( activePermissions.toString(), "permissions", json );
		return json.toString();
	}

	private static void addValueForKey( Object value, String key, JSONObject json ) {
		if( value != null ) {
			try {
				json.put( key, value );
			} catch( JSONException e ) {
				e.printStackTrace();
				AIR.log( "Error adding JSON value " + value + " for key " + key );
			}
		}
	}

}
