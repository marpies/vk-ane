package com.marpies.ane.vk {

    import flash.display.BitmapData;

    /**
     * VO representing VK share parameters. For internal use only.
     */
    public class VKShareParameters {

        private var mAttachmentImages:Vector.<BitmapData>;
        private var mAttachmentLinkURL:String;
        private var mAttachmentLinkTitle:String;
        private var mText:String;
        private var mUploadedPhotos:Vector.<String>;
        private var mCompleteCallback:Function;
        private var mCancelCallback:Function;
        private var mErrorCallback:Function;

        public function VKShareParameters() {
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * List of images to attach to the shared post.
         */
        public function get attachmentImages():Vector.<BitmapData> {
            return mAttachmentImages;
        }

        /**
         * @private
         */
        public function set attachmentImages( value:Vector.<BitmapData> ):void {
            mAttachmentImages = value;
        }

        /**
         * URL of the link to attach to the shared post.
         */
        public function get attachmentLinkURL():String {
            return mAttachmentLinkURL;
        }

        /**
         * @private
         */
        public function set attachmentLinkURL( value:String ):void {
            mAttachmentLinkURL = value;
        }

        /**
         * Title of the link to attach to the shared post.
         */
        public function get attachmentLinkTitle():String {
            return mAttachmentLinkTitle;
        }

        /**
         * @private
         */
        public function set attachmentLinkTitle( value:String ):void {
            mAttachmentLinkTitle = value;
        }

        /**
         * Text of the shared post.
         */
        public function get text():String {
            return mText;
        }

        /**
         * @private
         */
        public function set text( value:String ):void {
            mText = value;
        }

        /**
         * List of photo IDs which are already uploaded on VK network.
         * Each ID should have the format <code>photo{owner_id}_{photo_id}</code>.
         * You must be granted <code>VKPermissions.PHOTOS</code> permission to successfully
         * use this feature.
         */
        public function get uploadedPhotos():Vector.<String> {
            return mUploadedPhotos;
        }

        /**
         * @private
         */
        public function set uploadedPhotos( value:Vector.<String> ):void {
            mUploadedPhotos = value;
        }

        /**
         * Function that is called when the sharing is successfully completed.
         *
         * The callback is expected to have this signature:
         * <listing version="3.0">
         * function onShareCompleteCallback( postId:int ):void {
         * }
         * </listing>
         */
        public function get completeCallback():Function {
            return mCompleteCallback;
        }

        /**
         * @private
         */
        public function set completeCallback( value:Function ):void {
            mCompleteCallback = value;
        }

        /**
         * Function that is called when the sharing is cancelled.
         *
         * The callback is expected to have this signature:
         * <listing version="3.0">
         * function onShareCancelCallback():void {
         *
         * }
         * </listing>
         */
        public function get cancelCallback():Function {
            return mCancelCallback;
        }

        /**
         * @private
         */
        public function set cancelCallback( value:Function ):void {
            mCancelCallback = value;
        }

        /**
         * Function that is called when the sharing fails.
         *
         * The callback is expected to have this signature:
         * <listing version="3.0">
         * function onShareErrorCallback( errorMessage:String ):void {
         *     // errorMessage contains the reason of the failure
         * }
         * </listing>
         */
        public function get errorCallback():Function {
            return mErrorCallback;
        }

        /**
         * @private
         */
        public function set errorCallback( value:Function ):void {
            mErrorCallback = value;
        }

    }

}
