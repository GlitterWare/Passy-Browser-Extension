import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/identity.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'identity_screen.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'edit_identity_screen.dart';

class IdentitiesScreen extends StatefulWidget {
  const IdentitiesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/identities';

  @override
  State<StatefulWidget> createState() => _IdentitiesScreen();
}

class _IdentitiesScreen extends State<IdentitiesScreen> {
  List<String> _tags = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIdentityScreen.routeName).then((value) {
        if (_isLoading) return;
        _load().then((value) => _isLoading = false);
      });

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
            entryType: EntryType.identity,
            selectedTags: tag == null ? [] : [tag],
            builder:
                (String terms, List<String> tags, void Function() rebuild) {
              final List<IdentityMeta> found = [];
              final List<String> termsList =
                  terms.trim().toLowerCase().split(' ');
              final List<IdentityMeta> identities = ModalRoute.of(context)!
                  .settings
                  .arguments as List<IdentityMeta>;
              for (IdentityMeta identity in identities) {
                {
                  bool testIdentity(IdentityMeta value) =>
                      identity.key == value.key;

                  if (found.any(testIdentity)) continue;
                }
                {
                  bool tagMismatch = false;
                  for (String tag in tags) {
                    if (!identity.tags.contains(tag)) {
                      tagMismatch = true;
                      break;
                    }
                  }
                  if (tagMismatch) continue;
                  int positiveCount = 0;
                  for (String term in termsList) {
                    if (identity.firstAddressLine
                        .toLowerCase()
                        .contains(term)) {
                      positiveCount++;
                      continue;
                    }
                    if (identity.nickname.toLowerCase().contains(term)) {
                      positiveCount++;
                      continue;
                    }
                  }
                  if (positiveCount == termsList.length) {
                    found.add(identity);
                  }
                }
              }
              if (found.isEmpty) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
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
              return IdentityButtonListView(
                identities: found,
                shouldSort: true,
                onPressed: (identityMeta) async {
                  Identity? identity = await data.getIdentity(identityMeta.key);
                  if (identity == null) return;
                  bool isFavorite =
                      (await data.getFavoriteIDCards())?[identity.key]
                              ?.status ==
                          EntryStatus.alive;
                  if (!mounted) return;
                  Navigator.pushNamed(
                    context,
                    IdentityScreen.routeName,
                    arguments: EntryScreenArgs(
                        entry: identity, isFavorite: isFavorite),
                  );
                },
                popupMenuItemBuilder: identityPopupMenuBuilder,
              );
            }));
  }

  Future<void> _load() async {
    _isLoaded = true;
    _isLoading = true;
    List<String> newTags;
    try {
      newTags = await data.identitiesTags;
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
    List<IdentityMeta> identities =
        ModalRoute.of(context)!.settings.arguments as List<IdentityMeta>;
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.identity,
          title: Center(child: Text(localizations.identities)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: identities.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noIdentities,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          onPressed: _onAddPressed,
                          child: const Icon(Icons.add_rounded)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : IdentityButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addIdentity,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: _onAddPressed,
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
              identities: identities,
              shouldSort: true,
              onPressed: (identityMeta) async {
                Identity? identity = await data.getIdentity(identityMeta.key);
                if (identity == null) return;
                bool isFavorite =
                    (await data.getFavoriteIdentities())?[identityMeta.key]
                            ?.status ==
                        EntryStatus.alive;
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    IdentityScreen.routeName,
                    arguments: EntryScreenArgs(
                        entry: identity, isFavorite: isFavorite),
                  ).then((value) {
                    if (_isLoading) return;
                    _load().then((value) => _isLoading = false);
                  });
                }
              },
              popupMenuItemBuilder: identityPopupMenuBuilder,
            ),
    );
  }
}
