import 'package:flutter/material.dart';
import 'package:passy_browser_extension/common/assets.dart';
import 'package:passy_browser_extension/common/js_interop.dart';

import '../../passy_flutter/passy_flutter.dart';

class BrowserExtensionAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  final EdgeInsetsGeometry buttonPadding;
  final double buttonSplashRadius;
  final Widget? title;
  final Widget? leading;

  const BrowserExtensionAppbar({
    Key? key,
    this.buttonPadding = PassyTheme.appBarButtonPadding,
    this.buttonSplashRadius = PassyTheme.appBarButtonSplashRadius,
    this.title,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: key,
      title: title,
      centerTitle: true,
      leading: leading ?? PassyPadding(logo60Purple),
      automaticallyImplyLeading: false,
      actions: [
        if (JsInterop.getIsEmbed())
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
