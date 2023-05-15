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
  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIdentityScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(builder: (String terms) {
      List<IdentityMeta> identitiesMetadata =
          ModalRoute.of(context)!.settings.arguments as List<IdentityMeta>;
      final List<IdentityMeta> found = [];
      final List<String> termsSplit = terms.trim().toLowerCase().split(' ');
      for (IdentityMeta identity in identitiesMetadata) {
        {
          bool testIdentity(IdentityMeta value) => identity.key == value.key;

          if (found.any(testIdentity)) continue;
        }
        {
          int positiveCount = 0;
          for (String term in termsSplit) {
            if (identity.firstAddressLine.toLowerCase().contains(term)) {
              positiveCount++;
              continue;
            }
            if (identity.nickname.toLowerCase().contains(term)) {
              positiveCount++;
              continue;
            }
          }
          if (positiveCount == termsSplit.length) {
            found.add(identity);
          }
        }
      }
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
      return IdentityButtonListView(
        identities: found,
        shouldSort: true,
        onPressed: (identityMeta) async {
          Identity? identity = await data.getIdentity(identityMeta.key);
          if (identity == null) return;
          bool isFavorite =
              (await data.getFavoriteIdentities())?[identityMeta.key]?.status ==
                  EntryStatus.alive;
          if (mounted) {
            Navigator.pushNamed(
              context,
              IdentityScreen.routeName,
              arguments:
                  EntryScreenArgs(entry: identity, isFavorite: isFavorite),
            );
          }
        },
        popupMenuItemBuilder: identityPopupMenuBuilder,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
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
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditIdentityScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : IdentityButtonListView(
              identities: identities,
              shouldSort: true,
              onPressed: (identityMeta) async {
                Identity? identity = await data.getIdentity(identityMeta.key);
                if (identity == null) return;
                bool isFavorite =
                    (await data.getFavoriteIdentities())?[identityMeta.key]
                            ?.status ==
                        EntryStatus.alive;
                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    IdentityScreen.routeName,
                    arguments: EntryScreenArgs(
                        entry: identity, isFavorite: isFavorite),
                  );
                }
              },
              popupMenuItemBuilder: identityPopupMenuBuilder,
            ),
    );
  }
}
