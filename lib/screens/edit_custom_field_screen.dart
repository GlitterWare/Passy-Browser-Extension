import 'package:flutter/material.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_flutter/passy_flutter.dart';

class EditCustomFieldScreen extends StatefulWidget {
  const EditCustomFieldScreen({Key? key}) : super(key: key);

  static const routeName = '/editCustomField';

  @override
  State<StatefulWidget> createState() => _EditCustomFieldScreen();
}

class _EditCustomFieldScreen extends State<EditCustomFieldScreen> {
  final CustomField _customField = CustomField();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.customField.toLowerCase(),
        onSave: () => Navigator.pop(context, _customField),
        isNew: true,
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _customField.title,
          decoration: InputDecoration(labelText: localizations.title),
          onChanged: (value) => setState(() => _customField.title = value),
        )),
        PassyPadding(DropdownButtonFormField(
          items: [
            DropdownMenuItem(
              value: FieldType.text,
              child: Text(FieldType.text.name[0].toUpperCase() +
                  FieldType.text.name.substring(1)),
            ),
            DropdownMenuItem(
              value: FieldType.number,
              child: Text(FieldType.number.name[0].toUpperCase() +
                  FieldType.number.name.substring(1)),
            ),
            DropdownMenuItem(
              value: FieldType.password,
              child: Text(FieldType.password.name[0].toUpperCase() +
                  FieldType.password.name.substring(1)),
            ),
            DropdownMenuItem(
              value: FieldType.date,
              child: Text(FieldType.date.name[0].toUpperCase() +
                  FieldType.date.name.substring(1)),
            ),
          ],
          value: _customField.fieldType,
          decoration: InputDecoration(labelText: localizations.type),
          onChanged: (value) => _customField.fieldType = value as FieldType,
        )),
        PassyPadding(DropdownButtonFormField(
          items: [
            DropdownMenuItem(
              value: false,
              child: Text(localizations.false_),
            ),
            DropdownMenuItem(
              value: true,
              child: Text(localizations.true_),
            ),
          ],
          value: _customField.obscured,
          decoration: InputDecoration(labelText: localizations.obscured),
          onChanged: (value) => _customField.obscured = value as bool,
        )),
        PassyPadding(DropdownButtonFormField(
          items: [
            DropdownMenuItem(
              value: false,
              child: Text(localizations.false_),
            ),
            DropdownMenuItem(
              value: true,
              child: Text(localizations.true_),
            ),
          ],
          value: _customField.obscured,
          decoration: InputDecoration(labelText: localizations.multiline),
          onChanged: (value) => _customField.multiline = value as bool,
        )),
      ]),
    );
  }
}
