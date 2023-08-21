import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../passy_data/id_card.dart';
import '../passy_flutter.dart';

class IDCardButton extends StatelessWidget {
  final IDCardMeta idCard;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const IDCardButton({
    Key? key,
    required this.idCard,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: ThreeWidgetButton(
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Symbols.perm_identity_rounded, weight: 700),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: onPressed,
            center: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    idCard.nickname,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    idCard.name,
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
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              splashRadius: 24,
              itemBuilder: popupMenuItemBuilder!,
            ),
          ),
      ],
    );
  }
}
