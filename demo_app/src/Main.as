package {

    import com.marpies.ane.vk.VK;
    import com.marpies.ane.vk.VKPermissions;
    import com.marpies.ane.vk.VKRequest;
    import com.marpies.utils.Constants;
    import com.marpies.utils.Logger;
    import com.marpies.utils.ObjectUtils;
    import com.marpies.utils.VerticalLayoutBuilder;

    import feathers.controls.Button;
    import feathers.controls.LayoutGroup;
    import feathers.layout.VerticalLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import starling.events.Event;

    public class Main extends LayoutGroup {

        /* Your VK.com app ID goes here */
        private static const VK_APP_ID:String = null;

        private var mLogoutBtn:Button;
        private var mAuthBtn:Button;
        private var mGetUsersRequestBtn:Button;
        private var mGetAppPermissionsRequestBtn:Button;
        private var mWallPostRequestBtn:Button;
        private var mShareBtn:Button;

        public function Main() {
            super();

            if( VK_APP_ID === null ) throw new Error( "You must specify VK_APP_ID in Main.as" );

            new MetalWorksMobileTheme();
        }

        public function start():void {
            layout = new VerticalLayoutBuilder()
                    .setGap( 10 )
                    .setHorizontalAlign( VerticalLayout.HORIZONTAL_ALIGN_CENTER )
                    .setVerticalAlign( VerticalLayout.VERTICAL_ALIGN_MIDDLE )
                    .build();
            width = Constants.stageWidth;
            height = Constants.stageHeight;

            mAuthBtn = new Button();
            mAuthBtn.label = "Authorize";
            mAuthBtn.isEnabled = VK.isSupported;
            mAuthBtn.validate();
            mAuthBtn.addEventListener( Event.TRIGGERED, onAuthBtnTriggered );
            addChild( mAuthBtn );

            mLogoutBtn = new Button();
            mLogoutBtn.label = "Logout";
            mLogoutBtn.isEnabled = false;
            mLogoutBtn.styleNameList.add( Button.ALTERNATE_STYLE_NAME_DANGER_BUTTON );
            mLogoutBtn.addEventListener( Event.TRIGGERED, onLogoutBtnTriggered );
            addChild( mLogoutBtn );

            mGetUsersRequestBtn = new Button();
            mGetUsersRequestBtn.label = "Req: users.get";
            mGetUsersRequestBtn.isEnabled = VK.isSupported; // No need to be authorized to use this request
            mGetUsersRequestBtn.addEventListener( Event.TRIGGERED, onGetUsersRequestBtnTriggered );
            addChild( mGetUsersRequestBtn );

            mGetAppPermissionsRequestBtn = new Button();
            mGetAppPermissionsRequestBtn.label = "Req: account.getAppPermissions";
            mGetAppPermissionsRequestBtn.isEnabled = false;
            mGetAppPermissionsRequestBtn.addEventListener( Event.TRIGGERED, onGetAppPermissionsRequestBtnTriggered );
            addChild( mGetAppPermissionsRequestBtn );
            addChild( mGetUsersRequestBtn );

            mWallPostRequestBtn = new Button();
            mWallPostRequestBtn.label = "Req: wall.post";
            mWallPostRequestBtn.isEnabled = false;
            mWallPostRequestBtn.addEventListener( Event.TRIGGERED, onWallPostRequestBtnTriggered );
            addChild( mWallPostRequestBtn );

            mShareBtn = new Button();
            mShareBtn.label = "Share dialog";
            mShareBtn.isEnabled = false;
            mShareBtn.addEventListener( Event.TRIGGERED, onShareBtnTriggered );
            addChild( mShareBtn );

            VK.addAccessTokenUpdateCallback( onAccessTokenUpdated );
            VK.init( VK_APP_ID, true );
        }

        /**
         *
         *
         * UI handlers
         *
         *
         */

        private function onAuthBtnTriggered():void {
            VK.authorize( new <String>[ VKPermissions.FRIENDS, VKPermissions.WALL ], onAuthResult );
        }

        private function onLogoutBtnTriggered():void {
            VK.logout();
        }

        private function onGetUsersRequestBtnTriggered():void {
            VK.request
                    .setMethod( "users.get" )
                    .setParameters( {
                        user_ids: ["210700286"],
                        fields  : "photo_200,city,verified"
                    } )
                    .setResponseCallback( onGetUsersResponse )
                    .setErrorCallback( onGetUsersError )
                    .send();
        }

        private function onGetAppPermissionsRequestBtnTriggered():void {
            VK.request
                    .setMethod( "account.getAppPermissions" )
                    .setResponseCallback( onGetAppPermissionsResponse )
                    .setErrorCallback( onGetAppPermissionsError )
                    .send();
        }

        private function onWallPostRequestBtnTriggered():void {
            VK.request
                    .setMethod( "wall.post" )
                    .setParameters( {
                        message: "Hello, here's a link to a Starling framework page.",
                        attachments: ["http://gamua.com/starling/"]
                    } )
                    .setResponseCallback( onWallPostResponse )
                    .setErrorCallback( onWallPostError )
                    .send();
        }

        private function onShareBtnTriggered():void {
            VK.share
                    .setText( "Hello, sharing this fine link with you." )
                    .setAttachmentLink( "VK.com", "http://vk.com" )
                    .setCompleteCallback( onShareCompleted )
                    .setCancelCallback( onShareCancelled )
                    .setErrorCallback( onShareFailed )
                    .showDialog();
        }

        /**
         *
         *
         * VK handlers
         *
         *
         */

        private function onAccessTokenUpdated():void {
            mLogoutBtn.isEnabled = VK.isLoggedIn;
            mAuthBtn.isEnabled = VK.isSupported && !VK.isLoggedIn;
            mGetAppPermissionsRequestBtn.isEnabled = VK.isSupported && VK.isLoggedIn; // User must be authorized to use this request
            mWallPostRequestBtn.isEnabled = VK.isSupported && VK.isLoggedIn; // User must be authorized to use this request
            mShareBtn.isEnabled = VK.isSupported && VK.isLoggedIn; // User must be authorized to use sharing

            if( VK.accessToken === null ) {
                Logger.log( "VK::onAccessTokenUpdated | not logged in" );
            } else {
                Logger.log( "VK::onAccessTokenUpdated | userId: " + VK.accessToken.userId + " perms: " + VK.accessToken.permissions + " isLoggedIn: " + VK.isLoggedIn );
            }
        }

        private function onAuthResult( errorMessage:String ):void {
            Logger.log( "VK::onAuthResult | error: " + errorMessage );
            Logger.log( "VK::onAuthResult | accessToken: " + VK.accessToken );
            Logger.log( "VK::onAuthResult | isLoggedIn: " + VK.isLoggedIn );
        }

        private function onGetUsersResponse( response:Object, originalRequest:VKRequest ):void {
            Logger.log( "VK::onGetUsersResponse for request: " + originalRequest.method );
            ObjectUtils.printObject( response );
        }

        private function onGetUsersError( error:String ):void {
            Logger.log( "VK::onGetUsersError: " + error );
        }

        private function onGetAppPermissionsResponse( response:Object, originalRequest:VKRequest ):void {
            Logger.log( "VK::onGetAppPermissionsResponse for request: " + originalRequest.method );
            ObjectUtils.printObject( response );
        }

        private function onGetAppPermissionsError( error:String ):void {
            Logger.log( "VK::onGetAppPermissionsError: " + error );
        }

        private function onWallPostResponse( response:Object, originalRequest:VKRequest ):void {
            Logger.log( "VK::onWallPostResponse for request: " + originalRequest.method );
            ObjectUtils.printObject( response );
        }

        private function onWallPostError( error:String ):void {
            Logger.log( "VK::onWallPostError: " + error );
        }

        private function onShareCompleted( postId:String ):void {
            Logger.log( "VK::onShareCompleted postId: " + postId );
        }

        private function onShareCancelled():void {
            Logger.log( "VK::onShareCancelled" );
        }

        private function onShareFailed( errorMessage:String ):void {
            Logger.log( "VK::onShareFailed " + errorMessage );
        }

    }

}
