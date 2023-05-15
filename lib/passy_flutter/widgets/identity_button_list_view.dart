import 'package:flutter/material.dart';

import '../../passy_data/identity.dart';
import '../passy_flutter.dart';

class IdentityButtonListView extends StatefulWidget {
  final List<IdentityMeta> identities;
  final bool shouldSort;
  final void Function(IdentityMeta identity)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      State state, IdentityMeta identityMeta)? popupMenuItemBuilder;

  const IdentityButtonListView({
    Key? key,
    required this.identities,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  State<IdentityButtonListView> createState() => _IdentityButtonListViewState();
}

class _IdentityButtonListViewState extends State<IdentityButtonListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.shouldSort) PassySort.sortIdentities(widget.identities);
    return ListView(
      children: [
        for (IdentityMeta identity in widget.identities)
          PassyPadding(IdentityButton(
            identity: identity,
            onPressed: widget.onPressed == null
                ? null
                : () => widget.onPressed!(identity),
            popupMenuItemBuilder: widget.popupMenuItemBuilder == null
                ? null
                : (context) => widget.popupMenuItemBuilder!(this, identity),
          )),
      ],
    );
  }
}
