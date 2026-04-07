import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static bool get isConfigured => false;

  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured yet. Run `flutterfire configure` and replace '
      '`lib/firebase_options.dart` with the generated file.',
    );
  }
}
