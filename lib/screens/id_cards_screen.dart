import 'package:flutter/material.dart';
import 'package:passy_browser_extension/passy_data/entry_event.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/id_card.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'edit_id_card_screen.dart';
import 'id_card_screen.dart';
import 'main_screen.dart';
import 'search_screen.dart';

class IDCardsScreen extends StatefulWidget {
  const IDCardsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/idCards';

  @override
  State<StatefulWidget> createState() => _IDCardsScreen();
}

class _IDCardsScreen extends State<IDCardsScreen> {
  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIDCardScreen.routeName);

  void _onSearchPressed() {
    List<IDCardMeta> idCardsMetadata =
        ModalRoute.of(context)!.settings.arguments as List<IDCardMeta>;
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(builder: (String terms) {
      final List<IDCardMeta> found = [];
      final List<String> termsSplit = terms.trim().toLowerCase().split(' ');
      for (IDCardMeta idCard in idCardsMetadata) {
        {
          bool testIDCard(IDCardMeta value) => idCard.key == value.key;

          if (found.any(testIDCard)) continue;
        }
        {
          int positiveCount = 0;
          for (String term in termsSplit) {
            if (idCard.nickname.toLowerCase().contains(term)) {
              positiveCount++;
              continue;
            }
            if (idCard.name.toLowerCase().contains(term)) {
              positiveCount++;
              continue;
            }
          }
          if (positiveCount == termsSplit.length) {
            found.add(idCard);
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
      return IDCardButtonListView(
        idCards: found,
        shouldSort: true,
        onPressed: (idCardMeta) async {
          IDCard? idCard = await data.getIDCard(idCardMeta.key);
          bool isFavorite =
              (await data.getFavoriteIDCards())?[idCardMeta.key]?.status ==
                  EntryStatus.alive;
          if (idCard == null) return;
          if (mounted) {
            Navigator.pushNamed(context, IDCardScreen.routeName,
                arguments:
                    EntryScreenArgs(entry: idCard, isFavorite: isFavorite));
          }
        },
        popupMenuItemBuilder: idCardPopupMenuBuilder,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    List<IDCardMeta> idCards =
        ModalRoute.of(context)!.settings.arguments as List<IDCardMeta>;
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.idCard,
          title: Center(child: Text(localizations.idCards)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: idCards.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noIDCards,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditIDCardScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : IDCardButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addIDCard,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, EditIDCardScreen.routeName),
                  ),
                ),
              ],
              idCards: idCards,
              shouldSort: true,
              onPressed: (idCardMeta) async {
                IDCard? idCard = await data.getIDCard(idCardMeta.key);
                bool isFavorite =
                    (await data.getFavoriteIDCards())?[idCardMeta.key]
                            ?.status ==
                        EntryStatus.alive;
                if (idCard == null) return;
                if (mounted) {
                  Navigator.pushNamed(context, IDCardScreen.routeName,
                      arguments: EntryScreenArgs(
                          entry: idCard, isFavorite: isFavorite));
                }
              },
              popupMenuItemBuilder: idCardPopupMenuBuilder,
            ),
    );
  }
}
