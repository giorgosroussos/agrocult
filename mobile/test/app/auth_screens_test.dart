import 'dart:async';

import 'package:agrocult/app/app.dart';
import 'package:agrocult/app/auth/reset_password_screen.dart';
import 'package:agrocult/app/auth/sign_in_screen.dart';
import 'package:agrocult/app/auth/verify_email_screen.dart';
import 'package:agrocult/app/router.dart';
import 'package:agrocult/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/fake_identity_server.dart';
import '../core/fakes.dart';

late FakeIdentityServer server;
late InMemoryTokenStorage tokens;

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokens),
        deviceIdStorageProvider.overrideWithValue(const FixedDeviceIdStorage()),
        apiClientProvider.overrideWithValue(fakeApiClient(server, tokens)),
      ],
      child: const AgrocultApp(locale: Locale('en')),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester, String route, {Object? args}) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  unawaited(navigator.pushNamed(route, arguments: args));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String text) =>
    tester.enterText(find.byKey(Key(key)), text);

Future<void> _signUp(WidgetTester tester, String email) async {
  await _open(tester, AppRoutes.signUp);
  await _enter(tester, 'signUp.email', email);
  await _enter(tester, 'signUp.password', 'secret-123');
  await _tap(tester, 'signUp.age');
  await _tap(tester, 'signUp.submit');
}

Future<void> _signIn(WidgetTester tester, String email, String password) async {
  await _open(tester, AppRoutes.signIn);
  await _enter(tester, 'signIn.email', email);
  await _enter(tester, 'signIn.password', password);
  await _tap(tester, 'signIn.submit');
}

String _fieldText(WidgetTester tester, String key) => tester
    .widget<TextField>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(TextField),
      ),
    )
    .controller!
    .text;

String _textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  setUp(() {
    server = FakeIdentityServer();
    tokens = InMemoryTokenStorage();
  });

  group('sign-up', () {
    testWidgets('a new visitor sees the verify email notice', (tester) async {
      await _pumpApp(tester);

      await _signUp(tester, 'ana@example.test');

      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(find.textContaining('ana@example.test'), findsOneWidget);
      expect(server.accounts.keys, ['ana@example.test']);
      expect(
        server.requestsTo('auth/sign-up').single.data,
        containsPair('language', 'en'),
      );
    });

    testWidgets(
      'Given an email that is already registered, When a visitor signs up '
      'with it, Then no second account is created',
      (tester) async {
        server.addAccount('ana@example.test', 'old-password');
        await _pumpApp(tester);

        await _signUp(tester, 'ana@example.test');

        expect(server.accounts, hasLength(1));
        expect(server.accounts['ana@example.test']!.password, 'old-password');
        // Same notice as a new account, offering sign-in and password reset.
        expect(find.byType(VerifyEmailScreen), findsOneWidget);
        expect(
          find.text(
            'Already have an account with this email? Sign in, or reset your '
            'password if you have forgotten it.',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('verifyEmail.signIn')), findsOneWidget);
        await _tap(tester, 'verifyEmail.forgotPassword');
        expect(_fieldText(tester, 'forgotPassword.email'), 'ana@example.test');
      },
    );

    testWidgets('without the age confirmation nothing is sent', (tester) async {
      await _pumpApp(tester);
      await _open(tester, AppRoutes.signUp);

      await _enter(tester, 'signUp.email', 'ana@example.test');
      await _enter(tester, 'signUp.password', 'secret-123');
      await _tap(tester, 'signUp.submit');

      expect(
        find.text('You must be at least 15 years old to create an account.'),
        findsOneWidget,
      );
      expect(server.requests, isEmpty);
      expect(find.byType(VerifyEmailScreen), findsNothing);
    });

    testWidgets('an invalid email or short password is not sent', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _open(tester, AppRoutes.signUp);

      await _enter(tester, 'signUp.email', 'not-an-email');
      await _enter(tester, 'signUp.password', 'short');
      await _tap(tester, 'signUp.age');
      await _tap(tester, 'signUp.submit');

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(server.requests, isEmpty);
    });

    testWidgets('the notice can request a new confirmation link', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _open(tester, AppRoutes.verifyEmail, args: 'ana@example.test');

      await _tap(tester, 'verifyEmail.resend');

      expect(
        server.requestsTo('auth/email/verification-notification').single.data,
        {'email': 'ana@example.test'},
      );
      expect(find.byKey(const Key('verifyEmail.resent')), findsOneWidget);
    });
  });

  group('sign-in', () {
    testWidgets('signs in, stores the token and returns to the start', (
      tester,
    ) async {
      server.addAccount('ana@example.test', 'secret-123');
      await _pumpApp(tester);

      await _signIn(tester, 'ana@example.test', 'secret-123');

      expect(tokens.token, server.tokens['device-1']);
      expect(find.byType(SignInScreen), findsNothing);
      expect(find.byKey(const Key('start.signOut')), findsOneWidget);
    });

    testWidgets(
      'Given a wrong password, Then the error message is the same as for an '
      'unknown email',
      (tester) async {
        server.addAccount('ana@example.test', 'secret-123');
        await _pumpApp(tester);

        await _signIn(tester, 'ana@example.test', 'wrong-password');
        final wrongPassword = _textOf(tester, 'auth.error');

        await _signIn(tester, 'nobody@example.test', 'wrong-password');
        final unknownEmail = _textOf(tester, 'auth.error');

        expect(wrongPassword, 'The email or password is not correct.');
        expect(unknownEmail, wrongPassword);
        expect(tokens.token, isNull);
        // The rejected password is not kept on screen.
        expect(_fieldText(tester, 'signIn.password'), isEmpty);
      },
    );

    testWidgets('an unconfirmed email leads to the verify notice', (
      tester,
    ) async {
      server.addAccount('ana@example.test', 'secret-123', verified: false);
      await _pumpApp(tester);

      await _signIn(tester, 'ana@example.test', 'secret-123');

      expect(
        _textOf(tester, 'auth.error'),
        'Confirm your email address before signing in.',
      );
      expect(tokens.token, isNull);
      await _tap(tester, 'signIn.verify');
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
    });

    testWidgets('shows a network error when the server is unreachable', (
      tester,
    ) async {
      server.offline = true;
      await _pumpApp(tester);

      await _signIn(tester, 'ana@example.test', 'secret-123');

      expect(
        _textOf(tester, 'auth.error'),
        'Could not reach the server. Check your connection and try again.',
      );
    });
  });

  group('sign-out', () {
    testWidgets('revokes the device token and offers sign-in again', (
      tester,
    ) async {
      server.addAccount('ana@example.test', 'secret-123');
      await _pumpApp(tester);
      await _signIn(tester, 'ana@example.test', 'secret-123');

      await _tap(tester, 'start.signOut');

      expect(tokens.token, isNull);
      expect(server.tokens, isEmpty);
      expect(find.byKey(const Key('start.signIn')), findsOneWidget);
      expect(find.text('You have signed out.'), findsOneWidget);
    });
  });

  group('password reset', () {
    Future<String> requestReset(WidgetTester tester, String email) async {
      await _open(tester, AppRoutes.forgotPassword);
      await _enter(tester, 'forgotPassword.email', email);
      await _tap(tester, 'forgotPassword.submit');
      return _textOf(tester, 'forgotPassword.sent');
    }

    testWidgets(
      'Given an unknown email, When a reset is requested, Then the response '
      'is the same as for a known email',
      (tester) async {
        server.addAccount('ana@example.test', 'secret-123');
        await _pumpApp(tester);

        final known = await requestReset(tester, 'ana@example.test');
        await _tap(tester, 'forgotPassword.backToSignIn');
        final unknown = await requestReset(tester, 'nobody@example.test');

        expect(unknown, known);
        expect(server.requestsTo('auth/password/forgot'), hasLength(2));
        expect(server.sentResetTokens, hasLength(1));
      },
    );

    testWidgets('the link sets a new password and asks to sign in again', (
      tester,
    ) async {
      server.addAccount('ana@example.test', 'secret-123');
      tokens.token = 'token-old';
      await _pumpApp(tester);
      await requestReset(tester, 'ana@example.test');
      final link = server.sentResetTokens.single;

      await _open(
        tester,
        '/reset-password?token=$link&email=ana%40example.test',
      );
      await _enter(tester, 'resetPassword.password', 'brand-new-1');
      await _enter(tester, 'resetPassword.repeat', 'brand-new-1');
      await _tap(tester, 'resetPassword.submit');

      expect(server.accounts['ana@example.test']!.password, 'brand-new-1');
      expect(tokens.token, isNull);
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(
        _textOf(tester, 'signIn.notice'),
        'Your password has been changed. Sign in again on your devices.',
      );
    });

    testWidgets(
      'Given a reset link already used once, When it is opened again, Then '
      'it is rejected',
      (tester) async {
        server.addAccount('ana@example.test', 'secret-123');
        await _pumpApp(tester);
        await requestReset(tester, 'ana@example.test');
        final link =
            '/reset-password?token=${server.sentResetTokens.single}'
            '&email=ana%40example.test';

        Future<void> useLink(String password) async {
          await _open(tester, link);
          await _enter(tester, 'resetPassword.password', password);
          await _enter(tester, 'resetPassword.repeat', password);
          await _tap(tester, 'resetPassword.submit');
        }

        await useLink('brand-new-1');
        expect(find.byType(SignInScreen), findsOneWidget);

        await useLink('another-new-2');

        expect(find.byType(ResetPasswordScreen), findsOneWidget);
        expect(
          _textOf(tester, 'auth.error'),
          'This reset link is not valid or has already been used.',
        );
        expect(server.accounts['ana@example.test']!.password, 'brand-new-1');
        await _tap(tester, 'resetPassword.requestNew');
        expect(find.byKey(const Key('forgotPassword.email')), findsOneWidget);
      },
    );

    testWidgets('a link without token is rejected without a request', (
      tester,
    ) async {
      await _pumpApp(tester);

      await _open(tester, '/reset-password?email=ana%40example.test');

      expect(
        _textOf(tester, 'auth.error'),
        'This reset link is not valid or has already been used.',
      );
      expect(find.byKey(const Key('resetPassword.submit')), findsNothing);
      expect(server.requests, isEmpty);
    });

    testWidgets('differing new passwords are not sent', (tester) async {
      await _pumpApp(tester);
      await _open(tester, '/reset-password?token=t&email=a%40example.test');

      await _enter(tester, 'resetPassword.password', 'brand-new-1');
      await _enter(tester, 'resetPassword.repeat', 'brand-new-2');
      await _tap(tester, 'resetPassword.submit');

      expect(find.text('The passwords do not match.'), findsOneWidget);
      expect(server.requests, isEmpty);
    });
  });

  group('reset link routing', () {
    test('recognises the forms the platforms hand the link over in', () {
      for (final name in [
        '/reset-password?token=t1&email=a%40b.test',
        'agrocult://reset-password?token=t1&email=a%40b.test',
        '/?token=t1&email=a%40b.test',
      ]) {
        final link = AppRouter.resetLinkFrom(name);
        expect(link?.queryParameters['token'], 't1', reason: name);
        expect(link?.queryParameters['email'], 'a@b.test', reason: name);
      }
    });

    test('other routes are not reset links', () {
      expect(AppRouter.resetLinkFrom('/'), isNull);
      expect(AppRouter.resetLinkFrom('/sign-in'), isNull);
      expect(AppRouter.resetLinkFrom('/?token=t1'), isNull);
    });

    testWidgets('the verify notice needs the email address', (tester) async {
      await _pumpApp(tester);

      await _open(tester, AppRoutes.verifyEmail);

      expect(find.byType(NotFoundScreen), findsOneWidget);
    });

    testWidgets('a signed-out device is offered sign-in and sign-up', (
      tester,
    ) async {
      await _pumpApp(tester);

      expect(find.byKey(const Key('start.signIn')), findsOneWidget);
      expect(find.byKey(const Key('start.signUp')), findsOneWidget);
      expect(find.byKey(const Key('start.signOut')), findsNothing);
    });
  });
}
