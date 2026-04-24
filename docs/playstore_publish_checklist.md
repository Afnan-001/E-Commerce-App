# PetsWorld Play Store Checklist

## Before uploading

1. Keep or change the Android package name deliberately.
2. The current Firebase Android config uses `com.example.shop`.
3. If you change the package name, regenerate Firebase config with `flutterfire configure` and replace `android/app/google-services.json`.
4. Update the app version in `pubspec.yaml` before each release.

## Release signing

1. Create a release keystore.
2. Add `android/key.properties` with:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

3. Place the keystore file at the path referenced by `storeFile`.
4. Build an app bundle with `flutter build appbundle --release`.

## Store compliance

1. Keep the in-app Delete account option available from Profile.
2. Add a public Privacy Policy URL in Play Console.
3. Complete the Data safety form based on Firebase Auth, Firestore, Google Sign-In, payments, and any analytics/crash tools you add later.
4. Make sure your support email is active and visible in Play Console.
5. Review all screenshots, app icon, feature graphic, and app description.

## Final checks

1. Run `flutter analyze`.
2. Run `flutter test`.
3. Test login, logout, delete account, checkout, order history, and Google Sign-In on a release build.
4. Upload the generated `.aab` to an internal testing track first.
