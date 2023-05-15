import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../passy_data/entry_type.dart';
import '../passy_flutter.dart';

class EntriesScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  final EntryType entryType;
  final EdgeInsetsGeometry buttonPadding;
  final double buttonSplashRadius;
  final Widget title;
  final void Function()? onSearchPressed;
  final void Function()? onAddPressed;

  const EntriesScreenAppBar({
    Key? key,
    required this.entryType,
    this.buttonPadding = PassyTheme.appBarButtonPadding,
    this.buttonSplashRadius = PassyTheme.appBarButtonSplashRadius,
    required this.title,
    this.onSearchPressed,
    this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        padding: buttonPadding,
        splashRadius: buttonSplashRadius,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: title,
      actions: [
        IconButton(
          padding: buttonPadding,
          splashRadius: buttonSplashRadius,
          onPressed: onSearchPressed,
          tooltip: localizations.search,
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          padding: buttonPadding,
          splashRadius: buttonSplashRadius,
          onPressed: onAddPressed,
          tooltip: localizations.addEntry,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
