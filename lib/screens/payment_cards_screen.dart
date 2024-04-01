import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/payment_card.dart';
import '../passy_flutter/passy_flutter.dart';
import 'edit_payment_card_screen.dart';
import 'common/entry_screen_args.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'payment_card_screen.dart';

class PaymentCardsScreen extends StatefulWidget {
  const PaymentCardsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/paymentCards';

  @override
  State<StatefulWidget> createState() => _PaymentCardsScreen();
}

class _PaymentCardsScreen extends State<PaymentCardsScreen> {
  List<String> _tags = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
          entryType: EntryType.paymentCard,
          selectedTags: tag == null ? [] : [tag],
          builder: (String terms, List<String> tags, void Function() rebuild) {
            final List<PaymentCardMeta> found = [];
            final List<String> termsList =
                terms.trim().toLowerCase().split(' ');
            final List<PaymentCardMeta> paymentCards = ModalRoute.of(context)!
                .settings
                .arguments as List<PaymentCardMeta>;
            for (PaymentCardMeta paymentCard in paymentCards) {
              {
                bool testPaymentCard(PaymentCardMeta value) =>
                    paymentCard.key == value.key;

                if (found.any(testPaymentCard)) continue;
              }
              {
                int positiveCount = 0;
                bool tagMismatch = false;
                for (String tag in tags) {
                  if (!paymentCard.tags.contains(tag)) {
                    tagMismatch = true;
                    break;
                  }
                }
                if (tagMismatch) continue;
                for (String term in termsList) {
                  if (paymentCard.cardholderName.toLowerCase().contains(term)) {
                    positiveCount++;
                    continue;
                  }
                  if (paymentCard.nickname.toLowerCase().contains(term)) {
                    positiveCount++;
                    continue;
                  }
                  if (paymentCard.exp.toLowerCase().contains(term)) {
                    positiveCount++;
                    continue;
                  }
                }
                if (positiveCount == termsList.length) {
                  found.add(paymentCard);
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
            return PaymentCardButtonListView(
              paymentCards: found,
              shouldSort: true,
              onPressed: (paymentCardMeta) async {
                PaymentCard? paymentCard =
                    await data.getPaymentCard(paymentCardMeta.key);
                if (paymentCard == null) return;
                bool isFavorite =
                    (await data.getFavoritePaymentCards())?[paymentCardMeta.key]
                            ?.status ==
                        EntryStatus.alive;
                if (!mounted) return;
                Navigator.pushNamed(
                  context,
                  PaymentCardScreen.routeName,
                  arguments: EntryScreenArgs(
                      entry: paymentCard, isFavorite: isFavorite),
                ).then((value) {
                  if (_isLoading) return;
                  _load().then((value) => _isLoading = false);
                });
              },
            );
          },
        ));
  }

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPaymentCardScreen.routeName)
          .then((value) {
        if (_isLoading) return;
        _load().then((value) => _isLoading = false);
      });

  Future<void> _load() async {
    _isLoaded = true;
    _isLoading = true;
    List<String> newTags;
    try {
      newTags = await data.paymentCardsTags;
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
    List<PaymentCardMeta> paymentCards =
        ModalRoute.of(context)!.settings.arguments as List<PaymentCardMeta>;
    return Scaffold(
      appBar: EntriesScreenAppBar(
        entryType: EntryType.paymentCard,
        title: Text(localizations.paymentCards),
        onAddPressed: _onAddPressed,
        onSearchPressed: _onSearchPressed,
      ),
      body: paymentCards.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noPaymentCards,
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
          : PaymentCardButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                      left: const Icon(Icons.add_rounded),
                      center: Text(
                        localizations.addPaymentCard,
                        textAlign: TextAlign.center,
                      ),
                      right: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: _onAddPressed),
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
              paymentCards: paymentCards,
              shouldSort: true,
              onPressed: (paymentCardMeta) async {
                PaymentCard? paymentCard =
                    await data.getPaymentCard(paymentCardMeta.key);
                if (paymentCard == null) return;
                bool isFavorite =
                    (await data.getFavoritePaymentCards())?[paymentCardMeta.key]
                            ?.status ==
                        EntryStatus.alive;
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    PaymentCardScreen.routeName,
                    arguments: EntryScreenArgs(
                        entry: paymentCard, isFavorite: isFavorite),
                  ).then((value) {
                    if (_isLoading) return;
                    _load().then((value) => _isLoading = false);
                  });
                }
              },
            ),
    );
  }
}
