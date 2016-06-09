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

        /* Misc */
        private static var mLogEnabled:Boolean;
        private static var mInitialized:Boolean;

        /* Callbacks */
        private static var mAuthCallback:Function;
        private static var mCallbackMap:Dictionary;
        private static var mTokenUpdateCallbacks:Vector.<Function> = new <Function>[];

        /* Internal event codes */
        private static const VK_AUTH_ERROR:String = "vkAuthError";
        private static const VK_AUTH_SUCCESS:String = "vkAuthSuccess";
        private static const VK_TOKEN_UPDATE:String = "vkTokenUpdate";

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
            mContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null );
            if( !mContext ) {
                log( "Error creating extension context for " + EXTENSION_ID );
                return false;
            }

            mCallbackMap = new Dictionary();
            if( mTokenUpdateCallbacks === null ) {
                mTokenUpdateCallbacks = new <Function>[];
            }

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
            return "0.0.1";
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

        private static function dispatchAuthResult( error:String ):void {
            if( mAuthCallback !== null ) {
                mAuthCallback( error );
                mAuthCallback = null;
            }
        }

        /**
         * Registers given callback and generates ID which is used to look the callback up when it is time to call it.
         * @param callback Function to register.
         * @return ID of the callback.
         */
        private static function registerCallback( callback:Function ):int {
            if( callback == null ) return -1;

            var id:int;
            do {
                id = Math.random() * 100;
            } while( id in mCallbackMap );

            mCallbackMap[id] = callback;
            return id;
        }

        /**
         * Gets registered callback with given ID.
         * @param callbackID ID of the callback to retrieve.
         * @return Callback registered with given ID, or <code>null</code> if no such callback exists.
         */
        private static function getCallback( callbackID:int ):Function {
            if( callbackID == -1 || !(callbackID in mCallbackMap) ) return null;
            return mCallbackMap[callbackID];
        }

        /**
         * Unregisters callback with given ID.
         * @param callbackID ID of the callback to unregister.
         */
        private static function unregisterCallback( callbackID:int ):void {
            if( callbackID in mCallbackMap ) {
                delete mCallbackMap[callbackID];
            }
        }

        private static function validateExtensionContext():void {
            if( !mContext ) throw new Error( "VK extension was not initialized. Call init() first." );
        }

        private static function onStatus( event:StatusEvent ):void {
            var eventJSON:Object = null;
            switch( event.code ) {
                case VK_AUTH_SUCCESS:
                    log( "Success auth" );
                    parseAccessToken( event.level );
                    dispatchAuthResult( null );
                    return;
                case VK_AUTH_ERROR:
                    log( "Error auth" );
                    eventJSON = JSON.parse( event.level );
                    dispatchAuthResult( eventJSON.errorMessage );
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
