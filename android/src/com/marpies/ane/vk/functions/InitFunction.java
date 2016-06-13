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

package com.marpies.ane.vk.functions;

import android.app.Activity;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.vk.utils.AIR;
import com.marpies.ane.vk.utils.FREObjectUtils;
import com.vk.sdk.VKAccessToken;
import com.vk.sdk.VKCallback;
import com.vk.sdk.VKSdk;
import com.vk.sdk.api.VKError;

public class InitFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		boolean enableLogs = FREObjectUtils.getBoolean( args[1] );
		AIR.setLogEnabled( enableLogs );
		VKSdk.DEBUG = enableLogs;
		int appId = Integer.valueOf( FREObjectUtils.getString( args[0] ) );

		AIR.log( "Initializing VKSdk" );

		Activity activity = AIR.getContext().getActivity();

		AIR.startAccessTokenTracker();
		VKSdk.customInitialize( activity, appId, "" );
		VKSdk.wakeUpSession( activity, new VKCallback<VKSdk.LoginState>() {
			@Override
			public void onResult( VKSdk.LoginState res ) {
				AIR.log( "VKSdk.wakeUpSession::onResult " + res );
				AIR.notifyTokenChange( VKAccessToken.currentToken() );
			}

			@Override
			public void onError( VKError error ) {
				AIR.log( "VKSdk.wakeUpSession::onError " + error.errorReason );
				AIR.notifyTokenChange( VKAccessToken.currentToken() );
			}
		} );

		return null;
	}

}
