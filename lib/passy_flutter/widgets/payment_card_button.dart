import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../passy_data/payment_card.dart';
import '../common/common.dart';

class PaymentCardButton extends StatelessWidget {
  final PaymentCardMeta paymentCard;
  final bool obscureCardNumber;
  final bool obscureCardCvv;
  final bool isSwipeGestureEnabled;
  final List<CustomCardTypeIcon>? customCardTypeIcons;
  final void Function()? onPressed;

  const PaymentCardButton({
    Key? key,
    required this.paymentCard,
    this.obscureCardNumber = true,
    this.obscureCardCvv = true,
    this.isSwipeGestureEnabled = false,
    this.customCardTypeIcons,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          TextButton(
            onPressed: onPressed,
            child: CreditCardWidget(
              glassmorphismConfig: Glassmorphism.defaultConfig(),
              width: 350,
              height: 200,
              cardNumber: ' ',
              expiryDate: paymentCard.exp,
              cardHolderName: paymentCard.cardholderName,
              customCardTypeIcons: customCardTypeIcons ??
                  [
                    CustomCardTypeIcon(
                        cardType: CardType.otherBrand,
                        cardImage: WebsafeSvg.asset(
                          'assets/images/logo_circle.svg',
                          colorFilter: const ColorFilter.mode(
                              Colors.purple, BlendMode.srcIn),
                          width: 50,
                        ))
                  ],
              cvvCode: '',
              showBackView: false,
              obscureCardNumber: obscureCardNumber,
              obscureCardCvv: obscureCardCvv,
              isHolderNameVisible: true,
              isChipVisible: false,
              backgroundImage: 'assets/images/payment_card_bg.png',
              cardType: cardTypeFromNumber(
                  paymentCard.cardNumber.replaceAll('*', '0')),
              isSwipeGestureEnabled: isSwipeGestureEnabled,
              onCreditCardWidgetChange: (brand) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 32, 0, 0),
            child: Text(
              paymentCard.nickname,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
