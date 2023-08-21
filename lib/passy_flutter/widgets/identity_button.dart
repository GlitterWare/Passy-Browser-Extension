import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../passy_data/identity.dart';
import '../passy_flutter.dart';

class IdentityButton extends StatelessWidget {
  final IdentityMeta identity;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const IdentityButton({
    Key? key,
    required this.identity,
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
              child: Icon(Symbols.people_outline_rounded, weight: 700),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: onPressed,
            center: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    identity.nickname,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    identity.firstAddressLine,
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
