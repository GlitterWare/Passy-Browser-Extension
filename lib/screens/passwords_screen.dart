import 'package:flutter/foundation.dart';
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
  List<String> _tags = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPasswordScreen.routeName);

  Widget _buildPasswords(
    String terms,
    List<String> tags,
    void Function() rebuild,
  ) {
    List<PasswordMeta> passwords =
        ModalRoute.of(context)!.settings.arguments as List<PasswordMeta>;
    List<PasswordMeta> found = PassySearch.searchPasswords(
        passwords: passwords, terms: terms, tags: tags);
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

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
            builder: _buildPasswords,
            entryType: EntryType.password,
            selectedTags: tag == null ? [] : [tag]));
  }

  Future<void> _load() async {
    _isLoaded = true;
    _isLoading = true;
    List<String> newTags;
    try {
      newTags = await data.passwordsTags;
    } catch (_) {
      return;
    }
    newTags.sort();
    if (listEquals(newTags, _tags)) {
      return;
    }
    if (mounted) {
      setState(() {
        _tags = newTags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) _load().whenComplete(() => _isLoading = false);
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
                if (_tags.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: PassyTheme.passyPadding.top / 2,
                          bottom: PassyTheme.passyPadding.bottom / 2),
                      child: EntryTagList(
                        notSelected: _tags,
                        onAdded: (tag) => setState(() {
                          _onSearchPressed(tag: tag);
                        }),
                      ),
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
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    PasswordScreen.routeName,
                    arguments: EntryScreenArgs(
                        entry: password, isFavorite: isFavorite),
                  ).then((value) {
                    if (_isLoading) return;
                    _load().then((value) => _isLoading = false);
                  });
                }
              },
              shouldSort: true,
              popupMenuItemBuilder: passwordPopupMenuBuilder,
            ),
    );
  }
}
