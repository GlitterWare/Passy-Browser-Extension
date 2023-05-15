import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/common.dart';
import '../../passy_data/custom_field.dart';
import '../common/common.dart';
import '../passy_flutter.dart';

class CustomFieldsEditor extends StatefulWidget {
  final List<CustomField> customFields;
  final bool shouldSort;
  final EdgeInsetsGeometry padding;
  final ColorScheme? datePickerColorScheme;
  final Future<CustomField?> Function() constructCustomField;

  const CustomFieldsEditor({
    Key? key,
    required this.customFields,
    this.shouldSort = false,
    this.padding = EdgeInsets.zero,
    this.datePickerColorScheme = PassyTheme.datePickerColorScheme,
    required this.constructCustomField,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFieldsEditor();
}

class _CustomFieldsEditor extends State<CustomFieldsEditor> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldSort) PassySort.sortCustomFields(widget.customFields);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PassyPadding(ThreeWidgetButton(
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.add_rounded),
          ),
          center: Text(localizations.addCustomField),
          onPressed: () {
            widget.constructCustomField().then((value) {
              if (value != null) {
                setState(() {
                  widget.customFields.add(value);
                  PassySort.sortCustomFields(widget.customFields);
                });
              }
            });
          },
        )),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.customFields.length,
          itemBuilder: (context, index) {
            List<TextInputFormatter>? inputFormatters;
            CustomField field = widget.customFields[index];
            List<Widget> widgets = [];
            switch (field.fieldType) {
              case (FieldType.number):
                inputFormatters = [FilteringTextInputFormatter.digitsOnly];
                break;
              case (FieldType.date):
                widgets.add(
                  FloatingActionButton(
                    heroTag: null,
                    tooltip: localizations.selectDate,
                    onPressed: () => showPassyDatePicker(
                      context: context,
                      date: field.value == ''
                          ? DateTime.now()
                          : stringToDate(field.value),
                    ).then(
                      (value) {
                        if (value == null) return;
                        setState(() => field.value = dateToString(value));
                      },
                    ),
                    child: const Icon(Icons.date_range),
                  ),
                );
                break;
              case (FieldType.password):
                widgets.add(
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const StringGeneratorDialog(),
                      ).then((value) {
                        if (value == null) return;
                        setState(() => field.value = value);
                      });
                    },
                    tooltip: localizations.generate,
                    child: const Icon(Icons.password_rounded),
                  ),
                );
                break;
              default:
                break;
            }
            widgets.insert(
              0,
              Flexible(
                child: TextFormField(
                  inputFormatters: inputFormatters,
                  initialValue: field.value,
                  decoration: InputDecoration(
                    labelText: field.title,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.0),
                      borderSide:
                          const BorderSide(color: PassyTheme.lightContentColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.0),
                      borderSide: const BorderSide(
                          color: PassyTheme.darkContentSecondaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.0),
                      borderSide:
                          const BorderSide(color: PassyTheme.lightContentColor),
                    ),
                  ),
                  onChanged: (value) => field.value = value,
                  maxLines: field.multiline ? null : 1,
                ),
              ),
            );
            widgets.add(
              FloatingActionButton(
                heroTag: null,
                tooltip: localizations.remove,
                onPressed: () =>
                    setState(() => widget.customFields.removeAt(index)),
                child: const Icon(Icons.remove_rounded),
              ),
            );
            return Padding(
              padding: widget.padding,
              child: Row(
                key: UniqueKey(),
                children: widgets,
              ),
            );
          },
        ),
      ],
    );
  }
}
