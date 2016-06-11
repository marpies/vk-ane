package com.marpies.ane.vk {

    /**
     * VO representing VK request. For internal use only.
     */
    public class VKRequest {

        private var mMethod:String;
        private var mParameters:Object;
        private var mResponseCallback:Function;
        private var mErrorCallback:Function;

        public function VKRequest() {
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Request API method, e.g. <code>users.get</code>.
         *
         * @see http://new.vk.com/dev/methods
         */
        public function get method():String {
            return mMethod;
        }

        /**
         * @private
         */
        public function set method( value:String ):void {
            mMethod = value;
        }

        /**
         * Request parameters, a key-value object. Can be <code>null</code> if the
         * request method does not require any parameters.
         *
         * <p>The value can be one of the following types:
         * <ul>
         *     <li><code>int, uint, Number</code></li>
         *     <li><code>String</code></li>
         *     <li><code>Array (of Strings)</code></li>
         *     <li><code>Vector.&lt;String&gt;</code></li>
         * </ul>
         * If one of the values in an <code>Array</code> must be numeric then simply wrap it in quotes.
         * </p>
         *
         * An example <code>parameters</code> value for <code>users.get</code> request:
         * <listing version="3.0">
         * VK.request
         *     .setMethod( "users.get" )
         *     .setParameters( {
         *         user_ids: ["210700286"],
         *         fields  : "photo_200,city,verified"
         *     } )
         *     .setResponseCallback( onUsersGetResponse )
         *     .send();
         * </listing>
         */
        public function get parameters():Object {
            return mParameters;
        }

        /**
         * @private
         */
        public function set parameters( value:Object ):void {
            mParameters = value;
        }

        /**
         * Function that is called when the request is successfully executed.
         *
         * The callback is expected to have this signature:
         * <listing version="3.0">
         * function onResponseCallback( response:Object, originalRequest:VKRequest ):void {
         *     // response is a parsed JSON
         *     // originalRequest represents the request that was executed
         * }
         * </listing>
         */
        public function get responseCallback():Function {
            return mResponseCallback;
        }

        /**
         * @private
         */
        public function set responseCallback( value:Function ):void {
            mResponseCallback = value;
        }

        /**
         * Function that is called when the request fails.
         *
         * The callback is expected to have this signature:
         * <listing version="3.0">
         * function onErrorCallback( errorMessage:String ):void {
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

        /**
         * @private
         */
        internal function get hasErrorCallback():Boolean {
            return mErrorCallback !== null;
        }

        /**
         * @private
         */
        internal function get hasResponseCallback():Boolean {
            return mResponseCallback !== null;
        }

        /**
         * @private
         */
        internal function get hasAnyCallback():Boolean {
            return hasErrorCallback || hasResponseCallback;
        }

    }

}
