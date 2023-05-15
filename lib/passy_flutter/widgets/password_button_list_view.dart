import 'package:flutter/material.dart';
import 'package:passy_browser_extension/common/js_interop.dart';
import 'package:passy_browser_extension/screens/edit_password_screen.dart';

import '../../common/common.dart';
import '../../passy_data/password.dart';
import '../passy_flutter.dart';

class PasswordButtonListView extends StatefulWidget {
  final List<PasswordMeta> passwords;
  final bool shouldSort;
  final void Function(PasswordMeta password)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      State state, PasswordMeta passwordMeta)? popupMenuItemBuilder;

  const PasswordButtonListView({
    Key? key,
    required this.passwords,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  State<PasswordButtonListView> createState() => _PasswordButtonListViewState();
}

class _PasswordButtonListViewState extends State<PasswordButtonListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.shouldSort) PassySort.sortPasswords(widget.passwords);
    return ListView(
      children: [
        if (data.isEmbed)
          PassyPadding(ThreeWidgetButton(
            left: const Icon(Icons.add_rounded),
            center: Center(child: Text(localizations.newPassword)),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () async {
              Uri? uri = await JsInterop.getPageUri();
              if (mounted) {
                Navigator.pushNamed(context, EditPasswordScreen.routeName,
                    arguments: Password(
                      nickname: uri == null ? '' : uri.host,
                      website: uri == null ? '' : uri.host,
                    ));
              }
            },
          )),
        for (PasswordMeta password in widget.passwords)
          PassyPadding(PasswordButton(
            password: password,
            onPressed: widget.onPressed == null
                ? null
                : () => widget.onPressed!(password),
            popupMenuItemBuilder: widget.popupMenuItemBuilder == null
                ? null
                : (ctx) => widget.popupMenuItemBuilder!(this, password),
          )),
      ],
    );
  }
}
