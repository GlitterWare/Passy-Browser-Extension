import 'package:flutter/material.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/id_card.dart';
import '../passy_flutter/passy_flutter.dart';
import 'edit_custom_field_screen.dart';
import 'id_cards_screen.dart';
import 'splash_screen.dart';
import 'id_card_screen.dart';
import 'main_screen.dart';

class EditIDCardScreen extends StatefulWidget {
  const EditIDCardScreen({Key? key}) : super(key: key);

  static const routeName = '${IDCardScreen.routeName}/editIDCard';

  @override
  State<StatefulWidget> createState() => _EditIDCardScreen();
}

class _EditIDCardScreen extends State<EditIDCardScreen> {
  bool _isLoaded = false;
  bool _isNew = false;

  String? _key;
  List<CustomField> _customFields = [];
  String _additionalInfo = '';
  List<String> _tags = [];
  String _nickname = '';
  List<String> _pictures = [];
  String _type = '';
  String _idNumber = '';
  String _name = '';
  String _issDate = '';
  String _expDate = '';
  String _country = '';
  List<String> _attachments = [];

  void _onSave() async {
    IDCard idCardArgs = IDCard(
      key: _key,
      customFields: _customFields,
      additionalInfo: _additionalInfo,
      tags: _tags,
      nickname: _nickname,
      pictures: _pictures,
      type: _type,
      idNumber: _idNumber,
      name: _name,
      issDate: _issDate,
      expDate: _expDate,
      country: _country,
            attachments: _attachments,
    );
    Navigator.pushNamed(context, SplashScreen.routeName);
    await data.setIDCard(idCardArgs);
    List<IDCardMeta> idCards =
        (await data.getIDCardsMetadata())?.values.toList() ?? <IDCardMeta>[];
    bool isFavorite =
        (await data.getFavoriteIDCards())?[idCardArgs.key]?.status ==
            EntryStatus.alive;
    if (!mounted) return;
    Navigator.popUntil(context, ModalRoute.withName(MainScreen.routeName));
    Navigator.pushNamed(context, IDCardsScreen.routeName, arguments: idCards);
    Navigator.pushNamed(context, IDCardScreen.routeName,
        arguments: EntryScreenArgs(entry: idCardArgs, isFavorite: isFavorite));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? args = ModalRoute.of(context)!.settings.arguments;
      _isNew = args == null;
      if (!_isNew) {
        IDCard idCardArgs = args as IDCard;
        _key = idCardArgs.key;
        _customFields = idCardArgs.customFields
            .map((e) => CustomField(
                title: e.title,
                fieldType: e.fieldType,
                value: e.value,
                obscured: e.obscured,
                multiline: e.multiline))
            .toList();
        _additionalInfo = idCardArgs.additionalInfo;
        _tags = idCardArgs.tags;
        _nickname = idCardArgs.nickname;
        _pictures = idCardArgs.pictures;
        _type = idCardArgs.type;
        _idNumber = idCardArgs.idNumber;
        _name = idCardArgs.name;
        _issDate = idCardArgs.issDate;
        _expDate = idCardArgs.expDate;
        _country = idCardArgs.country;
        _attachments = idCardArgs.attachments;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.idCard,
        onSave: _onSave,
        isNew: _isNew,
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _nickname,
          decoration: InputDecoration(labelText: localizations.nickname),
          onChanged: (value) => setState(() => _nickname = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _type,
          decoration: InputDecoration(labelText: localizations.type),
          onChanged: (value) => setState(() => _type = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _idNumber,
          decoration: InputDecoration(labelText: localizations.idNumber),
          onChanged: (value) => setState(() => _idNumber = value.trim()),
        )),
        PassyPadding(TextFormField(
          initialValue: _name,
          decoration: InputDecoration(labelText: localizations.name),
          onChanged: (value) => setState(() => _name = value.trim()),
        )),
        PassyPadding(MonthPickerFormField(
          key: UniqueKey(),
          initialValue: _issDate,
          title: localizations.dateOfIssue,
          getSelectedDate: () {
            DateTime now = DateTime.now();
            List<String> date = _issDate.split('/');
            if (date.length < 2) return DateTime.now();
            String month = date[0];
            String year = date[1];
            if (month[0] == '0') {
              month = month[1];
            }
            int? monthDecoded = int.tryParse(month);
            if (monthDecoded == null) return now;
            int? yearDecoded = int.tryParse(year);
            if (yearDecoded == null) return now;
            if (yearDecoded < now.year) yearDecoded = now.year;
            return DateTime.utc(yearDecoded, monthDecoded);
          },
          onChanged: (selectedDate) {
            String month = selectedDate.month.toString();
            String year = selectedDate.year.toString();
            if (month.length == 1) month = '0$month';
            setState(() => _issDate = '$month/$year');
          },
        )),
        PassyPadding(MonthPickerFormField(
          key: UniqueKey(),
          initialValue: _expDate,
          title: localizations.expirationDate,
          getSelectedDate: () {
            DateTime now = DateTime.now();
            List<String> date = _expDate.split('/');
            if (date.length < 2) return DateTime.now();
            String month = date[0];
            String year = date[1];
            if (month[0] == '0') {
              month = month[1];
            }
            int? monthDecoded = int.tryParse(month);
            if (monthDecoded == null) return now;
            int? yearDecoded = int.tryParse(year);
            if (yearDecoded == null) return now;
            if (yearDecoded < now.year) yearDecoded = now.year;
            return DateTime.utc(yearDecoded, monthDecoded);
          },
          onChanged: (selectedDate) {
            String month = selectedDate.month.toString();
            String year = selectedDate.year.toString();
            if (month.length == 1) month = '0$month';
            setState(() => _expDate = '$month/$year');
          },
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
