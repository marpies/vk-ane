package {

    import com.marpies.ane.vk.VK;
    import com.marpies.ane.vk.VKPermissions;
    import com.marpies.utils.AnchorLayoutDataBuilder;
    import com.marpies.utils.Constants;
    import com.marpies.utils.Logger;

    import feathers.controls.Button;
    import feathers.controls.LayoutGroup;
    import feathers.layout.AnchorLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import starling.events.Event;

    public class Main extends LayoutGroup {

        /* Your VK.com app ID goes here */
        private static const VK_APP_ID:String = null;

        private var mLogoutBtn:Button;
        private var mAuthBtn:Button;

        public function Main() {
            super();

            if( VK_APP_ID === null ) throw new Error( "You must specify VK_APP_ID in Main.as" );

            new MetalWorksMobileTheme();
        }

        public function start():void {
            layout = new AnchorLayout();
            width = Constants.stageWidth;
            height = Constants.stageHeight;

            mAuthBtn = new Button();
            mAuthBtn.label = "Authorize";
            mAuthBtn.isEnabled = VK.isSupported;
            mAuthBtn.validate();
            mAuthBtn.layoutData = new AnchorLayoutDataBuilder().setHorizontalCenter( 0 ).setVerticalCenter( -mAuthBtn.height ).build();
            mAuthBtn.addEventListener( Event.TRIGGERED, onAuthBtnTriggered );
            addChild( mAuthBtn );

            mLogoutBtn = new Button();
            mLogoutBtn.label = "Logout";
            mLogoutBtn.layoutData = new AnchorLayoutDataBuilder().setHorizontalCenter( 0 ).setTop( 10 ).setTopAnchorObject( mAuthBtn ).build();
            mLogoutBtn.styleNameList.add( Button.ALTERNATE_STYLE_NAME_DANGER_BUTTON );
            mLogoutBtn.addEventListener( Event.TRIGGERED, onLogoutBtnTriggered );
            addChild( mLogoutBtn );

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
            VK.authorize( new <String>[ VKPermissions.FRIENDS ], onAuthResult );
        }

        private function onLogoutBtnTriggered():void {
            VK.logout();
        }

        /**
         *
         *
         * VK handlers
         *
         *
         */

        private function onAuthResult( errorMessage:String ):void {
            Logger.log( "VK::onAuthResult | error: " + errorMessage );
            Logger.log( "VK::onAuthResult | accessToken: " + VK.accessToken );
            Logger.log( "VK::onAuthResult | isLoggedIn: " + VK.isLoggedIn );
        }

        private function onAccessTokenUpdated():void {
            mLogoutBtn.isEnabled = VK.isLoggedIn;
            mAuthBtn.isEnabled = VK.isSupported && !VK.isLoggedIn;

            if( VK.accessToken === null ) {
                Logger.log( "VK::onAccessTokenUpdated | not logged in" );
            } else {
                Logger.log( "VK::onAccessTokenUpdated | userId: " + VK.accessToken.userId + " perms: " + VK.accessToken.permissions + " isLoggedIn: " + VK.isLoggedIn );
            }
        }

    }

}
