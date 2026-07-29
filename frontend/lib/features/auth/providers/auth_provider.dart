import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';

/// Streams Firebase Auth state changes — the single source of truth for
/// whether the user is signed in, consumed by [appRouterProvider] for
/// redirect logic and by any widget that needs the current uid.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseService.instance.auth.authStateChanges();
});

/// Auth actions (sign in, register, sign out, password reset) exposed as a
/// notifier so screens can await results and surface loading/error state
/// without duplicating FirebaseAuth error-handling logic everywhere.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  final FirebaseAuth _auth = FirebaseService.instance.auth;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> register({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _auth.createUserWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _auth.sendPasswordResetEmail(email: email));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(),
);
