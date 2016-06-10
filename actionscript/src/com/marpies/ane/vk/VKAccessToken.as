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

    public class VKAccessToken {

        private var mUserId:String;
        private var mAccessToken:String;
        private var mSecret:String;
        private var mPermissions:Vector.<String>;
        private var mEmail:String;
        private var mHttpsRequired:Boolean;
        private var mCreated:int;
        private var mExpiresIn:int;

        public function VKAccessToken() {
        }

        /**
         *
         *
         * Internal API
         *
         *
         */

        internal static function fromJSON( json:Object ):VKAccessToken {
            if( !("userId" in json) ) return null;

            var token:VKAccessToken = new VKAccessToken();
            token.mUserId = json.userId;
            token.mAccessToken = json.accessToken;
            token.mHttpsRequired = json.httpsRequired;
            token.mCreated = json.created;
            token.mExpiresIn = json.expiresIn;
            if( "permissions" in json ) {
                var permissions:Array = json.permissions as Array;
                if( permissions === null ) {
                    try {
                        permissions = JSON.parse( json.permissions ) as Array;
                    } catch( e:Error ) { }
                }
                if( permissions !== null ) {
                    token.mPermissions = Vector.<String>( permissions );
                }
            }
            if( "secret" in json ) {
                token.mSecret = json.secret;
            }
            if( "email" in json ) {
                token.mEmail = json.secret;
            }
            return token;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Current user id for this token.
         */
        public function get userId():String {
            return mUserId;
        }

        /**
         * Actual access token string.
         */
        public function get accessToken():String {
            return mAccessToken;
        }

        /**
         * User secret to sign requests (if nohttps is used).
         */
        public function get secret():String {
            return mSecret;
        }

        /**
         * Permissions associated with the token.
         */
        public function get permissions():Vector.<String> {
            return mPermissions;
        }

        /**
         * <code>true</code> if user sets "Always use HTTPS" setting in his profile.
         */
        public function get httpsRequired():Boolean {
            return mHttpsRequired;
        }

        /**
         * Indicates time of token creation
         */
        public function get created():int {
            return mCreated;
        }

        /**
         * Time when token expires.
         */
        public function get expiresIn():int {
            return mExpiresIn;
        }

        /**
         * User email, if available.
         */
        public function get email():String {
            return mEmail;
        }

    }

}
