import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passy_browser_extension/common/common.dart';
import 'package:passy_browser_extension/passy_browser_extension_flutter/passy_browser_extensions_flutter.dart';
import 'package:passy_browser_extension/screens/common/common.dart';

import '../passy_flutter/passy_flutter.dart';

class SearchScreenArgs {
  String? title;
  Widget Function(String terms) builder;

  SearchScreenArgs({
    this.title,
    required this.builder,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const routeName = '/search';

  @override
  State<StatefulWidget> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  bool _initialized = false;
  Widget _widget = const Text('');
  TextEditingController queryController =
      TextEditingController.fromValue(TextEditingValue(
    text: data.isEmbed ? Uri.parse(data.pageUrl).host : '',
    selection: TextSelection(
        baseOffset: 0,
        extentOffset:
            (data.isEmbed ? Uri.parse(data.pageUrl).host : '').length),
  ));
  FocusNode queryFocus = FocusNode()..requestFocus();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SearchScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as SearchScreenArgs;
    Widget Function(String terms) builder = args.builder;
    if (!_initialized) {
      _widget = builder(queryController.text);
      _initialized = true;
    }
    return WillPopScope(
      onWillPop: data.isEmbed ? () => logoutOnWillPop(this) : null,
      child: Scaffold(
        appBar: BrowserExtensionAppbar(
          leading: IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            icon: data.isEmbed
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: const Icon(Icons.logout),
                  )
                : const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: data.isEmbed
                ? () => logOut(this)
                : () => Navigator.pop(context),
          ),
          title: Text(args.title ??
              (data.isEmbed ? localizations.autofill : localizations.search)),
        ),
        body: Column(
          children: [
            PassyPadding(TextFormField(
                controller: queryController,
                onTap: () {
                  if (!queryFocus.hasFocus) {
                    queryFocus.requestFocus();
                    queryController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: queryController.value.text.length);
                  }
                },
                focusNode: queryFocus,
                decoration: InputDecoration(
                  label: Text(localizations.search),
                  hintText: 'github human@example.com',
                ),
                onChanged: (s) {
                  setState(() {
                    int baseOffset = queryController.selection.baseOffset;
                    queryController.text = s;
                    queryController.selection = TextSelection(
                        baseOffset: baseOffset, extentOffset: baseOffset);
                    _widget = builder(s);
                  });
                })),
            Expanded(
              child: _widget,
            ),
          ],
        ),
      ),
    );
  }
}
