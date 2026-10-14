import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Whether this device is signed in (holds an API token).
class AuthSession extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await ref.watch(tokenStorageProvider).read() != null;

  /// Signs in; throws [AuthException] when the server refuses.
  Future<void> signIn({required String email, required String password}) async {
    await ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password);
    if (ref.mounted) state = const AsyncData(true);
  }

  /// Signs out this device; never fails.
  Future<void> signOut({String? pushToken}) async {
    await ref.read(authRepositoryProvider).signOut(pushToken: pushToken);
    if (ref.mounted) state = const AsyncData(false);
  }

  /// Re-reads the token storage (e.g. after a password reset revoked it).
  Future<void> refresh() async {
    final signedIn = await ref.read(tokenStorageProvider).read() != null;
    if (ref.mounted) state = AsyncData(signedIn);
  }
}
