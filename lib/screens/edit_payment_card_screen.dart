import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/payment_card.dart';
import '../passy_flutter/passy_flutter.dart';
import 'edit_custom_field_screen.dart';
import 'main_screen.dart';
import 'payment_card_screen.dart';
import 'splash_screen.dart';
import 'payment_cards_screen.dart';

class EditPaymentCardScreen extends StatefulWidget {
  const EditPaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '${PaymentCardScreen.routeName}/editPaymentCard';

  @override
  State<StatefulWidget> createState() => _EditPaymentCardScreen();
}

class _EditPaymentCardScreen extends State<EditPaymentCardScreen> {
  bool _isLoaded = false;
  bool _isNew = false;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  String _cardNumber = '';
  String _cardholderName = '';
  String _cvv = '';
  String _exp = '';
  List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    {
      DateTime date = DateTime.now().toUtc();
      String month = date.month.toString();
      String year = date.year.toString();
      if (month.length == 1) {
        month = '0$month';
      }
      _exp = '$month/$year';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? args = ModalRoute.of(context)!.settings.arguments;
      _isNew = args == null;
      if (!_isNew) {
        PaymentCard paymentCardArgs = args as PaymentCard;
        _key = paymentCardArgs.key;
        _customFields = paymentCardArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured,
                multiline: e.multiline))
            .toList();
        _additionalInfo = paymentCardArgs.additionalInfo;
        _tags = paymentCardArgs.tags;
        _nickname = paymentCardArgs.nickname;
        _cardNumber = paymentCardArgs.cardNumber;
        _cardholderName = paymentCardArgs.cardholderName;
        _cvv = paymentCardArgs.cvv;
        _exp = paymentCardArgs.exp;
        _attachments = paymentCardArgs.attachments;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.paymentCard.toLowerCase(),
        onSave: () async {
          _customFields.removeWhere((element) => element.value == '');
          PaymentCard paymentCardArgs = PaymentCard(
            key: _key,
            customFields: _customFields,
            additionalInfo: _additionalInfo,
            tags: _tags,
            nickname: _nickname,
            cardNumber: _cardNumber,
            cardholderName: _cardholderName,
            cvv: _cvv,
            exp: _exp,
            attachments: _attachments,
          );
          Navigator.pushNamed(context, SplashScreen.routeName);
          await data.setPaymentCard(paymentCardArgs);
          List<PaymentCardMeta> paymentCards =
              (await data.getPaymentCardsMetadata())?.values.toList() ??
                  <PaymentCardMeta>[];
          bool isFavorite =
              (await data.getFavoritePaymentCards())?[paymentCardArgs.key]
                      ?.status ==
                  EntryStatus.alive;
          if (!context.mounted) return;
          Navigator.popUntil(
              context, ModalRoute.withName(MainScreen.routeName));
          Navigator.pushNamed(context, PaymentCardsScreen.routeName,
              arguments: paymentCards);
          Navigator.pushNamed(context, PaymentCardScreen.routeName,
              arguments: EntryScreenArgs(
                  entry: paymentCardArgs, isFavorite: isFavorite));
        },
        isNew: _isNew,
      ),
      body: ListView(
        children: [
          PaymentCardButton(
            paymentCard: PaymentCardMeta(
              key: '',
              tags: [],
              nickname: _nickname,
              cardNumber: _cardNumber,
              cardholderName: _cardholderName,
              exp: _exp,
            ),
            obscureCardNumber: false,
            obscureCardCvv: false,
            isSwipeGestureEnabled: false,
          ),
          PassyPadding(TextFormField(
            initialValue: _nickname,
            decoration: InputDecoration(labelText: localizations.nickname),
            onChanged: (value) => setState(() => _nickname = value.trim()),
          )),
          PassyPadding(TextFormField(
            initialValue: _cardNumber,
            decoration: InputDecoration(labelText: localizations.cardNumber),
            onChanged: (value) => setState(() => _cardNumber = value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )),
          PassyPadding(TextFormField(
            initialValue: _cardholderName,
            decoration:
                InputDecoration(labelText: localizations.cardHolderName),
            onChanged: (value) =>
                setState(() => _cardholderName = value.trim()),
          )),
          PassyPadding(MonthPickerFormField(
            key: UniqueKey(),
            initialValue: _exp,
            title: localizations.expirationDate,
            getSelectedDate: () {
              DateTime now = DateTime.now();
              List<String> date = _exp.split('/');
              if (date.length < 2) return DateTime.now();
              String month = date[0];
              String year = date[1];
              if (month[0] == '0') {
                month = month[1];
              }
              int? monthDecoded = int.tryParse(month);
              if (monthDecoded == null) return now;
              int? yearDecoded = int.tryParse(year);
              if (yearDecoded == null) return now;
              if (yearDecoded < now.year) yearDecoded = now.year;
              return DateTime.utc(yearDecoded, monthDecoded);
            },
            onChanged: (selectedDate) {
              String month = selectedDate.month.toString();
              String year = selectedDate.year.toString();
              if (month.length == 1) month = '0$month';
              setState(() => _exp = '$month/$year');
            },
          )),
          PassyPadding(TextFormField(
            initialValue: _cvv,
            decoration: const InputDecoration(labelText: 'CVV'),
            onChanged: (value) => setState(() => _cvv = value),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )),
          CustomFieldsEditor(
            customFields: _customFields,
            shouldSort: true,
            padding: PassyTheme.passyPadding,
            constructCustomField: () async => (await Navigator.pushNamed(
              context,
              EditCustomFieldScreen.routeName,
            )) as CustomField?,
          ),
          PassyPadding(TextFormField(
            initialValue: _additionalInfo,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              labelText: localizations.additionalInfo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.0),
                borderSide:
                    const BorderSide(color: PassyTheme.lightContentColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.0),
                borderSide: const BorderSide(
                    color: PassyTheme.darkContentSecondaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.0),
                borderSide:
                    const BorderSide(color: PassyTheme.lightContentColor),
              ),
            ),
            onChanged: (value) => setState(() => _additionalInfo = value),
          )),
        ],
      ),
    );
  }
}
