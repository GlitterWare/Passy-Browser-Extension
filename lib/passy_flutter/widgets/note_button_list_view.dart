import 'package:flutter/material.dart';

import '../../passy_data/note.dart';
import '../passy_flutter.dart';

class NoteButtonListView extends StatefulWidget {
  final List<NoteMeta> notes;
  final bool shouldSort;
  final void Function(NoteMeta note)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(State state, NoteMeta noteMeta)?
      popupMenuItemBuilder;
  final List<Widget>? topWidgets;

  const NoteButtonListView({
    Key? key,
    required this.notes,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
  }) : super(key: key);

  @override
  State<NoteButtonListView> createState() => _NoteButtonListViewState();
}

class _NoteButtonListViewState extends State<NoteButtonListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.shouldSort) PassySort.sortNotes(widget.notes);
    return ListView(
      children: [
        if (widget.topWidgets != null) ...widget.topWidgets!,
        for (NoteMeta note in widget.notes)
          PassyPadding(NoteButton(
            note: note,
            onPressed:
                widget.onPressed == null ? null : () => widget.onPressed!(note),
            popupMenuItemBuilder: widget.popupMenuItemBuilder == null
                ? null
                : (context) => widget.popupMenuItemBuilder!(this, note),
          )),
      ],
    );
  }
}
