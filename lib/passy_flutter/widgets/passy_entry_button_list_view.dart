import 'package:flutter/material.dart';

import '../passy_flutter.dart';

class PassyEntryButtonListView extends StatefulWidget {
  final List<SearchEntryData> entries;
  final bool shouldSort;
  final void Function(SearchEntryData entry)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      State state, SearchEntryData entryMeta)? popupMenuItemBuilder;

  const PassyEntryButtonListView({
    Key? key,
    required this.entries,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  State<PassyEntryButtonListView> createState() =>
      _PassyEntryButtonListViewState();
}

class _PassyEntryButtonListViewState extends State<PassyEntryButtonListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.shouldSort) PassySort.sortEntries(widget.entries);
    return ListView(
      children: [
        for (SearchEntryData entry in widget.entries)
          PassyPadding(entry.toWidget(
            onPressed: widget.onPressed == null
                ? null
                : () => widget.onPressed!(entry),
            popupMenuItemBuilder: widget.popupMenuItemBuilder == null
                ? null
                : (context) => widget.popupMenuItemBuilder!(this, entry),
          )),
      ],
    );
  }
}
