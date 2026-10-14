import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/reset_password_screen.dart';
import 'auth/sign_in_screen.dart';
import 'auth/sign_up_screen.dart';
import 'auth/verify_email_screen.dart';
import 'routes.dart';
import 'start_screen.dart';

export 'routes.dart';

/// The screens of one feature: a builder for each route name the feature
/// handles, null for any other route. CMP-AppCore never imports a feature,
/// so features hand their routes to the app where it is composed (main.dart).
typedef FeatureRoutes = WidgetBuilder? Function(RouteSettings settings);

/// Maps route names to screens (Navigator 2.0 is not needed yet). The app
/// shell's own routes are here; features add theirs as [FeatureRoutes].
abstract final class AppRouter {
  static const initialRoute = AppRoutes.start;

  static Route<Object?> onGenerateRoute(
    RouteSettings settings, {
    List<FeatureRoutes> features = const [],
  }) {
    final builder =
        _builderFor(settings) ??
        _featureBuilderFor(settings, features) ??
        (_) => const NotFoundScreen();
    return MaterialPageRoute<Object?>(builder: builder, settings: settings);
  }

  static WidgetBuilder? _featureBuilderFor(
    RouteSettings settings,
    List<FeatureRoutes> features,
  ) {
    for (final routes in features) {
      final builder = routes(settings);
      if (builder != null) return builder;
    }
    return null;
  }

  static WidgetBuilder? _builderFor(RouteSettings settings) {
    final name = settings.name ?? '';
    final args = settings.arguments;
    final text = args is String ? args : null;
    switch (name) {
      case AppRoutes.start:
        return (_) => const StartScreen();
      case AppRoutes.signUp:
        return (_) => const SignUpScreen();
      case AppRoutes.signIn:
        return (_) => SignInScreen(notice: text);
      case AppRoutes.verifyEmail:
        return text == null ? null : (_) => VerifyEmailScreen(email: text);
      case AppRoutes.forgotPassword:
        return (_) => ForgotPasswordScreen(initialEmail: text);
    }
    final reset = resetLinkFrom(name);
    if (reset != null) {
      return (_) => ResetPasswordScreen(
        token: reset.queryParameters['token'],
        email: reset.queryParameters['email'],
      );
    }
    return null;
  }

  /// Recognises the password reset link (UC-013) in the forms the platforms
  /// hand it over: `/reset-password?...`, the full `agrocult://reset-password?...`
  /// link, or `/?token=...&email=...` when the link's host was dropped.
  static Uri? resetLinkFrom(String name) {
    final uri = Uri.tryParse(name);
    if (uri == null) return null;
    final isResetPath = uri.path == AppRoutes.resetPassword;
    final isResetHost = uri.host == 'reset-password';
    final isBareLink =
        (uri.path.isEmpty || uri.path == '/') &&
        uri.queryParameters.containsKey('token') &&
        uri.queryParameters.containsKey('email');
    return (isResetPath || isResetHost || isBareLink) ? uri : null;
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(child: Text(l10n.pageNotFound)),
    );
  }
}
