import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/payment_card.dart';
import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/entry_screen_args.dart';
import 'main_screen.dart';
import 'edit_payment_card_screen.dart';
import 'payment_cards_screen.dart';
import 'splash_screen.dart';

class PaymentCardScreen extends StatefulWidget {
  const PaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '/paymentCard';

  @override
  State<StatefulWidget> createState() => _PaymentCardScreen();
}

class _PaymentCardScreen extends State<PaymentCardScreen> {
  bool isFavorite = false;
  bool isLoaded = false;

  void _onRemovePressed(PaymentCard paymentCard) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removePaymentCard),
            content: Text(
                '${localizations.paymentCardsCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () async {
                  Navigator.pushNamed(context, SplashScreen.routeName);
                  await data.removePaymentCard(paymentCard.key);
                  List<PaymentCardMeta> paymentCards =
                      (await data.getPaymentCardsMetadata())?.values.toList() ??
                          <PaymentCardMeta>[];
                  if (!mounted) return;
                  Navigator.popUntil(
                      context, ModalRoute.withName(MainScreen.routeName));
                  Navigator.pushNamed(context, PaymentCardsScreen.routeName,
                      arguments: paymentCards);
                },
              )
            ],
          );
        });
  }

  void _onEditPressed(PaymentCard paymentCard) {
    Navigator.pushNamed(
      context,
      EditPaymentCardScreen.routeName,
      arguments: paymentCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final EntryScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as EntryScreenArgs;
    final PaymentCard paymentCard = args.entry as PaymentCard;
    if (!isLoaded) {
      isLoaded = true;
      isFavorite = args.isFavorite;
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.paymentCard,
        entryKey: paymentCard.key,
        title: Center(child: Text(localizations.paymentCard)),
        onRemovePressed: () => _onRemovePressed(paymentCard),
        onEditPressed: () => _onEditPressed(paymentCard),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await data.toggleFavoritePaymentCard(paymentCard.key, false);
            setState(() => isFavorite = false);
            if (mounted) {
              showSnackBar(
                  message: localizations.removedFromFavorites,
                  icon: const Icon(
                    Symbols.star_rounded,
                    weight: 700,
                    color: PassyTheme.darkContentColor,
                  ));
            }
          } else {
            await data.toggleFavoritePaymentCard(paymentCard.key, true);
            setState(() => isFavorite = true);
            if (mounted) {
              showSnackBar(
                  message: localizations.addedToFavorites,
                  icon: const Icon(
                    Symbols.star_rounded,
                    weight: 700,
                    fill: 1,
                    color: PassyTheme.darkContentColor,
                  ));
            }
          }
          setState(() {});
        },
      ),
      body: ListView(children: [
        PaymentCardButton(
          paymentCard: paymentCard.uncensoredMetadata,
          obscureCardNumber: false,
          obscureCardCvv: false,
          isSwipeGestureEnabled: false,
        ),
        if (paymentCard.nickname != '')
          PassyPadding(RecordButton(
            title: localizations.nickname,
            value: paymentCard.nickname,
          )),
        if (paymentCard.cardNumber != '')
          PassyPadding(RecordButton(
            title: localizations.cardNumber,
            value: paymentCard.cardNumber,
          )),
        if (paymentCard.cardholderName != '')
          PassyPadding(RecordButton(
            title: localizations.cardHolderName,
            value: paymentCard.cardholderName,
          )),
        if (paymentCard.exp != '')
          PassyPadding(RecordButton(
            title: localizations.expirationDate,
            value: paymentCard.exp,
          )),
        if (paymentCard.cvv != '')
          PassyPadding(RecordButton(
            title: 'CVV',
            value: paymentCard.cvv,
            obscureValue: true,
          )),
        for (CustomField customField in paymentCard.customFields)
          PassyPadding(CustomFieldButton(customField: customField)),
        if (paymentCard.additionalInfo != '')
          PassyPadding(RecordButton(
            title: localizations.additionalInfo,
            value: paymentCard.additionalInfo,
          )),
      ]),
    );
  }
}
