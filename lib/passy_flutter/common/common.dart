export 'always_disabled_focus_node.dart';

import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../../common/assets.dart';
import '../passy_flutter.dart';

String capitalize(String string) {
  if (string.isEmpty) return '';
  String firstLetter = string[0].toUpperCase();
  if (string.length == 1) return firstLetter;
  return '$firstLetter${string.substring(1)}';
}

CardType cardTypeFromCreditCardType(CreditCardType cardType) {
  switch (cardType) {
    case CreditCardType.visa:
      return CardType.visa;
    case CreditCardType.mastercard:
      return CardType.mastercard;
    case CreditCardType.amex:
      return CardType.americanExpress;
    case CreditCardType.discover:
      return CardType.discover;
    default:
      return CardType.otherBrand;
  }
}

CardType cardTypeFromNumber(String number) =>
    cardTypeFromCreditCardType(detectCCType(number));

String beautifyCardNumber(String cardNumber) {
  if (cardNumber.isEmpty) {
    return '';
  }
  String value = cardNumber.trim();
  cardNumber = value[0];
  for (int i = 1; i < value.length; i++) {
    if (i % 4 == 0) cardNumber += ' ';
    cardNumber += value[i];
  }
  return cardNumber;
}

int alphabeticalCompare(String a, String b) =>
    a.toLowerCase().compareTo(b.toLowerCase());

String dateToString(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

DateTime stringToDate(String value) {
  if (value == '') return DateTime.now();
  List<String> dateSplit = value.split('/');
  if (dateSplit.length < 3) return DateTime.now();
  int? yy = int.tryParse(dateSplit[2]);
  if (yy == null) return DateTime.now();
  int? mm = int.tryParse(dateSplit[1]);
  if (mm == null) return DateTime.now();
  int? dd = int.tryParse(dateSplit[0]);
  if (dd == null) return DateTime.now();
  return DateTime(yy, mm, dd);
}

Future<DateTime?> showPassyDatePicker(
    {required BuildContext context,
    required DateTime date,
    ColorScheme colorScheme = PassyTheme.datePickerColorScheme}) {
  return showDatePicker(
    context: context,
    initialDate: date,
    firstDate: DateTime.utc(-271820),
    lastDate: DateTime.utc(275760),
    builder: (context, w) => Theme(
      data: ThemeData(colorScheme: colorScheme),
      child: w!,
    ),
  );
}

Widget getCardTypeImage(CardType? cardType) {
  if (cardType == CardType.otherBrand) {
    return logoCircle50White;
  }

  return Image.asset(
    CardTypeIconAsset[cardType]!,
    height: 48,
    width: 48,
    package: 'flutter_credit_card',
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
  BuildContext context, {
  required String message,
  required Widget icon,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      icon,
      const SizedBox(width: 20),
      Expanded(child: Text(message)),
    ]),
    action: action,
  ));
}
