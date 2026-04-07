import 'package:firebase_core/firebase_core.dart';

import 'package:shop/firebase_options.dart';

class FirebaseRuntime {
  static bool get isInitialized => Firebase.apps.isNotEmpty;

  static bool get canUseDefaultOptions {
    try {
      DefaultFirebaseOptions.currentPlatform;
      return true;
    } on UnsupportedError {
      return false;
    }
  }
}
