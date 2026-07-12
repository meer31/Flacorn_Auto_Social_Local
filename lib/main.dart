import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TODO: when running against the Firebase Local Emulator Suite during
  // development, connect each SDK to its emulator here, e.g.:
  //   FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //   FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  //   FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  // Gate this behind a --dart-define=USE_EMULATOR=true flag so production
  // builds never accidentally point at localhost.

  runApp(const ProviderScope(child: FlacronSocialAutoApp()));
}
