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

package com.marpies.ane.vk {

    import flash.desktop.NativeApplication;
    import flash.events.InvokeEvent;
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;
    import flash.system.Capabilities;
    import flash.utils.Dictionary;

    public class VK {

        private static const TAG:String = "[VK]";
        private static const EXTENSION_ID:String = "com.marpies.ane.vk";

        private static var mContext:ExtensionContext;

        /* VK objects */
        private static var mAccessToken:VKAccessToken;
        private static var mRequestBuilder:VKRequestBuilder;
        private static var mShareBuilder:VKShareBuilder;

        /* Misc */
        private static var mLogEnabled:Boolean;
        private static var mInitialized:Boolean;

        /* Callbacks */
        private static var mRequestIdCounter:int;
        private static var mAuthCallback:Function;
        private static var mShareCompleteCallback:Function;
        private static var mShareCancelCallback:Function;
        private static var mShareErrorCallback:Function;
        private static var mRequestMap:Dictionary;
        private static var mTokenUpdateCallbacks:Vector.<Function> = new <Function>[];

        /* Internal event codes */
        private static const VK_AUTH_ERROR:String = "vkAuthError";
        private static const VK_AUTH_SUCCESS:String = "vkAuthSuccess";
        private static const VK_TOKEN_UPDATE:String = "vkTokenUpdate";
        private static const VK_REQUEST_SUCCESS:String = "vkRequestSuccess";
        private static const VK_REQUEST_ERROR:String = "vkRequestError";
        private static const VK_SHARE_COMPLETE:String = "vkShareComplete";
        private static const VK_SHARE_CANCEL:String = "vkShareCancel";
        private static const VK_SHARE_ERROR:String = "vkShareError";

        /**
         * @private
         * Do not use. VK is a static class.
         */
        public function VK() {
            throw Error( "VK is static class." );
        }

        /**
         *
         *
         * Public API
         *
         *
         */

        /**
         * Initializes extension context.
         *
         * @param appId     VK app id.
         * @param showLogs  Set to <code>true</code> to show extension log messages.
         *
         * @return <code>true</code> if the extension context was created, <code>false</code> otherwise
         */
        public static function init( appId:String, showLogs:Boolean = false ):Boolean {
            if( !isSupported ) return false;
            if( mInitialized ) return true;

            if( appId === null ) throw new ArgumentError( "Parameter appId cannot be null." );

            mLogEnabled = showLogs;

            /* Initialize context */
            if( !initExtensionContext() ) {
                log( "Error creating extension context for " + EXTENSION_ID );
                return false;
            }

            mRequestMap = new Dictionary();
            if( mTokenUpdateCallbacks === null ) {
                mTokenUpdateCallbacks = new <Function>[];
            }
            mRequestBuilder = VKRequestBuilder.instance;
            mShareBuilder = VKShareBuilder.instance;

            /* Listen for native library events */
            mContext.addEventListener( StatusEvent.STATUS, onStatus );
            /* Listen for invoke event */
            NativeApplication.nativeApplication.addEventListener( InvokeEvent.INVOKE, onInvokeHandler );

            /* Call init */
            mContext.call( "init", appId, showLogs );
            mInitialized = true;
            return true;
        }

        /**
         * Attempts to authorize user with given permissions.
         * @param permissions List of permissions.
         * @param callback Function to be called with the auth result. The function should accept
         *                 single <code>String</code> parameter (possible error message).
         */
        public static function authorize( permissions:Vector.<String>, callback:Function ):void {
            if( !isSupported ) return;
            validateExtensionContext();

            mAuthCallback = callback;

            if( isLoggedIn ) {
                dispatchAuthResult( null );
                return;
            }

            mContext.call( "auth", permissions );
        }

        /**
         * Logs out current user.
         */
        public static function logout():void {
            if( !isSupported ) return;
            validateExtensionContext();

            if( !isLoggedIn ) return;

            mContext.call( "logout" );
        }

        /**
         * Checks whether the access token has the given permission.
         */
        public static function hasPermission( permission:String ):Boolean {
            if( mAccessToken === null || mAccessToken.permissions === null ) return false;
            return mAccessToken.permissions.indexOf( permission ) >= 0;
        }

        /**
         * Adds callback that will be called when access token is updated.
         * @param callback Function to be called when access token is updated. It should expect zero parameters.
         *
         * @see com.marpies.ane.vk.VK.removeAccessTokenUpdateCallback
         */
        public static function addAccessTokenUpdateCallback( callback:Function ):void {
            if( !isSupported ) return;

            if( callback === null ) throw new ArgumentError( "Parameter callback cannot be null." );

            if( mTokenUpdateCallbacks.indexOf( callback ) < 0 ) {
                mTokenUpdateCallbacks[mTokenUpdateCallbacks.length] = callback;
            }
        }

        /**
         * Removes callback that was added earlier using <code>VK.addAccessTokenUpdateCallback()</code>.
         * @param callback Function to remove.
         *
         * @see com.marpies.ane.vk.VK.addAccessTokenUpdateCallback
         */
        public static function removeAccessTokenUpdateCallback( callback:Function ):void {
            if( !isSupported ) return;

            if( callback === null ) throw new ArgumentError( "Parameter callback cannot be null." );

            var index:int = mTokenUpdateCallbacks.indexOf( callback );
            if( index < 0 ) {
                mTokenUpdateCallbacks.removeAt( index );
            }
        }

        /**
         * Disposes native extension context.
         */
        public static function dispose():void {
            if( !isSupported || !mInitialized ) return;

            mContext.removeEventListener( StatusEvent.STATUS, onStatus );
            NativeApplication.nativeApplication.removeEventListener( InvokeEvent.INVOKE, onInvokeHandler );

            mRequestBuilder = null;
            mShareBuilder = null;
            mTokenUpdateCallbacks = null;
            mContext.dispose();
            mContext = null;
            mInitialized = false;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Returns current access token, or <code>null</code> if there is none.
         */
        public static function get accessToken():VKAccessToken {
            return mAccessToken;
        }

        /**
         * Getter for internal request builder used for creating and sending requests to VK network.
         */
        public static function get request():VKRequestBuilder {
            if( !isSupported ) return null;

            if( mRequestBuilder === null ) throw new Error( "Initialize the extension before making a request." );
            return mRequestBuilder.init();
        }

        /**
         * Getter for internal sharing builder used for creating and showing native UI share dialog.
         */
        public static function get share():VKShareBuilder {
            if( !isSupported ) return null;

            if( mShareBuilder === null ) throw new Error( "Initialize the extension before sharing." );
            return mShareBuilder.init();
        }

        /**
         * Returns <code>true</code> if user is logged in.
         */
        public static function get isLoggedIn():Boolean {
            if( !isSupported || !mInitialized ) return false;

            return mContext.call( "isLoggedIn" ) as Boolean;
        }

        /**
         * Extension version.
         */
        public static function get version():String {
            return "1.0.1";
        }

        /**
         * Version of the native VK SDK.
         */
        public static function get sdkVersion():String {
            if( !isSupported ) return null;
            if( !mInitialized && !initExtensionContext() ) {
                return null;
            }

            return mContext.call( "sdkVersion" ) as String;
        }

        /**
         * Supported on iOS and Android.
         */
        public static function get isSupported():Boolean {
            return iOS || Capabilities.manufacturer.indexOf( "Android" ) > -1;
        }

        /**
         *
         *
         * Private API
         *
         *
         */

        internal static function sendRequestInternal( request:VKRequest ):void {
            var requestId:int = registerRequest( request );
            var params:Array = getArrayFromObject( request.parameters );

            log( "VK::sendRequestInternal()" );

            mContext.call( "request", request.method, params, requestId );
        }

        internal static function showShareDialogInternal( params:VKShareParameters ):void {
            log( "VK::showShareDialogInternal()" );
            
            /* Store callbacks */
            mShareCompleteCallback = params.completeCallback;
            mShareCancelCallback = params.cancelCallback;
            mShareErrorCallback = params.errorCallback;

            mContext.call( "share", params.text, params.attachmentLinkTitle, params.attachmentLinkURL, params.uploadedPhotos, params.attachmentImages );
        }

        private static function dispatchAuthResult( error:String ):void {
            if( mAuthCallback !== null ) {
                mAuthCallback( error );
                mAuthCallback = null;
            }
        }

        /**
         * Initializes extension context.
         * @return <code>true</code> if initialized successfully, <code>false</code> otherwise.
         */
        private static function initExtensionContext():Boolean {
            if( mContext === null ) {
                mContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null );
            }
            return mContext !== null;
        }

        /**
         * Registers given request and generates ID which is used to look the request up when
         * it is time to call its callback methods.
         *
         * @param request Function to register.
         * @return ID of the request.
         */
        private static function registerRequest( request:VKRequest ):int {
            if( request === null || !request.hasAnyCallback ) return -1;

            mRequestMap[mRequestIdCounter] = request;
            return mRequestIdCounter++;
        }

        /**
         * Gets registered request with given ID.
         *
         * @param requestId ID of the request to retrieve.
         * @return Request registered with given ID, or <code>null</code> if no such request exists.
         */
        private static function getRequest( requestId:int ):VKRequest {
            if( requestId == -1 || !(requestId in mRequestMap) ) return null;
            return mRequestMap[requestId];
        }

        /**
         * Unregisters request with given ID.
         *
         * @param requestId ID of the request to unregister.
         */
        private static function unregisterRequest( requestId:int ):void {
            if( requestId in mRequestMap ) {
                delete mRequestMap[requestId];
            }
        }

        /**
         * Returns a list of key-values from key-value object, e.g. { "key": "val" } -> [ "key", "val" ].
         * @param object Key-value object to transform into list.
         * @return List of key-values from <code>object</code>, or <code>null</code> if <code>object</code> is <code>null</code>.
         */
        private static function getArrayFromObject( object:Object ):Array {
            var properties:Array = null;
            if( object !== null ) {
                properties = [];
                /* Create a list of object properties, that is a key followed by its value */
                for( var key:String in object ) {
                    properties[properties.length] = key;
                    properties[properties.length] = object[key];
                }
            }
            return properties;
        }

        private static function validateExtensionContext():void {
            if( !mContext ) throw new Error( "VK extension was not initialized. Call init() first." );
        }

        private static function onStatus( event:StatusEvent ):void {
            var request:VKRequest = null;
            var requestId:int = -1;
            var responseJSON:Object = null;
            switch( event.code ) {
                case VK_AUTH_SUCCESS:
                    log( "Success auth" );
                    parseAccessToken( event.level );
                    dispatchAuthResult( null );
                    return;
                case VK_AUTH_ERROR:
                    log( "Error auth" );
                    dispatchAuthResult( event.level );
                    return;
                case VK_TOKEN_UPDATE:
                    log( "Token update, callbacks " + mTokenUpdateCallbacks.length );
                    parseAccessToken( event.level );
                    /* Call the registered callbacks */
                    var length:int = mTokenUpdateCallbacks.length;
                    for( var i:int = 0; i < length; ++i ) {
                        mTokenUpdateCallbacks[i]();
                    }
                    return;
                case VK_REQUEST_SUCCESS:
                    responseJSON = JSON.parse( event.level );
                    log( "Request success" );
                    requestId = responseJSON.requestId;
                    request = getRequest( requestId );
                    if( request !== null && request.hasResponseCallback ) {
                        /* Delete 'requestId' from the response JSON (it's manually inserted in
                         * native library for us to retrieve the correct VKRequest here in AS3) */
                        delete responseJSON.requestId;
                        request.responseCallback( responseJSON, request );
                        unregisterRequest( requestId );
                    }
                    return;
                case VK_REQUEST_ERROR:
                    responseJSON = JSON.parse( event.level );
                    log( "Request error: " + responseJSON.errorMessage );
                    requestId = responseJSON.requestId;
                    request = getRequest( requestId );
                    if( request !== null && request.hasErrorCallback ) {
                        request.errorCallback( responseJSON.errorMessage );
                        unregisterRequest( requestId );
                    }
                    return;
                case VK_SHARE_COMPLETE:
                    log( "Share complete, postId: " + event.level );
                    if( mShareCompleteCallback !== null ) {
                        mShareCompleteCallback( event.level );
                    }
                    removeShareCallbacks();
                    return;
                case VK_SHARE_CANCEL:
                    log( "Share cancelled" );
                    if( mShareCancelCallback !== null ) {
                        mShareCancelCallback();
                    }
                    removeShareCallbacks();
                    return;
                case VK_SHARE_ERROR:
                    log( "Share error: " + event.level );
                    if( mShareErrorCallback !== null ) {
                        mShareErrorCallback( event.level );
                    }
                    removeShareCallbacks();
                    return;
            }
        }

        private static function onInvokeHandler( event:InvokeEvent ):void {
            log( "onInvoke " + event.reason + " args: " + event.arguments );

            /* Handle openURL invoke event, to avoid iOS app delegate method swizzling */
            if( event.reason && event.reason.toLowerCase() == "openurl" ) {
                const args:Array = event.arguments;
                var url:String = String( args[0] );
                if( url !== null ) {
                    var sourceApp:String = null;
                    if( args.length > 1 ) {
                        sourceApp = String( args[1] );
                    }
                    mContext.call( "applicationOpenURL", url , sourceApp );
                }
            }
        }

        private static function parseAccessToken( jsonStr:String ):void {
            var json:Object = JSON.parse( jsonStr );
//            printObject( json, " " );
            mAccessToken = VKAccessToken.fromJSON( json );
        }

        private static function removeShareCallbacks():void {
            mShareCancelCallback = null;
            mShareCompleteCallback = null;
            mShareErrorCallback = null;
        }

        private static function printObject( object:Object, indent:String = "" ):void {
            for( var key:String in object ) {
                var value:Object = object[key];
                if( value is Array ) {
                    log( indent + key + " -> Array( " + value + " )" );
                } else {
                    log( indent + key + " -> " + value );
                }
                printObject( value, indent + "  " );
            }
        }

        private static function log( message:String ):void {
            if( mLogEnabled ) {
                trace( TAG, message );
            }
        }

        private static function get iOS():Boolean {
            return Capabilities.manufacturer.indexOf( "iOS" ) > -1;
        }

    }
}
