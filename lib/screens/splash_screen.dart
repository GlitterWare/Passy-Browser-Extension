// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passy_browser_extension/common/assets.dart';
import 'package:passy_browser_extension/common/browser_extension_data.dart';
import 'package:passy_browser_extension/common/js_interop.dart';
import 'package:passy_browser_extension/passy_browser_extension_flutter/passy_browser_extensions_flutter.dart';
import 'package:passy_browser_extension/screens/login_screen.dart';

import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'no_connector_screen.dart';
import '../common/common.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  static bool _isloaded = false;

  @override
  Widget build(BuildContext context) {
    Future<void> load() async {
      if (!(await JsInterop.getIsConnectorFound())) {
        if (mounted) Navigator.pushNamed(context, NoConnectorScreen.routeName);
        while (!(await JsInterop.getIsConnectorFound())) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (mounted) Navigator.pop(context);
      }
      BrowserExtensionData? extensionData = await BrowserExtensionData.load();
      if (extensionData == null) {
        if (mounted) {
          showSnackBar(
            context,
            message: localizations.failedToLoad,
            icon: const Icon(Symbols.person_rounded,
                weight: 700, color: PassyTheme.darkContentColor),
          );
        }
        return;
      }
      data = extensionData;
      if (mounted) Navigator.pushNamed(context, LoginScreen.routeName);
    }

    if (!_isloaded) {
      _isloaded = true;
      loadLocalizations(context);
      load();
    }
    return Scaffold(
      appBar: const BrowserExtensionAppbar(),
      body: Center(
        child: logo60Purple,
      ),
    );
  }
}
