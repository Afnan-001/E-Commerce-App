import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:shop/firebase_options.dart';

class FirebaseBootstrap {
  static Future<bool> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        'Firebase is not configured yet. Run `flutterfire configure` and add '
        'the generated firebase_options.dart file before enabling auth/data.',
      );
      return false;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    return true;
  }
}
