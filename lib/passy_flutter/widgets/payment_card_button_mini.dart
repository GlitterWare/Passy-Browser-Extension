import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import '../../passy_data/payment_card.dart';
import '../common/common.dart';
import '../passy_flutter.dart';

class PaymentCardButtonMini extends StatelessWidget {
  final PaymentCardMeta paymentCard;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const PaymentCardButtonMini({
    Key? key,
    required this.paymentCard,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CardType cardType =
        cardTypeFromNumber(paymentCard.cardNumber.replaceAll('*', '0'));
    return Row(children: [
      Flexible(
        child: ThreeWidgetButton(
          left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: getCardTypeImage(cardType)),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: onPressed,
          center: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  paymentCard.nickname,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  paymentCard.cardholderName,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
      if (popupMenuItemBuilder != null)
        FittedBox(
          child: PopupMenuButton(
            shape: PassyTheme.dialogShape,
            icon: const Icon(Icons.more_vert_rounded),
            padding: const EdgeInsets.fromLTRB(12, 23, 12, 23),
            splashRadius: 24,
            itemBuilder: popupMenuItemBuilder!,
          ),
        )
    ]);
  }
}
