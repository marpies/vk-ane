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

package com.marpies.ane.vk.functions;

import android.content.Intent;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.IActivityResultCallback;
import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.vk.data.AIRVKEvent;
import com.marpies.ane.vk.utils.AIR;
import com.marpies.ane.vk.utils.FREObjectUtils;
import com.marpies.ane.vk.utils.VKAccessTokenUtils;
import com.vk.sdk.VKAccessToken;
import com.vk.sdk.VKCallback;
import com.vk.sdk.VKSdk;
import com.vk.sdk.api.VKError;

import java.util.ArrayList;

public class AuthFunction extends BaseFunction implements IActivityResultCallback {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		ArrayList<String> permissions = (args[0] == null) ? null : (ArrayList<String>) FREObjectUtils.getListOfString( (FREArray) args[0] );

		AndroidActivityWrapper.GetAndroidActivityWrapper().addActivityResultListener( this );

		AIR.log( "AuthFunction | VKSdk::login" );

		VKSdk.login( AIR.getContext().getActivity(), (permissions != null) ? permissions.toArray( new String[0] ) : null );

		return null;
	}

	@Override
	public void onActivityResult( int requestCode, int resultCode, Intent data ) {
		if( !VKSdk.onActivityResult( requestCode, resultCode, data, new VKCallback<VKAccessToken>() {
			@Override
			public void onResult( VKAccessToken res ) {
				AIR.log( "AuthFunction::onActivityResult | VK_AUTH_SUCCESS" );
				AIR.dispatchEvent( AIRVKEvent.VK_AUTH_SUCCESS, VKAccessTokenUtils.toJSON( res ) );
			}

			@Override
			public void onError( VKError error ) {
				AIR.log( "AuthFunction::onActivityResult | VK_AUTH_ERROR: " + error.errorMessage + " reason: " + error.errorReason );
				AIR.dispatchEvent( AIRVKEvent.VK_AUTH_ERROR, (error.errorMessage == null) ? "Error - user denied access." : error.errorMessage );
			}
		} ) ) {
			AIR.log( "AuthFunction::onActivityResult | no callback" );
		}
		AndroidActivityWrapper.GetAndroidActivityWrapper().removeActivityResultListener( this );
	}

}

