# lurkur

A free and open source Reddit reader.

## Try it

This app isn't intended to be published to any app stores. For that, check out Reddit's official apps.

[Apple](https://apps.apple.com/us/app/reddit/id1064216828)

[Google](https://play.google.com/store/apps/details?id=com.reddit.frontpage)

Instead, this app is meant to provide a lean viewing experience using the free tier of Reddit's public APIs.

### Building the app

Building the app is a simple process.
1. Configure your dev environment for Flutter
   1. You can follow the [flutter.dev](https://docs.flutter.dev/get-started/install) install instructions.
   2. (Note that you need MacOS to build the iOS app.)
2. Once installed, clone this Git repo onto your machine
3. Plug in your device
   1. For iOS, you may need to open xcode to ensure the app can be signed and installed on your device
4. Run the app using either
   1. `flutter run`
   2. IDE run of `main.dart`

This should get the app running on your device.
For the best experience, run it in Flutter's release mode.
1. `flutter run --release`

### Getting a client id

After building the app, you'll likely find that you can't sign in.
This is because you're missing a very important bit of information:
1. `client_id`

This value (along with the `redirect_uri`) is specific to Reddit's oauth system and are required to authorize your account with this app.
To actually make the app useful, you're going to need to make your own client id.
Below is a link to Reddit's OAuth2 startup instructions.
1. [Reddit's OAuth2 Guide](https://github.com/reddit-archive/reddit/wiki/OAuth2#refreshing-the-token)

Follow this OAuth2 "Getting Started" portion.
This will set up your Reddit account to being a "developer", granting you access to their OAuth APIs.
Make sure you set up the app as an "installed app".
(Your `redirect_uri` is assumed to be `https://www.reddit.com`)

Once you have a developer app created, make a new file in `lib/app/` called `secrets.dart`.
There, add this line of code: `const clientId = '';` and populate the empty string with your client id.

### Keeping the app on your device

#### Android

Building the `.apk` and installing it should be good enough.

(I don't own an Android device so your experience may vary.)

#### iOS

Apple likes to make things incredibly difficult.

Apple devices require a valid provisioning profile. The standard, unpaid Apple developer account only allows 7 days.
To get around this, you'll either have to pay Apple for a developer account, or deal with reinstalling the app every week.

For those that are choosing to reinstall the app every week, simply run:

`flutter run --release`

(You may need to open XCode go to Runner -> Singing & Capabilities and check "Automatically manage signing" and select a team.)

If you need to refresh your provisioning profile for any reason, you can delete the old one and generate a new one.
The old one can be found at `/Library/MobileDevice/Provisinoing Profiles`.

For example
`rm /Users/myusername/Library/MobileDevice/Provisioning\ Profiles/<some random hash>.mobileprovision`

## Contributing

This project isn't currently accepting changes to its main branch.
I mainly use this project as a way to experiment with Flutter.

Forking is welcome, though. If there's anything you'd personally like in a Reddit app,
feel free to fork this repo and implement it yourself.

If you think you have a particularly good idea, feel free to post an issue,
but just know that I'm unlikely to implement it.
