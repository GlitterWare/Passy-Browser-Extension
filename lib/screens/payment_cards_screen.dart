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
  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
      builder: (String terms) {
        List<PaymentCardMeta> paymentCardsMetadata =
            ModalRoute.of(context)!.settings.arguments as List<PaymentCardMeta>;
        final List<PaymentCardMeta> found = [];
        final List<String> termsSplit = terms.trim().toLowerCase().split(' ');
        for (PaymentCardMeta paymentCard in paymentCardsMetadata) {
          {
            bool testPaymentCard(PaymentCardMeta value) =>
                paymentCard.key == value.key;

            if (found.any(testPaymentCard)) continue;
          }
          {
            int positiveCount = 0;
            for (String term in termsSplit) {
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
            if (positiveCount == termsSplit.length) {
              found.add(paymentCard);
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
            if (mounted) {
              Navigator.pushNamed(
                context,
                PaymentCardScreen.routeName,
                arguments:
                    EntryScreenArgs(entry: paymentCard, isFavorite: isFavorite),
              );
            }
          },
        );
      },
    ));
  }

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPaymentCardScreen.routeName);

  @override
  Widget build(BuildContext context) {
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
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditPaymentCardScreen.routeName)),
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
                    onPressed: () => Navigator.pushNamed(
                        context, EditPaymentCardScreen.routeName),
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
                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    PaymentCardScreen.routeName,
                    arguments: EntryScreenArgs(
                        entry: paymentCard, isFavorite: isFavorite),
                  );
                }
              },
            ),
    );
  }
}
