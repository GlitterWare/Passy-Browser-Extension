import 'package:flutter/foundation.dart';
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
  List<String> _tags = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIDCardScreen.routeName).then((value) {
        if (_isLoading) return;
        _load().then((value) => _isLoading = false);
      });

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
            entryType: EntryType.idCard,
            selectedTags: tag == null ? [] : [tag],
            builder:
                (String terms, List<String> tags, void Function() rebuild) {
              final List<IDCardMeta> found = [];
              final List<String> termsList =
                  terms.trim().toLowerCase().split(' ');
              final List<IDCardMeta> idCards = ModalRoute.of(context)!
                  .settings
                  .arguments as List<IDCardMeta>;
              for (IDCardMeta idCard in idCards) {
                {
                  bool testIDCard(IDCardMeta value) => idCard.key == value.key;

                  if (found.any(testIDCard)) continue;
                }
                {
                  bool tagMismatch = false;
                  for (String tag in tags) {
                    if (!idCard.tags.contains(tag)) {
                      tagMismatch = true;
                      break;
                    }
                  }
                  if (tagMismatch) continue;
                  int positiveCount = 0;
                  for (String term in termsList) {
                    if (idCard.nickname.toLowerCase().contains(term)) {
                      positiveCount++;
                      continue;
                    }
                    if (idCard.name.toLowerCase().contains(term)) {
                      positiveCount++;
                      continue;
                    }
                  }
                  if (positiveCount == termsList.length) {
                    found.add(idCard);
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
              return IDCardButtonListView(
                idCards: found,
                shouldSort: true,
                onPressed: (idCardMeta) async {
                  IDCard? idCard = await data.getIDCard(idCardMeta.key);
                  if (idCard == null) return;
                  bool isFavorite =
                      (await data.getFavoriteIDCards())?[idCardMeta.key]
                              ?.status ==
                          EntryStatus.alive;
                  if (!mounted) return;
                  Navigator.pushNamed(
                    context,
                    IDCardScreen.routeName,
                    arguments:
                        EntryScreenArgs(entry: idCard, isFavorite: isFavorite),
                  );
                },
                popupMenuItemBuilder: idCardPopupMenuBuilder,
              );
            }));
  }

  Future<void> _load() async {
    _isLoaded = true;
    _isLoading = true;
    List<String> newTags;
    try {
      newTags = await data.idCardsTags;
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
                          onPressed: _onAddPressed,
                          child: const Icon(Icons.add_rounded)),
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
              idCards: idCards,
              shouldSort: true,
              onPressed: (idCardMeta) async {
                IDCard? idCard = await data.getIDCard(idCardMeta.key);
                bool isFavorite =
                    (await data.getFavoriteIDCards())?[idCardMeta.key]
                            ?.status ==
                        EntryStatus.alive;
                if (idCard == null) return;
                if (context.mounted) {
                  Navigator.pushNamed(context, IDCardScreen.routeName,
                          arguments: EntryScreenArgs(
                              entry: idCard, isFavorite: isFavorite))
                      .then((value) {
                    if (_isLoading) return;
                    _load().then((value) => _isLoading = false);
                  });
                }
              },
              popupMenuItemBuilder: idCardPopupMenuBuilder,
            ),
    );
  }
}
