import 'package:flutter/material.dart';

import '../../passy_data/payment_card.dart';
import '../passy_flutter.dart';

class PaymentCardButtonListView extends StatelessWidget {
  final List<PaymentCardMeta> paymentCards;
  final bool shouldSort;
  final void Function(PaymentCardMeta paymentCard)? onPressed;

  const PaymentCardButtonListView({
    Key? key,
    required this.paymentCards,
    this.shouldSort = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortPaymentCards(paymentCards);
    return ListView(
      children: [
        for (PaymentCardMeta paymentCard in paymentCards)
          PassyPadding(PaymentCardButton(
            paymentCard: paymentCard,
            onPressed: onPressed == null ? null : () => onPressed!(paymentCard),
          )),
      ],
    );
  }
}
