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

#import "ShareFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import <AIRExtHelpers/MPBitmapDataUtils.h>
#import "VKSdk.h"
#import "AIRVK.h"
#import "AIRVKEvent.h"

NSArray* getAttachmentImages( FREObject attachmentImages );
NSArray* removePhotoPrefixFromIds( NSArray* uploadedPhotoIds );

FREObject vk_share( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [AIRVK log:@"vk_share"];
    NSString* text = (argv[0] == nil) ? nil : [MPFREObjectUtils getNSString: argv[0]];
    NSString* attachmentLinkTitle = (argv[1] == nil) ? nil : [MPFREObjectUtils getNSString: argv[1]];
    NSString* attachmentLinkURL = (argv[2] == nil) ? nil : [MPFREObjectUtils getNSString: argv[2]];
    NSArray* uploadedPhotoIds = (argv[3] == nil) ? nil : [MPFREObjectUtils getNSArray: argv[3]];
    FREObject freAttachmentImages = (argv[4] == nil) ? nil : argv[4];
    
    /* Remove 'photo' prefix from uploaded photo IDs (iOS requires it) */
    uploadedPhotoIds = removePhotoPrefixFromIds( uploadedPhotoIds );
    /* Parse BitmapData */
    NSArray* attachmentImages = getAttachmentImages( freAttachmentImages );
    
    /* Create share dialog */
    VKShareDialogController* shareDialog = [VKShareDialogController new];
    shareDialog.text = text;
    shareDialog.vkImages = uploadedPhotoIds;
    if( attachmentLinkTitle != nil && attachmentLinkURL != nil ) {
        shareDialog.shareLink = [[VKShareLink alloc] initWithTitle:attachmentLinkTitle link:[NSURL URLWithString:attachmentLinkURL]];
    }
    shareDialog.uploadImages = attachmentImages;
    [shareDialog setCompletionHandler:^(VKShareDialogController *dialog, VKShareDialogControllerResult result) {
        [AIRVK log:[NSString stringWithFormat:@"ShareDialog::CompletionHandler result %li", (long)result]];
        if( result == VKShareDialogControllerResultCancelled ) {
            [AIRVK dispatchEvent:VK_SHARE_CANCEL];
        } else {
            [AIRVK dispatchEvent:VK_SHARE_COMPLETE withMessage:dialog.postId];
        }
        /* Dismiss the share dialog */
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
    }];
    /* Present the share dialog */
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController]presentViewController:shareDialog animated:YES completion:nil];
    
    return nil;
}

NSArray* getAttachmentImages( FREObject attachmentImages ) {
    if( attachmentImages == nil ) return nil;
    
    NSMutableArray* result = [NSMutableArray array];
    uint32_t length;
    FREGetArrayLength( attachmentImages, &length );
    for( uint32_t i = 0; i < length; i++ ) {
        FREObject bitmapDataObject;
        FREBitmapData2 bitmapData;
        if( (FREGetArrayElementAt( attachmentImages, i, &bitmapDataObject ) != FRE_OK) ||
            (FREAcquireBitmapData2( bitmapDataObject, &bitmapData ) != FRE_OK) ) {
            [AIRVK log:@"Error parsing attachment images"];
            return nil;
        }
        UIImage* image = [MPBitmapDataUtils getUIImageFromFREBitmapData:bitmapData];
        [result addObject:[VKUploadImage uploadImageWithImage:image andParams:[VKImageParameters pngImage]]];
        FREReleaseBitmapData( bitmapDataObject );
    }
    return result;
}

NSArray* removePhotoPrefixFromIds( NSArray* uploadedPhotoIds ) {
    if( uploadedPhotoIds == nil ) return nil;
    
    NSMutableArray* result = [NSMutableArray arrayWithArray:uploadedPhotoIds];
    NSString* prefix = @"photo";
    NSUInteger prefixLength = [prefix length];
    for( NSString* photoId in uploadedPhotoIds ) {
        if( [photoId hasPrefix:prefix] ) {
            [result addObject:[photoId substringFromIndex:prefixLength]];
        }
    }
    return result;
}


