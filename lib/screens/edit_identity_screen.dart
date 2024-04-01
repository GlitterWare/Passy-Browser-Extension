import 'package:flutter/material.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_event.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'main_screen.dart';
import 'splash_screen.dart';
import 'edit_custom_field_screen.dart';
import 'identities_screen.dart';
import 'identity_screen.dart';
import '../passy_data/identity.dart' as id;

class EditIdentityScreen extends StatefulWidget {
  const EditIdentityScreen({Key? key}) : super(key: key);

  static const routeName = '${IdentityScreen.routeName}/edit';

  @override
  State<StatefulWidget> createState() => _EditIdentityScreen();
}

class _EditIdentityScreen extends State<EditIdentityScreen> {
  bool _isLoaded = false;
  bool _isNew = true;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  id.Title _title = id.Title.mx;
  String _firstName = '';
  String _middleName = '';
  String _lastName = '';
  id.Gender _gender = id.Gender.notSpecified;
  String _email = '';
  String _number = '';
  String _firstAddressLine = '';
  String _secondAddressLine = '';
  String _zipCode = '';
  String _city = '';
  String _country = '';
  List<String> _attachments = [];

  @override
  Widget build(BuildContext context) {
    void onSave() async {
      _customFields.removeWhere((element) => element.value == '');
      id.Identity identityArgs = id.Identity(
        key: _key,
        customFields: _customFields,
        additionalInfo: _additionalInfo,
        tags: _tags,
        nickname: _nickname,
        title: _title,
        firstName: _firstName,
        middleName: _middleName,
        lastName: _lastName,
        gender: _gender,
        email: _email,
        number: _number,
        firstAddressLine: _firstAddressLine,
        secondAddressLine: _secondAddressLine,
        zipCode: _zipCode,
        city: _city,
        country: _country,
        attachments: _attachments,
      );
      Navigator.pushNamed(context, SplashScreen.routeName);
      await data.setIdentity(identityArgs);
      List<id.IdentityMeta> identities =
          (await data.getIdentitiesMetadata())?.values.toList() ??
              <id.IdentityMeta>[];
      bool isFavorite =
          (await data.getFavoriteIdentities())?[identityArgs.key]?.status ==
              EntryStatus.alive;
      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName(MainScreen.routeName));
      Navigator.pushNamed(context, IdentitiesScreen.routeName,
          arguments: identities);
      Navigator.pushNamed(context, IdentityScreen.routeName,
          arguments:
              EntryScreenArgs(entry: identityArgs, isFavorite: isFavorite));
    }

    if (!_isLoaded) {
      Object? args = ModalRoute.of(context)!.settings.arguments;
      _isNew = args == null;
      if (!_isNew) {
        id.Identity identityArgs = args as id.Identity;
        _key = identityArgs.key;
        _customFields = identityArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured,
                multiline: e.multiline))
            .toList();
        _additionalInfo = identityArgs.additionalInfo;
        _tags = identityArgs.tags;
        _nickname = identityArgs.nickname;
        _title = identityArgs.title;
        _firstName = identityArgs.firstName;
        _middleName = identityArgs.middleName;
        _lastName = identityArgs.lastName;
        _gender = identityArgs.gender;
        _email = identityArgs.email;
        _number = identityArgs.number;
        _firstAddressLine = identityArgs.firstAddressLine;
        _secondAddressLine = identityArgs.secondAddressLine;
        _zipCode = identityArgs.zipCode;
        _city = identityArgs.city;
        _country = identityArgs.country;
        _attachments = identityArgs.attachments;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.identity.toLowerCase(),
        isNew: _isNew,
        onSave: onSave,
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _nickname,
          decoration: InputDecoration(labelText: localizations.nickname),
          onChanged: (value) => setState(() => _nickname = value.trim()),
        )),
        PassyPadding(EnumDropDownButtonFormField<id.Title>(
          value: _title,
          values: id.Title.values,
          decoration: InputDecoration(labelText: localizations.title),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            if (value != null) setState(() => _title = value);
          },
        )),
        PassyPadding(TextFormField(
          initialValue: _firstName,
          decoration: InputDecoration(labelText: localizations.firstName),
          onChanged: (value) => setState(() => _firstName = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _middleName,
          decoration: InputDecoration(labelText: localizations.middleName),
          onChanged: (value) => setState(() => _middleName = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _lastName,
          decoration: InputDecoration(labelText: localizations.lastName),
          onChanged: (value) => setState(() => _lastName = value.trim()),
        )),
        PassyPadding(EnumDropDownButtonFormField<id.Gender>(
          value: _gender,
          values: id.Gender.values,
          itemBuilder: (id.Gender gender) => Text(genderToReadableName(gender)),
          decoration: InputDecoration(labelText: localizations.gender),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            if (value != null) setState(() => _gender = value);
          },
        )),
        PassyPadding(TextFormField(
          initialValue: _email,
          decoration: InputDecoration(labelText: localizations.email),
          onChanged: (value) => setState(() => _email = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _number,
          decoration: InputDecoration(labelText: localizations.phoneNumber),
          onChanged: (value) => setState(() => _number = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _firstAddressLine,
          decoration:
              InputDecoration(labelText: localizations.firstAddresssLine),
          onChanged: (value) =>
              setState(() => _firstAddressLine = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _secondAddressLine,
          decoration:
              InputDecoration(labelText: localizations.secondAddressLine),
          onChanged: (value) =>
              setState(() => _secondAddressLine = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _zipCode,
          decoration: InputDecoration(labelText: localizations.zipCode),
          onChanged: (value) => setState(() => _zipCode = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _city,
          decoration: InputDecoration(labelText: localizations.city),
          onChanged: (value) => setState(() => _city = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _country,
          decoration: InputDecoration(labelText: localizations.country),
          onChanged: (value) => setState(() => _country = value.trim()),
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
