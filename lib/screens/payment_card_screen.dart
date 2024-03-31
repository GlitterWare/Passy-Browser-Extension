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
  List<String> _tags = [];
  List<String> _selected = [];
  bool _tagsLoaded = false;
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

  Future<void> _load(PaymentCard paymentCard) async {
    List<String> newTags = await data.paymentCardsTags;
    newTags.sort();
    if (mounted) {
      setState(() {
        _tags = newTags;
        _selected = paymentCard.tags.toList();
        _selected.sort();
        for (String tag in _selected) {
          if (_tags.contains(tag)) {
            _tags.remove(tag);
          }
        }
        _tagsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final EntryScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as EntryScreenArgs;
    final PaymentCard paymentCard = args.entry as PaymentCard;
    if (!isLoaded) {
      isLoaded = true;
      _load(paymentCard);
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
        Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: PassyTheme.passyPadding.top / 2,
                bottom: PassyTheme.passyPadding.bottom / 2),
            child: !_tagsLoaded
                ? const CircularProgressIndicator()
                : EntryTagList(
                    showAddButton: true,
                    selected: _selected,
                    notSelected: _tags,
                    onSecondary: (tag) async {
                      String? newTag = await showDialog(
                        context: context,
                        builder: (ctx) => RenameTagDialog(tag: tag),
                      );
                      if (newTag == null) return;
                      if (newTag == tag) return;
                      if (!context.mounted) return;
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      try {
                        bool result =
                            await data.renameTag(tag: tag, newTag: newTag);
                        if (!result) throw Exception('Not implemented');
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                        showSnackBar(
                          message: localizations.somethingWentWrong,
                          icon: const Icon(Icons.error_outline_rounded,
                              color: PassyTheme.darkContentColor),
                        );
                        return;
                      }
                      paymentCard.tags = _selected.toList();
                      if (paymentCard.tags.contains(tag)) {
                        paymentCard.tags.remove(tag);
                        paymentCard.tags.add(newTag);
                      }
                      List<PaymentCardMeta> paymentCards =
                          (await data.getPaymentCardsMetadata())
                                  ?.values
                                  .toList() ??
                              <PaymentCardMeta>[];
                      if (!context.mounted) return;
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, PaymentCardsScreen.routeName,
                          arguments: paymentCards);
                      Navigator.pushNamed(context, PaymentCardScreen.routeName,
                          arguments: paymentCard);
                    },
                    onAdded: (tag) async {
                      if (paymentCard.tags.contains(tag)) return;
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      paymentCard.tags = _selected.toList();
                      paymentCard.tags.add(tag);
                      await data.setPaymentCard(paymentCard);
                      List<PaymentCardMeta> paymentCards =
                          (await data.getPaymentCardsMetadata())
                                  ?.values
                                  .toList() ??
                              <PaymentCardMeta>[];
                      if (!context.mounted) return;
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, PaymentCardsScreen.routeName,
                          arguments: paymentCards);
                      Navigator.pushNamed(
                        context,
                        PaymentCardScreen.routeName,
                        arguments: EntryScreenArgs(
                            entry: paymentCard, isFavorite: isFavorite),
                      );
                    },
                    onRemoved: (tag) async {
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      paymentCard.tags = _selected.toList();
                      paymentCard.tags.remove(tag);
                      await data.setPaymentCard(paymentCard);
                      List<PaymentCardMeta> paymentCards =
                          (await data.getPaymentCardsMetadata())
                                  ?.values
                                  .toList() ??
                              <PaymentCardMeta>[];
                      if (!context.mounted) return;
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, PaymentCardsScreen.routeName,
                          arguments: paymentCards);
                      Navigator.pushNamed(
                        context,
                        PaymentCardScreen.routeName,
                        arguments: EntryScreenArgs(
                            entry: paymentCard, isFavorite: isFavorite),
                      );
                    },
                  ),
          ),
        ),
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
