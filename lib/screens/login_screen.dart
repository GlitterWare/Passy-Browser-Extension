import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passy_browser_extension/common/js_interop.dart';
import 'package:passy_browser_extension/passy_browser_extension_flutter/passy_browser_extensions_flutter.dart';
import 'package:passy_browser_extension/passy_data/entry_type.dart';
import 'package:passy_browser_extension/passy_data/passy_search.dart';

import '../common/assets.dart';
import '../common/common.dart';
import '../passy_data/password.dart';
import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'main_screen.dart';
import 'search_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  Widget? _floatingActionButton;
  String _password = '';
  String _username = data.lastUsername;

  Widget _buildPasswords(Iterable<PasswordMeta> passwords, String terms,
      List<String> tags, void Function() rebuild) {
    List<PasswordMeta> found =
        PassySearch.searchPasswords(passwords: passwords, terms: terms, tags: tags);
    return PasswordButtonListView(
      passwords: found,
      onPressed: (passwordMeta) async {
        Password? password = await data.getPassword(passwordMeta.key);
        if (password == null) {
          if (mounted) {
            showSnackBar(
              message: localizations.failedToLoad,
              icon: const Icon(Symbols.password_rounded,
                  weight: 700, color: PassyTheme.darkContentColor),
            );
          }
          return;
        }
        JsInterop.autofillPassword(
          password.username.isNotEmpty ? password.username : password.email,
          password.email.isNotEmpty ? password.email : password.username,
          password.password,
        );
        JsInterop.unloadEmbed();
      },
      shouldSort: true,
    );
  }

  Future<void> _launchAutofill() async {
    Iterable<PasswordMeta> passwords =
        (await data.getPasswordsMetadata())?.values ?? {};
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        SearchScreen.routeName,
        arguments: SearchScreenArgs(
          entryType: EntryType.password,
          builder: (terms, tags, rebuild) =>
              _buildPasswords(passwords, terms, tags, rebuild),
        ),
      );
    }
  }

  void login() async {
    String password = _password;
    setState(() {
      _password = '';
      _passwordController.text = '';
    });
    await data.reloadAccountCredentials();
    if (!(await data.verify(_username, password))) {
      if (mounted) {
        showSnackBar(
          message: localizations.incorrectPassword,
          icon: const Icon(Icons.lock_rounded,
              color: PassyTheme.darkContentColor),
        );
      }
      return;
    }
    await data.login(_username, password);
    if (data.isEmbed) {
      await _launchAutofill();
      return;
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, MainScreen.routeName);
    }
  }

  Future<void> onUsernamesEmpty() async {
    while (data.usernames.isEmpty) {
      await data.reloadAccountCredentials();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    setState(() => _username = data.usernames.contains(data.lastUsername)
        ? data.lastUsername
        : data.usernames.first);
  }

  @override
  void initState() {
    super.initState();
    onUsernamesEmpty();
    if (data.isLoggedIn) {
      if (data.isEmbed) {
        _launchAutofill();
      } else {
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> usernames = data.usernames
        .map<DropdownMenuItem<String>>((username) => DropdownMenuItem(
              value: username,
              child: Text(username),
            ))
        .toList();

    return Scaffold(
      floatingActionButton: _floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: const BrowserExtensionAppbar(),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!data.isEmbed) const Spacer(flex: 4),
                if (data.isEmbed) const SizedBox(height: 45),
                logo60Purple,
                if (!data.isEmbed) const Spacer(),
                if (data.isEmbed) const SizedBox(height: 20),
                PassyPadding(
                  Column(
                    children: [
                      if (data.usernames.isEmpty)
                        Center(
                            child: Text(
                          '${localizations.noAccounts}!\n\n${localizations.pleaseOpenTheDesktopApplicationAndAddAnAccount}.',
                          textAlign: TextAlign.center,
                        )),
                      if (data.usernames.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                value: _username,
                                items: usernames,
                                selectedItemBuilder: (context) {
                                  return usernames.map<Widget>((item) {
                                    return Text(item.value!);
                                  }).toList();
                                },
                                onChanged: (a) {
                                  setState(() => _username = a!);
                                },
                              ),
                            ),
                          ],
                        ),
                      if (data.usernames.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                onSubmitted: (value) => login(),
                                onChanged: (a) => setState(() => _password = a),
                                decoration: InputDecoration(
                                  hintText: localizations.password,
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(32),
                                ],
                                autofocus: true,
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: () => login(),
                              tooltip: localizations.logIn,
                              heroTag: null,
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (!data.isEmbed) const Spacer(flex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
