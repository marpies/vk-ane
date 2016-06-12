# VK | VK.com extension for Adobe AIR (iOS & Android)

Development of this extension is supported by [Master Tigra, Inc.](https://github.com/mastertigra)

## Features

* Session management (auth, logout)
* Acessing user token
* (WIP) Requests
* (WIP) Sharing

## Getting started

Create an app in the [VK dashboard](http://vk.com/apps?act=manage). In the Settings tab, configure your app's IDs for iOS and/or Android. AIR apps for Android have their identifier prefixed with `air.` (unless you manually override this behavior). Thus the settings must reflect this. The settings for *Main activity for Android:* is simply your app ID (Android package name) followed by `.AppEntry`. See [the official guide](https://github.com/VKCOM/vk-android-sdk#fingerprint-receiving-via-keytool) on how to get your *Signing certificate fingerprint*.

### Additions to AIR descriptor

First, add the extension's ID to the `extensions` element.

```xml
<extensions>
    <extensionID>com.marpies.ane.vk</extensionID>
</extensions>
```

If you are targeting Android, add the following extension as well (unless you know the Android Support library is included by some other extension):

```xml
<extensions>
    <extensionID>com.marpies.ane.androidsupport</extensionID>
</extensions>
```

For iOS support, add the following to `iPhone / InfoAdditions` element where `{APP_ID}` is the *Application ID* as specified in your VK dashboard:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
            <array>
                <string>vk{APP_ID}</string>
            </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>vk</string>
    <string>vk-share</string>
    <string>vkauthorize</string>
</array>
```

If you plan to use `nohttps` in your requests, add the following snippet as well to make sure the SDK works correctly on iOS9+:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>vk.com</key>
        <dict>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

For Android support, modify the `manifestAdditions` so that it contains the following permission and activity:

```xml
<android>
    <manifestAdditions>
        <![CDATA[
        <manifest android:installLocation="auto">
            <uses-permission android:name="android.permission.INTERNET"/>

            <application>

                <activity
                    android:name="com.vk.sdk.VKServiceActivity"
                    android:label="ServiceActivity"
                    android:theme="@style/VK.Transparent"
                />

            </application>

        </manifest>
        ]]>
    </manifestAdditions>
</android>
```

After your descriptor is set up, add the VK ANE package from the [bin](bin/) directory to your project so that your IDE can work with it. The Android support ANE is only necessary during packaging.

### API overview

See the sources for the [demo application](demo_app/).

#### Initialization

Start by initializing the extension ideally after your app launches. You can also set a callback to be notified when an access token changes (which may happen shortly after you initialize the extension).

```as3
// The callback expects no parameters
VK.addAccessTokenUpdateCallback( onAccessTokenUpdated );
// The Boolean enables extension logs
VK.init( "VK_APP_ID", true );
...
function onAccessTokenUpdated():void {
	// Access token updated, may be null if user is not logged in
	// Retrieve the token using VK.accessToken
}
```

The `onAccessTokenUpdated` method will be called repeatedly if the access token changes (for example, when user logs in). You can remove the callback using:

```as3
VK.removeAccessTokenUpdateCallback( onAccessTokenUpdated );
```

#### Authorization

To authorize user, call the `authorize` method along with the requested permissions and callback:

```as3
VK.authorize( new <String>[ VKPermissions.FRIENDS ], onAuthResult );

function onAuthResult( errorMessage:String ):void {
	if( errorMessage == null ) {
		// Error logging in or user denied
	} else {
		// Good to go
	}
}
```
To check whether user is logged in, use the `isLoggedIn` getter:

```as3
VK.isLoggedIn
```

To log the user out, call the `logout` method:

```as3
VK.logout();
// Token update callback will be called (if added before)
```

#### Requests

To see all the request methods and their parameters, please visit the [official documentation](https://new.vk.com/dev/methods).

To send a request to VK network, use the `VK.request` getter. It is a [builder object](https://en.wikipedia.org/wiki/Builder_pattern) and the usage is as follows:

```as3
// Simple request with no parameters
VK.request
    .setMethod( "account.getAppPermissions" )
    .setResponseCallback( onGetAppPermissionsResponse )
    .setErrorCallback( onGetAppPermissionsError )
    .send();
...
// Response (success) callback expects Object and VKRequest parameters
private function onGetAppPermissionsResponse( response:Object, originalRequest:VKRequest ):void {
    trace( "VKRequest::onGetAppPermissionsResponse for request: " + originalRequest.method );
    // response param is a JSON
    // originalRequest param may be useful to retrieve the request method (for example if you use a single callback method for different requests)
}

// Error callback expects String (that is the error message if provided)
private function onGetAppPermissionsError( error:String ):void {
    trace( "VKRequest::onGetAppPermissionsError: " + error );
}

...

// A little more complex request with parameters
VK.request
    .setMethod( "users.get" )
    .setParameters( {
        user_ids: ["210700286"],
        fields  : "photo_200,city,verified"
    } )
    .setResponseCallback( onGetUsersResponse )
    .setErrorCallback( onGetUsersError )
    .send();
...
private function onGetUsersResponse( response:Object, originalRequest:VKRequest ):void {
    Logger.log( "VK::onGetUsersResponse for request: " + originalRequest.method );
    // response JSON could be something like this:
    /*
    { 
    response: [
            first_name: "Lindsey",
            photo_200: "https://pp.vk.me/c631329/v631329286/23f6c/oMiHw7KjcrU.jpg",
            id: 210700286,
            verified: 1,
            city: {
              title: Los Angeles
              id: 5331
            },
            last_name: "Stirling"
        ]
    }
    */
}
```

## Requirements

* iOS 7+
* Android 4+
* Adobe AIR 20+

## Documentation
Generated ActionScript documentation is available in the *docs* directory, or can be generated by running `ant asdoc` from the [build](build/) directory.

## Build ANE
ANT build scripts are available in the [build](build/) directory. Edit [build.properties](build/build.properties) to correspond with your local setup.

## Author
The ANE has been written by [Marcel Piestansky](https://twitter.com/marpies) and is distributed under [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).