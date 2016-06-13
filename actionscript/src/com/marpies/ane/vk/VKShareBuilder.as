package com.marpies.ane.vk {

    import flash.display.BitmapData;

    /**
     * Builder to create VK share dialog. For internal use only.
     */
    public class VKShareBuilder {

        /* Singleton stuff */
        private static var mCanInitialize:Boolean;
        private static var mInstance:VKShareBuilder;

        private var mShareParams:VKShareParameters;

        public function VKShareBuilder() {
            if( !mCanInitialize ) throw new Error( "VKShareBuilder cannot be used directly. Access it using VK.request." );
        }

        internal static function get instance():VKShareBuilder {
            if( !mInstance ) {
                mCanInitialize = true;
                mInstance = new VKShareBuilder();
                mCanInitialize = false;
            }
            return mInstance;
        }

        /**
         * Initializes builder for new share.
         */
        internal function init():VKShareBuilder {
            mShareParams = new VKShareParameters();
            return this;
        }

        /**
         * List of images to attach to the shared post.
         *
         * @param images List of <code>BitmapData</code> objects representing the images.
         */
        public function setAttachmentImages( images:Vector.<BitmapData> ):VKShareBuilder {
            if( images === null ) throw new ArgumentError( "Parameter images cannot be null." );
            mShareParams.attachmentImages = images;
            return this;
        }

        /**
         * Link to attach to the shared post.
         *
         * @param title Link title.
         * @param url   Link url.
         */
        public function setAttachmentLink( title:String, url:String ):VKShareBuilder {
            if( title === null ) throw new ArgumentError( "Parameter title cannot be null." );
            if( url === null ) throw new ArgumentError( "Parameter url cannot be null." );
            mShareParams.attachmentLinkTitle = title;
            mShareParams.attachmentLinkURL = url;
            return this;
        }

        /**
         * Text of the shared post.
         *
         * @param text Text of the post.
         */
        public function setText( text:String ):VKShareBuilder {
            if( text === null ) throw new ArgumentError( "Parameter text cannot be null." );
            mShareParams.text = text;
            return this;
        }

        /**
         * List of photo IDs which are already uploaded on VK network.
         * Each ID should have the format <code>photo{owner_id}_{photo_id}</code>.
         * You must be granted <code>VKPermissions.PHOTOS</code> permission to successfully
         * use this feature.
         *
         * @param photoIds List of photos IDs.
         */
        public function setUploadedPhotos( photoIds:Vector.<String> ):VKShareBuilder {
            if( photoIds === null ) throw new ArgumentError( "Parameter photoIds cannot be null." );
            mShareParams.uploadedPhotos = photoIds;
            return this;
        }

        /**
         * Function that is called when the sharing is successfully completed.
         *
         * The callback is expected to have this signature:
         * <listing version="3.0">
         * function onShareCompleteCallback( postId:int ):void {
         *
         * }
         * </listing>
         */
        public function setCompleteCallback( completeCallback:Function ):VKShareBuilder {
            if( completeCallback === null ) throw new ArgumentError( "Parameter completeCallback cannot be null." );
            mShareParams.completeCallback = completeCallback;
            return this;
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
        public function setCancelCallback( cancelCallback:Function ):VKShareBuilder {
            if( cancelCallback === null ) throw new ArgumentError( "Parameter cancelCallback cannot be null." );
            mShareParams.cancelCallback = cancelCallback;
            return this;
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
        public function setErrorCallback( errorCallback:Function ):VKShareBuilder {
            if( errorCallback === null ) throw new ArgumentError( "Parameter errorCallback cannot be null." );
            mShareParams.errorCallback = errorCallback;
            return this;
        }

        /**
         * Shows a native dialog with the configured parameters.
         */
        public function showDialog():void {
            VK.showShareDialogInternal( mShareParams );
        }

    }

}
