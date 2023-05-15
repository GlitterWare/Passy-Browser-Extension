import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../common/js_interop.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/password.dart';
import '../passy_data/tfa.dart';
import '../passy_flutter/passy_flutter.dart';
import 'edit_custom_field_screen.dart';
import 'password_screen.dart';
import 'splash_screen.dart';
import 'main_screen.dart';
import 'passwords_screen.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '${PasswordScreen.routeName}/edit';

  @override
  State<StatefulWidget> createState() => _EditPasswordScreen();
}

class _EditPasswordScreen extends State<EditPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoaded = false;
  bool _isNew = true;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _tfaSecret = '';
  int _tfaLength = 6;
  int _tfaInterval = 30;
  Algorithm _tfaAlgorithm = Algorithm.SHA1;
  bool _tfaIsGoogle = true;
  bool _tfaIsExpanded = false;
  String _website = '';

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? args = ModalRoute.of(context)!.settings.arguments;
      _isNew = args == null;
      if (!_isNew) {
        Password passwordArgs = args as Password;
        TFA? tfa = passwordArgs.tfa;
        _key = passwordArgs.key;
        _customFields = passwordArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured,
                multiline: e.multiline))
            .toList();
        _additionalInfo = passwordArgs.additionalInfo;
        _tags = passwordArgs.tags;
        _nickname = passwordArgs.nickname;
        _username = passwordArgs.username;
        _email = passwordArgs.email;
        _password = passwordArgs.password;
        _passwordController.text = _password;
        if (tfa != null) {
          _tfaSecret = tfa.secret;
          _tfaLength = tfa.length;
          _tfaInterval = tfa.interval;
          _tfaAlgorithm = tfa.algorithm;
          _tfaIsGoogle = tfa.isGoogle;
        }
        _website = passwordArgs.website;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.password.toLowerCase(),
        isNew: _isNew,
        onSave: () async {
          _customFields.removeWhere((element) => element.value == '');
          Password passwordArgs = Password(
            key: _key,
            customFields: _customFields,
            additionalInfo: _additionalInfo,
            tags: _tags,
            nickname: _nickname,
            username: _username,
            email: _email,
            password: _password,
            tfa: _tfaSecret == ''
                ? null
                : TFA(
                    secret: _tfaSecret,
                    length: _tfaLength,
                    interval: _tfaInterval,
                    algorithm: _tfaAlgorithm,
                    isGoogle: _tfaIsGoogle,
                  ),
            website: _website,
          );
          Navigator.pushNamed(context, SplashScreen.routeName);
          await data.setPassword(passwordArgs);
          if (data.isEmbed) {
            JsInterop.autofillPassword(
              _username.isNotEmpty ? _username : _email,
              _email.isNotEmpty ? _email : _username,
              _password,
            );
            JsInterop.unloadEmbed();
            return;
          }
          List<PasswordMeta> passwords =
              (await data.getPasswordsMetadata())?.values.toList() ??
                  <PasswordMeta>[];
          bool isFavorite =
              (await data.getFavoritePasswords())?[passwordArgs.key]?.status ==
                  EntryStatus.alive;
          if (!mounted) return;
          Navigator.popUntil(
              context, ModalRoute.withName(MainScreen.routeName));
          Navigator.pushNamed(context, PasswordsScreen.routeName,
              arguments: passwords);
          Navigator.pushNamed(context, PasswordScreen.routeName,
              arguments:
                  EntryScreenArgs(entry: passwordArgs, isFavorite: isFavorite));
        },
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _nickname,
          decoration: InputDecoration(
            labelText: localizations.nickname,
          ),
          onChanged: (value) => setState(() => _nickname = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _username,
          decoration: InputDecoration(labelText: localizations.username),
          onChanged: (value) => setState(() => _username = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _email,
          decoration: InputDecoration(labelText: localizations.email),
          onChanged: (value) => setState(() => _email = value.trim()),
        )),
        PassyPadding(ButtonedTextFormField(
          controller: _passwordController,
          labelText: localizations.password,
          tooltip: localizations.generate,
          onChanged: (value) => setState(() => _password = value),
          buttonIcon: const Icon(Icons.password_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const StringGeneratorDialog(),
            ).then((value) {
              if (value == null) return;
              _passwordController.text = value;
              setState(() => _password = value);
            });
          },
        )),
        ExpansionPanelList(
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (panelIndex, isExpanded) =>
                setState(() => _tfaIsExpanded = !isExpanded),
            elevation: 0,
            dividerColor: PassyTheme.lightContentSecondaryColor,
            children: [
              ExpansionPanel(
                  backgroundColor: PassyTheme.darkContentColor,
                  isExpanded: _tfaIsExpanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                                color: PassyTheme.darkPassyPurple),
                            child: PassyPadding(Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Icon(Icons.security),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text('Two-Factor Authentication')),
                              ],
                            ))));
                  },
                  body: Column(
                    children: [
                      PassyPadding(TextFormField(
                        initialValue: _tfaSecret.replaceFirst('=', ''),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.secret.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z]|[A-Z]|[2-7]')),
                          TextInputFormatter.withFunction(
                              (oldValue, newValue) => TextEditingValue(
                                  text: newValue.text.toUpperCase(),
                                  selection: newValue.selection)),
                        ],
                        onChanged: (value) {
                          if (value.length.isOdd) value += '=';
                          setState(() => _tfaSecret = value);
                        },
                      )),
                      PassyPadding(TextFormField(
                        initialValue: _tfaLength.toString(),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.length.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) =>
                            setState(() => _tfaLength = int.parse(value)),
                      )),
                      PassyPadding(TextFormField(
                        initialValue: _tfaInterval.toString(),
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.interval.toLowerCase()}'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) =>
                            setState(() => _tfaInterval = int.parse(value)),
                      )),
                      PassyPadding(EnumDropDownButtonFormField<Algorithm>(
                        value: _tfaAlgorithm,
                        values: Algorithm.values,
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.algorithm.toLowerCase()}'),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _tfaAlgorithm = value);
                          }
                        },
                      )),
                      PassyPadding(DropdownButtonFormField(
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text(
                                '${localizations.true_} (${localizations.recommended.toLowerCase()})'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(localizations.false_),
                          ),
                        ],
                        value: _tfaIsGoogle,
                        decoration: InputDecoration(
                            labelText:
                                '2FA ${localizations.isGoogle.replaceRange(0, 1, localizations.isGoogle[0].toLowerCase())}'),
                        onChanged: (value) =>
                            setState(() => _tfaIsGoogle = value as bool),
                      )),
                    ],
                  ))
            ]),
        PassyPadding(TextFormField(
          initialValue: _website,
          decoration: const InputDecoration(labelText: 'Website'),
          onChanged: (value) => setState(() => _website = value),
        )),
        CustomFieldsEditor(
          customFields: _customFields,
          shouldSort: true,
          padding: PassyTheme.passyPadding,
          constructCustomField: () async => (await Navigator.pushNamed(
            context,
            EditCustomFieldScreen.routeName,
          )) as CustomField?,
        ),
        PassyPadding(TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          initialValue: _additionalInfo,
          decoration: InputDecoration(
            labelText: localizations.additionalInfo,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: const BorderSide(color: PassyTheme.lightContentColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide:
                  const BorderSide(color: PassyTheme.darkContentSecondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: const BorderSide(color: PassyTheme.lightContentColor),
            ),
          ),
          onChanged: (value) => setState(() => _additionalInfo = value),
        )),
      ]),
    );
  }
}
