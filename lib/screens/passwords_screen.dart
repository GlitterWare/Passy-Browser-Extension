import 'package:flutter/material.dart';

import '../common/common.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/password.dart';
import '../passy_data/passy_search.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'edit_password_screen.dart';
import 'common/entry_screen_args.dart';
import 'main_screen.dart';
import 'password_screen.dart';
import 'search_screen.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/passwords';

  @override
  State<StatefulWidget> createState() => _PasswordsScreen();
}

class _PasswordsScreen extends State<PasswordsScreen> {
  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPasswordScreen.routeName);

  Widget _buildPasswords(String terms) {
    List<PasswordMeta> passwords =
        ModalRoute.of(context)!.settings.arguments as List<PasswordMeta>;
    List<PasswordMeta> found =
        PassySearch.searchPasswords(passwords: passwords, terms: terms);
    if (found.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                const Spacer(flex: 7),
                Text(
                  localizations.noSearchResults,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 7),
              ],
            ),
          ),
        ],
      );
    }
    return PasswordButtonListView(
      passwords: found,
      onPressed: (passwordMeta) async {
        Password? password = await data.getPassword(passwordMeta.key);
        if (password == null) return;
        bool isFavorite =
            (await data.getFavoritePasswords())?[passwordMeta.key]?.status ==
                EntryStatus.alive;
        if (mounted) {
          Navigator.pushNamed(
            context,
            PasswordScreen.routeName,
            arguments: EntryScreenArgs(entry: password, isFavorite: isFavorite),
          );
        }
      },
      shouldSort: true,
      popupMenuItemBuilder: passwordPopupMenuBuilder,
    );
  }

  void _onSearchPressed() async {
    if (mounted) {
      Iterable<PasswordMeta>? passwords =
          (await data.getPasswordsMetadata())?.values;
      if (passwords == null) return;
      if (mounted) {
        Navigator.pushNamed(context, SearchScreen.routeName,
            arguments: SearchScreenArgs(builder: _buildPasswords));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<PasswordMeta> passwords =
        ModalRoute.of(context)!.settings.arguments as List<PasswordMeta>;
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.password,
          title: Center(child: Text(localizations.passwords)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: passwords.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noPasswords,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditPasswordScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : PasswordButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addPassword,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, EditPasswordScreen.routeName),
                  ),
                ),
              ],
              passwords: passwords.toList(),
              onPressed: (passwordMeta) async {
                Password? password = await data.getPassword(passwordMeta.key);
                if (password == null) return;
                bool isFavorite =
                    (await data.getFavoritePasswords())?[passwordMeta.key]
                            ?.status ==
                        EntryStatus.alive;
                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    PasswordScreen.routeName,
                    arguments: EntryScreenArgs(
                        entry: password, isFavorite: isFavorite),
                  );
                }
              },
              shouldSort: true,
              popupMenuItemBuilder: passwordPopupMenuBuilder,
            ),
    );
  }
}
