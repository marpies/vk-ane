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

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.vk.data.AIRVKEvent;
import com.marpies.ane.vk.utils.AIR;
import com.marpies.ane.vk.utils.FREObjectUtils;
import com.marpies.ane.vk.utils.StringUtils;
import com.vk.sdk.api.VKError;
import com.vk.sdk.api.VKParameters;
import com.vk.sdk.api.VKRequest;
import com.vk.sdk.api.VKResponse;
import org.json.JSONException;

public class RequestFunction extends BaseFunction {

	private enum FREObjectType {
		INT,
		DOUBLE,
		STRING,
		ARRAY,
		UNKNOWN
	}

	private int mRequestId = -1;

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		FREArray params = (args[1] != null) ? (FREArray) args[1] : null;
		VKParameters vkParameters = new VKParameters();
		String errorMessage = parseRequestParameters( params, vkParameters );

		mRequestId = FREObjectUtils.getInt( args[2] );
		/* Send request if there's no error parsing the parameters */
		if( errorMessage == null ) {
			String method = FREObjectUtils.getString( args[0] );
			/* Execute the request */
			AIR.log( "Sending VKRequest " + method );
			VKRequest request = new VKRequest( method );
			request.addExtraParameters( vkParameters );
			request.executeWithListener( getRequestListener() );
		}
		/* Or dispatch error */
		else {
			AIR.log( "Error parsing request parameters: " + errorMessage );
			AIR.dispatchEvent( AIRVKEvent.VK_REQUEST_ERROR, StringUtils.getEventErrorJSON( mRequestId, errorMessage ) );
		}

		return null;
	}

	private String parseRequestParameters( FREArray params, VKParameters vkParameters ) {
		if( params != null ) {
			try {
				long length = params.getLength();
				String key = null;
				for( long i = 0; i < length; i++ ) {
					FREObject param = params.getObjectAt( i );
					/* Get key */
					if( i % 2 == 0 ) {
						key = FREObjectUtils.getString( param );
					}
					/* Get value */
					else {
						Object value = null;
						FREObjectType type = getFREObjectType( param );
						switch( type ) {
							case INT:
								value = FREObjectUtils.getInt( param );
								AIR.log( "FREObjectType: INT = " + FREObjectUtils.getInt( param ) );
								break;
							case DOUBLE:
								value = FREObjectUtils.getDouble( param );
								AIR.log( "FREObjectType: DOUBLE = " + FREObjectUtils.getDouble( param ) );
								break;
							case STRING:
								value = FREObjectUtils.getString( param );
								AIR.log( "FREObjectType: STRING = " + FREObjectUtils.getString( param ) );
								break;
							case ARRAY:
								value = FREObjectUtils.getListOfString( (FREArray) param );
								AIR.log( "FREObjectType: ARRAY = " + FREObjectUtils.getListOfString( (FREArray) param ) );
								break;
							case UNKNOWN:
								throw new Exception( "Parameter value for key " + key + " cannot be evaluated." );
						}
						if( value != null ) {
							vkParameters.put( key, value );
						}
					}
				}
			} catch( Exception e ) {
				e.printStackTrace();
				return e.getLocalizedMessage();
			}
		}
		/* No error message */
		return null;
	}

	private FREObjectType getFREObjectType( FREObject object ) {
		/* Try int */
		try {
			object.getAsInt();
			return FREObjectType.INT;
		} catch( Exception e ) {}
		/* Try double */
		try {
			object.getAsDouble();
			return FREObjectType.DOUBLE;
		} catch( Exception e ) {}
		/* Try string */
		try {
			object.getAsString();
			return FREObjectType.STRING;
		} catch( Exception e ) {}
		/* Try array */
		try {
			FREArray a = (FREArray) object;
			if( a != null ) return FREObjectType.ARRAY;
		} catch( Exception e ) {}
		return FREObjectType.UNKNOWN;
	}

	private VKRequest.VKRequestListener getRequestListener() {
		return new VKRequest.VKRequestListener() {
			@Override
			public void onComplete( VKResponse response ) {
				AIR.log( "VKRequest::onComplete JSON: " + response.json );
				try {
					/* Put the requestId to the response, read as listenerID in AS3 */
					response.json.put( "listenerID", mRequestId );
					AIR.dispatchEvent( AIRVKEvent.VK_REQUEST_SUCCESS, response.json.toString() );
				} catch( JSONException e ) {
					e.printStackTrace();
					AIR.dispatchEvent( AIRVKEvent.VK_REQUEST_ERROR, StringUtils.getEventErrorJSON( mRequestId, "Request succeeded but could not retrieve response." ) );
				}
			}

			@Override
			public void attemptFailed( VKRequest request, int attemptNumber, int totalAttempts ) {
				AIR.log( "VKRequest::attemptFailed n: " + attemptNumber + " total: " + totalAttempts  );
				if( attemptNumber < totalAttempts ) {
					request.executeWithListener( getRequestListener() );
				} else {
					AIR.dispatchEvent( AIRVKEvent.VK_REQUEST_ERROR, StringUtils.getEventErrorJSON( mRequestId, "Request timed out." ) );
				}
			}

			@Override
			public void onError( VKError error ) {
				// captcha error, validation error
				AIR.log( "VKRequest::onError: " + error.errorMessage + " reason: " + error.errorReason + " code: " + error.errorCode );
				String errorMessage = ((error.errorMessage != null) ? error.errorMessage : "Empty error message") + " | Error code: " + error.errorCode;
				AIR.dispatchEvent( AIRVKEvent.VK_REQUEST_ERROR, StringUtils.getEventErrorJSON( mRequestId, errorMessage ) );
			}
		};
	}

}

