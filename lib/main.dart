import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:passy_browser_extension/screens/note_screen.dart';
import 'package:passy_browser_extension/screens/notes_screen.dart';
import 'package:passy_browser_extension/screens/payment_card_screen.dart';
import 'package:passy_browser_extension/screens/payment_cards_screen.dart';

import 'passy_flutter/passy_flutter.dart';
import 'screens/edit_custom_field_screen.dart';
import 'screens/edit_id_card_screen.dart';
import 'screens/edit_identity_screen.dart';
import 'screens/edit_note_screen.dart';
import 'screens/edit_password_screen.dart';
import 'screens/edit_payment_card_screen.dart';
import 'screens/id_card_screen.dart';
import 'screens/id_cards_screen.dart';
import 'screens/identities_screen.dart';
import 'screens/identity_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/no_connector_screen.dart';
import 'screens/password_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/passwords_screen.dart';

void main() {
  runApp(const MyApp());
}

final ThemeData theme = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: PassyTheme.theme.colorScheme,
  snackBarTheme: PassyTheme.theme.snackBarTheme,
  scaffoldBackgroundColor: PassyTheme.theme.scaffoldBackgroundColor,
  inputDecorationTheme: PassyTheme.theme.inputDecorationTheme,
  elevatedButtonTheme: PassyTheme.theme.elevatedButtonTheme,
  textSelectionTheme: PassyTheme.theme.textSelectionTheme,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        EditCustomFieldScreen.routeName: (context) =>
            const EditCustomFieldScreen(),
        EditIDCardScreen.routeName: (context) => const EditIDCardScreen(),
        EditIdentityScreen.routeName: (context) => const EditIdentityScreen(),
        EditNoteScreen.routeName: (context) => const EditNoteScreen(),
        EditPasswordScreen.routeName: (context) => const EditPasswordScreen(),
        EditPaymentCardScreen.routeName: (context) =>
            const EditPaymentCardScreen(),
        IDCardScreen.routeName: (context) => const IDCardScreen(),
        IDCardsScreen.routeName: (context) => const IDCardsScreen(),
        IdentitiesScreen.routeName: (context) => const IdentitiesScreen(),
        IdentityScreen.routeName: (context) => const IdentityScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        NoConnectorScreen.routeName: (context) => const NoConnectorScreen(),
        NoteScreen.routeName: (context) => const NoteScreen(),
        NotesScreen.routeName: (context) => const NotesScreen(),
        PasswordScreen.routeName: (context) => const PasswordScreen(),
        PasswordsScreen.routeName: (context) => const PasswordsScreen(),
        PaymentCardScreen.routeName: (context) => const PaymentCardScreen(),
        PaymentCardsScreen.routeName: (context) => const PaymentCardsScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        SplashScreen.routeName: (context) => const SplashScreen(),
      },
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
    );
  }
}

const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('it'),
  Locale('ru'),
];
