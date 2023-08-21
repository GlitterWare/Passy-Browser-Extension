import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../passy_data/note.dart';
import '../passy_flutter.dart';

class NoteButton extends StatelessWidget {
  final NoteMeta note;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const NoteButton({
    Key? key,
    required this.note,
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
              child: Icon(Symbols.note_rounded, weight: 700, fill: 1),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: onPressed,
            center: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    note.title,
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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              splashRadius: 24,
              itemBuilder: popupMenuItemBuilder!,
            ),
          ),
      ],
    );
  }
}
