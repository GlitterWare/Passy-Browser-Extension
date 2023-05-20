import 'package:flutter/material.dart';

import '../../passy_data/id_card.dart';
import '../passy_flutter.dart';

class IDCardButtonListView extends StatefulWidget {
  final List<IDCardMeta> idCards;
  final bool shouldSort;
  final void Function(IDCardMeta idCard)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      State state, IDCardMeta idCardMeta)? popupMenuItemBuilder;
  final List<Widget>? topWidgets;

  const IDCardButtonListView({
    Key? key,
    required this.idCards,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
  }) : super(key: key);

  @override
  State<IDCardButtonListView> createState() => _IDCardButtonListViewState();
}

class _IDCardButtonListViewState extends State<IDCardButtonListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.shouldSort) PassySort.sortIDCards(widget.idCards);
    return ListView(
      children: [
        if (widget.topWidgets != null) ...widget.topWidgets!,
        for (IDCardMeta idCard in widget.idCards)
          PassyPadding(IDCardButton(
            idCard: idCard,
            onPressed: widget.onPressed == null
                ? null
                : () => widget.onPressed!(idCard),
            popupMenuItemBuilder: widget.popupMenuItemBuilder == null
                ? null
                : (context) => widget.popupMenuItemBuilder!(this, idCard),
          )),
      ],
    );
  }
}
