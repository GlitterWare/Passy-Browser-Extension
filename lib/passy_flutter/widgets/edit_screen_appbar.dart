import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/js_interop.dart';
import '../passy_flutter.dart';

class EditScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  final EdgeInsetsGeometry buttonPadding;
  final double buttonSplashRadius;
  final String title;
  final Function()? onSave;
  final bool isNew;

  const EditScreenAppBar({
    Key? key,
    this.buttonPadding = PassyTheme.appBarButtonPadding,
    this.buttonSplashRadius = PassyTheme.appBarButtonSplashRadius,
    required this.title,
    this.onSave,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: key,
      leading: IconButton(
        padding: buttonPadding,
        splashRadius: buttonSplashRadius,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: isNew
          ? Center(child: Text('${localizations.add} $title'))
          : Center(child: Text('${localizations.edit} $title')),
      actions: [
        IconButton(
          padding: buttonPadding,
          splashRadius: buttonSplashRadius,
          onPressed: onSave,
          tooltip: isNew ? localizations.add : localizations.save,
          icon: isNew
              ? const Icon(Icons.add_rounded)
              : const Icon(Icons.check_rounded),
        ),
        if (JsInterop.isEmbed())
          IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            icon: const Icon(Icons.close),
            onPressed: () => JsInterop.unloadEmbed(),
          ),
      ],
    );
  }
}
