// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passy_browser_extension/common/assets.dart';
import 'package:passy_browser_extension/common/browser_extension_data.dart';
import 'package:passy_browser_extension/common/js_interop.dart';
import 'package:passy_browser_extension/passy_browser_extension_flutter/passy_browser_extensions_flutter.dart';
import 'package:passy_browser_extension/screens/login_screen.dart';
import 'package:passy_browser_extension/screens/main_screen.dart';

import '../passy_data/entry_event.dart';
import '../passy_data/entry_meta.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/id_card.dart';
import '../passy_data/identity.dart';
import '../passy_data/note.dart';
import '../passy_data/password.dart';
import '../passy_data/passy_entry.dart';
import '../passy_data/payment_card.dart';
import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'common/entry_screen_args.dart';
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
        if (context.mounted) {
          Navigator.pushNamed(context, NoConnectorScreen.routeName);
        }
        while (!(await JsInterop.getIsConnectorFound())) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (context.mounted) Navigator.pop(context);
      }
      BrowserExtensionData? extensionData = await BrowserExtensionData.load();
      if (extensionData == null) {
        if (mounted) {
          showSnackBar(
            message: localizations.failedToLoad,
            icon: const Icon(Symbols.person_rounded,
                weight: 700, color: PassyTheme.darkContentColor),
          );
        }
        return;
      }
      data = extensionData;
      if (data.isLoggedIn) {
      CurrentEntry? currentEntry = data.currentEntry;
      if (currentEntry != null) {
        dynamic entries = (await data.getEntriesMetadata(currentEntry.type))
                ?.values
                .toList() ??
            <EntryMeta>[];
        switch (currentEntry.type) {
          case EntryType.password:
            entries = List<PasswordMeta>.from(entries);
            break;
          case EntryType.paymentCard:
            entries = List<PaymentCardMeta>.from(entries);
            break;
          case EntryType.note:
            entries = List<NoteMeta>.from(entries);
            break;
          case EntryType.idCard:
            entries = List<IDCardMeta>.from(entries);
            break;
          case EntryType.identity:
            entries = List<IdentityMeta>.from(entries);
            break;
        }
        PassyEntry? entry =
            await data.getEntry(currentEntry.type, key: currentEntry.key);
        bool isFavorite = (await data
                    .getFavoriteEntries(currentEntry.type))?[currentEntry.key]
                ?.status ==
            EntryStatus.alive;
        if (entry == null) {
          data.setCurrentEntry(null);
          return;
        }
        if (!context.mounted) return;
        Navigator.pushNamed(context, MainScreen.routeName);
        Navigator.pushNamed(
            context, entryTypeToEntriesScreenName(currentEntry.type),
            arguments: entries);
        Navigator.pushNamed(
            context, entryTypeToEntryScreenName(currentEntry.type),
            arguments: EntryScreenArgs(entry: entry, isFavorite: isFavorite));
        return;
      }
      }
      if (context.mounted) Navigator.pushNamed(context, LoginScreen.routeName);
    }

    if (!_isloaded) {
      _isloaded = true;
      loadLocalizations(context);
      load();
    }
    return Scaffold(
      floatingActionButton: const WebEmojiLoaderHack(),
      appBar: const BrowserExtensionAppbar(),
      body: Center(
        child: logo60Purple,
      ),
    );
  }
}
