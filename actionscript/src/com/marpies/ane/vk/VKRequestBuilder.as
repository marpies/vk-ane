package com.marpies.ane.vk {

    /**
     * Builder to create VK requests. For internal use only.
     */
    public class VKRequestBuilder {

        /* Singleton stuff */
        private static var mCanInitialize:Boolean;
        private static var mInstance:VKRequestBuilder;

        private var mRequest:VKRequest;

        public function VKRequestBuilder() {
            if( !mCanInitialize ) throw new Error( "VKRequestBuilder cannot be used directly. Access it using VK.request." );
        }

        internal static function get instance():VKRequestBuilder {
            if( !mInstance ) {
                mCanInitialize = true;
                mInstance = new VKRequestBuilder();
                mCanInitialize = false;
            }
            return mInstance;
        }

        /**
         * Initializes builder for new request.
         */
        internal function init():VKRequestBuilder {
            mRequest = new VKRequest();
            return this;
        }

        /**
         * Request API method, e.g. <code>users.get</code>.
         *
         * @see http://new.vk.com/dev/methods
         */
        public function setMethod( method:String ):VKRequestBuilder {
            if( method === null ) throw new ArgumentError( "Parameter method cannot be null." );
            mRequest.method = method;
            return this;
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
        public function setParameters( parameters:Object ):VKRequestBuilder {
            if( parameters === null ) throw new ArgumentError( "Parameter parameters cannot be null." );
            mRequest.parameters = parameters;
            return this;
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
        public function setResponseCallback( responseCallback:Function ):VKRequestBuilder {
            if( responseCallback === null ) throw new ArgumentError( "Parameter responseCallback cannot be null." );
            mRequest.responseCallback = responseCallback;
            return this;
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
        public function setErrorCallback( errorCallback:Function ):VKRequestBuilder {
            if( errorCallback === null ) throw new ArgumentError( "Parameter errorCallback cannot be null." );
            mRequest.errorCallback = errorCallback;
            return this;
        }

        /**
         * Sends the request to the VK network.
         */
        public function send():void {
            if( mRequest.method === null ) throw new Error( "Request method must be specified." );
            VK.sendRequestInternal( mRequest );
        }

    }

}
