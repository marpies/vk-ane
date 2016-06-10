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

package com.marpies.ane.vk;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import com.marpies.ane.vk.data.AIRVKEvent;
import com.marpies.ane.vk.utils.AIR;
import com.marpies.ane.vk.utils.VKAccessTokenUtils;
import com.vk.sdk.VKAccessToken;
import com.vk.sdk.VKCallback;
import com.vk.sdk.VKSdk;
import com.vk.sdk.api.VKError;

import java.util.ArrayList;
import java.util.Arrays;

public class AuthActivity extends Activity {

	public static final String EXTRA_PREFIX = "com.marpies.ane.vk.AuthActivity";

	@Override
	protected void onCreate( Bundle savedInstanceState ) {
		super.onCreate( savedInstanceState );

		Bundle extras = getIntent().getExtras();
		String[] permissions = null;
		if( extras != null ) {
			if( extras.containsKey( EXTRA_PREFIX + ".permissions" ) ) {
				permissions = extras.getStringArrayList( EXTRA_PREFIX + ".permissions" ).toArray( new String[0] );
			}
		}

		AIR.log( "AuthActivity::onCreate | permissions: " + Arrays.toString( permissions ) );

		VKSdk.login( this, permissions );
	}

	@Override
	protected void onActivityResult( int requestCode, int resultCode, Intent data ) {
		if( !VKSdk.onActivityResult( requestCode, resultCode, data, new VKCallback<VKAccessToken>() {
			@Override
			public void onResult( VKAccessToken res ) {
				AIR.log( "AuthActivity::onActivityResult | VK_AUTH_SUCCESS" );
				AIR.dispatchEvent( AIRVKEvent.VK_AUTH_SUCCESS, VKAccessTokenUtils.toJSON( res ) );
			}

			@Override
			public void onError( VKError error ) {
				AIR.log( "AuthActivity::onActivityResult | VK_AUTH_ERROR: " + error.errorMessage + " reason: " + error.errorReason );
				AIR.dispatchEvent( AIRVKEvent.VK_AUTH_ERROR, (error.errorMessage == null) ? "Error - user denied access." : error.errorMessage );
			}
		} ) ) {
			AIR.log( "AuthActivity::onActivityResult | no callback" );
			super.onActivityResult( requestCode, resultCode, data );
		}
		finish();
	}

	@Override
	public void onBackPressed() {
		finish();
	}

}