import 'package:agrocult/core/auth/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_identity_server.dart';
import 'fakes.dart';

void main() {
  late FakeIdentityServer server;
  late InMemoryTokenStorage tokens;
  late AuthRepository repo;

  setUp(() {
    server = FakeIdentityServer();
    tokens = InMemoryTokenStorage();
    repo = AuthRepository(
      api: fakeApiClient(server, tokens),
      tokenStorage: tokens,
      deviceIdStorage: const FixedDeviceIdStorage('device-42'),
    );
  });

  Matcher failsWith(AuthError error) =>
      throwsA(isA<AuthException>().having((e) => e.error, 'error', error));

  group('sign-up (UC-012)', () {
    test('sends email, password, age confirmation and language', () async {
      await repo.signUp(
        email: ' ana@example.test ',
        password: 'secret-123',
        ageConfirmed: true,
        language: 'el',
      );

      expect(server.requestsTo('auth/sign-up').single.data, {
        'email': 'ana@example.test',
        'password': 'secret-123',
        'age_confirmed': true,
        'language': 'el',
      });
    });

    test('is refused without the age confirmation, nothing is sent', () async {
      await expectLater(
        repo.signUp(
          email: 'ana@example.test',
          password: 'secret-123',
          ageConfirmed: false,
          language: 'en',
        ),
        failsWith(AuthError.invalidInput),
      );
      expect(server.requests, isEmpty);
      expect(server.accounts, isEmpty);
    });

    test('Given an email that is already registered, When a visitor signs up '
        'with it, Then no second account is created', () async {
      server.addAccount('ana@example.test', 'old-password');

      await repo.signUp(
        email: 'ana@example.test',
        password: 'new-password',
        ageConfirmed: true,
        language: 'en',
      );

      expect(server.accounts.keys, ['ana@example.test']);
      expect(server.accounts['ana@example.test']!.password, 'old-password');
      // Completes like a fresh sign-up: nothing reveals the account.
      expect(server.requestsTo('auth/sign-up'), hasLength(1));
    });
  });

  group('sign-in (UC-012)', () {
    test('stores the token issued for this device id', () async {
      server.addAccount('ana@example.test', 'secret-123');

      await repo.signIn(email: 'ana@example.test', password: 'secret-123');

      expect(
        server.requestsTo('auth/sign-in').single.data,
        containsPair('device_id', 'device-42'),
      );
      expect(tokens.token, server.tokens['device-42']);
    });

    test('Given a wrong password, Then the error is the same as for an unknown '
        'email', () async {
      server.addAccount('ana@example.test', 'secret-123');

      AuthException? wrongPassword;
      AuthException? unknownEmail;
      try {
        await repo.signIn(email: 'ana@example.test', password: 'wrong-pass');
      } on AuthException catch (e) {
        wrongPassword = e;
      }
      try {
        await repo.signIn(email: 'bob@example.test', password: 'wrong-pass');
      } on AuthException catch (e) {
        unknownEmail = e;
      }

      expect(wrongPassword?.error, AuthError.invalidCredentials);
      expect(unknownEmail?.error, wrongPassword?.error);
      expect(unknownEmail?.fields, wrongPassword?.fields);
      expect(tokens.token, isNull);
    });

    test('reports an unconfirmed email', () async {
      server.addAccount('ana@example.test', 'secret-123', verified: false);

      await expectLater(
        repo.signIn(email: 'ana@example.test', password: 'secret-123'),
        failsWith(AuthError.emailNotVerified),
      );
      expect(tokens.token, isNull);
    });

    test('reports rate limiting and network failures', () async {
      server.rateLimited = true;
      await expectLater(
        repo.signIn(email: 'a@example.test', password: 'x'),
        failsWith(AuthError.rateLimited),
      );

      server
        ..rateLimited = false
        ..offline = true;
      await expectLater(
        repo.signIn(email: 'a@example.test', password: 'x'),
        failsWith(AuthError.network),
      );
    });
  });

  group('sign-out', () {
    test('revokes the token on the server and forgets it', () async {
      server.addAccount('ana@example.test', 'secret-123');
      await repo.signIn(email: 'ana@example.test', password: 'secret-123');

      await repo.signOut(pushToken: 'fcm-1');

      expect(server.tokens, isEmpty);
      expect(tokens.token, isNull);
      expect(server.requestsTo('auth/sign-out').single.data, {
        'push_token': 'fcm-1',
      });
    });

    test('forgets the token even when the server is unreachable', () async {
      tokens.token = 'token-1';
      server.offline = true;

      await repo.signOut();

      expect(tokens.token, isNull);
    });
  });

  group('password reset (UC-013)', () {
    test('Given an unknown email, When a reset is requested, Then the response '
        'is the same as for a known email', () async {
      server.addAccount('ana@example.test', 'secret-123');

      await repo.requestPasswordReset('ana@example.test');
      await repo.requestPasswordReset('nobody@example.test');

      final answers = server.requestsTo('auth/password/forgot');
      expect(answers, hasLength(2));
      // Only the known account received a link; the app saw no difference.
      expect(server.sentResetTokens, hasLength(1));
    });

    test('sets the new password and signs this device out', () async {
      server.addAccount('ana@example.test', 'secret-123');
      tokens.token = 'token-old';
      await repo.requestPasswordReset('ana@example.test');

      await repo.resetPassword(
        token: server.sentResetTokens.single,
        email: 'ana@example.test',
        password: 'brand-new-1',
      );

      expect(server.accounts['ana@example.test']!.password, 'brand-new-1');
      expect(tokens.token, isNull);
    });

    test('Given a reset link already used once, When it is opened again, Then '
        'it is rejected', () async {
      server.addAccount('ana@example.test', 'secret-123');
      await repo.requestPasswordReset('ana@example.test');
      final link = server.sentResetTokens.single;
      await repo.resetPassword(
        token: link,
        email: 'ana@example.test',
        password: 'brand-new-1',
      );

      await expectLater(
        repo.resetPassword(
          token: link,
          email: 'ana@example.test',
          password: 'another-new-2',
        ),
        failsWith(AuthError.invalidResetLink),
      );
      expect(server.accounts['ana@example.test']!.password, 'brand-new-1');
    });

    test('a too short password is an input error, not a bad link', () async {
      await expectLater(
        repo.resetPassword(
          token: 'reset-1',
          email: 'ana@example.test',
          password: 'short',
        ),
        failsWith(AuthError.invalidInput),
      );
    });
  });

  test('error string form carries no user data', () {
    const e = AuthException(AuthError.invalidCredentials, fields: {'email'});
    expect(e.toString(), 'AuthException(invalidCredentials)');
  });
}
