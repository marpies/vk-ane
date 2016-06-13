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

import android.graphics.Bitmap;
import com.adobe.fre.FREArray;
import com.adobe.fre.FREBitmapData;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.marpies.ane.vk.data.AIRVKEvent;
import com.marpies.ane.vk.utils.AIR;
import com.marpies.ane.vk.utils.BitmapDataUtils;
import com.marpies.ane.vk.utils.FREObjectUtils;
import com.vk.sdk.api.VKError;
import com.vk.sdk.api.model.VKApiPhoto;
import com.vk.sdk.api.model.VKPhotoArray;
import com.vk.sdk.api.photo.VKImageParameters;
import com.vk.sdk.api.photo.VKUploadImage;
import com.vk.sdk.dialogs.VKShareDialogBuilder;

import java.util.List;

public class ShareFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		String text = (args[0] == null) ? null : FREObjectUtils.getString( args[0] );
		String attachmentLinkTitle = (args[1] == null) ? null : FREObjectUtils.getString( args[1] );
		String attachmentLinkURL = (args[2] == null) ? null : FREObjectUtils.getString( args[2] );
		List<String> uploadedPhotoIds = (args[3] == null) ? null : FREObjectUtils.getListOfString( (FREArray) args[3] );
		FREArray freAttachmentImages = (args[4] == null) ? null : (FREArray) args[4];

		/* Parse BitmapData */
		VKUploadImage[] attachmentImages = getAttachmentImages( freAttachmentImages );
		/* Create photo array from uploaded photo IDs */
		VKPhotoArray uploadedPhotos = null;
		if( uploadedPhotoIds != null ) {
			uploadedPhotos = new VKPhotoArray();
			for( String photoId : uploadedPhotoIds ) {
				uploadedPhotos.add( new VKApiPhoto( photoId ) );
			}
		}

		AIR.log( "VK.ShareFunction" );

		new VKShareDialogBuilder()
				.setText( text )
				.setAttachmentLink( attachmentLinkTitle, attachmentLinkURL )
				.setUploadedPhotos( uploadedPhotos )
				.setAttachmentImages( attachmentImages )
				.setShareDialogListener( getShareListener() )
				.show( AIR.getContext().getActivity().getFragmentManager(), "VKSdk.share" );

		return null;
	}

	private VKUploadImage[] getAttachmentImages( FREArray attachmentImages ) {
		if( attachmentImages == null ) return null;

		try {
			long length = attachmentImages.getLength();
			VKUploadImage[] result = new VKUploadImage[(int)length];
			for( int i = 0; i < length; i++ ) {
				FREBitmapData bmpData = (FREBitmapData) attachmentImages.getObjectAt( i );
				Bitmap bitmap = BitmapDataUtils.getBitmap( bmpData );
				result[i] = new VKUploadImage( bitmap, VKImageParameters.pngImage() );
			}
			return result;
		} catch( Exception e ) {
			e.printStackTrace();
			AIR.log( "Error parsing attachment images: " + e.getLocalizedMessage() );
			return null;
		}
	}

	private VKShareDialogBuilder.VKShareDialogListener getShareListener() {
		return new VKShareDialogBuilder.VKShareDialogListener() {
			@Override
			public void onVkShareComplete( int postId ) {
				AIR.log( "VKShareDialogListener::onVkShareComplete postId: " + postId );
				AIR.dispatchEvent( AIRVKEvent.VK_SHARE_COMPLETE, String.valueOf( postId ) );
			}

			@Override
			public void onVkShareCancel() {
				AIR.log( "VKShareDialogListener::onVkShareCancel" );
				AIR.dispatchEvent( AIRVKEvent.VK_SHARE_CANCEL );
			}

			@Override
			public void onVkShareError( VKError error ) {
				AIR.log( "VKShareDialogListener::onVkShareError error: " + error.errorMessage + " reason: " + error.errorReason + " code: " + error.errorCode );
				String errorMessage = ((error.errorMessage != null) ? error.errorMessage : "Empty error message") + " | Error code: " + error.errorCode;
				AIR.dispatchEvent( AIRVKEvent.VK_SHARE_ERROR, errorMessage );
			}
		};
	}

}

