import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';

import '../../common/common.dart';
import '../common/common.dart';
import '../passy_flutter.dart';

class MonthPickerFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final TextStyle buttonStyle;
  final TextStyle currentDateStyle;
  final TextStyle selectedDateStyle;
  final String title;
  final DateTime Function()? getSelectedDate;
  final Function(DateTime)? onChanged;

  const MonthPickerFormField({
    Key? key,
    this.controller,
    this.initialValue,
    TextStyle? buttonStyle,
    TextStyle? currentDateStyle,
    TextStyle? selectedDateStyle,
    this.title = '',
    this.getSelectedDate,
    this.onChanged,
  })  : buttonStyle = buttonStyle ??
            const TextStyle(color: PassyTheme.lightContentSecondaryColor),
        currentDateStyle = currentDateStyle ??
            const TextStyle(color: PassyTheme.lightContentSecondaryColor),
        selectedDateStyle = selectedDateStyle ??
            const TextStyle(color: PassyTheme.lightContentSecondaryColor),
        super(key: key);

  @override
  Widget build(context) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: title),
        initialValue: initialValue,
        focusNode: AlwaysDisabledFocusNode(),
        onTap: () => showDialog(
              context: context,
              builder: (ctx) {
                DateTime selectedDate = getSelectedDate == null
                    ? DateTime.now().toUtc()
                    : getSelectedDate!();
                return AlertDialog(
                  shape: PassyTheme.dialogShape,
                  title: Text(title),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          localizations.cancel,
                          style: buttonStyle,
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, selectedDate),
                        child: Text(
                          localizations.confirm,
                          style: buttonStyle,
                        )),
                  ],
                  content: StatefulBuilder(
                    builder: (ctx, setState) {
                      return MonthPicker.single(
                        selectedDate: selectedDate,
                        firstDate: DateTime.utc(-271820),
                        lastDate: DateTime.utc(275760),
                        onChanged: (date) {
                          setState(() => selectedDate = date);
                        },
                        datePickerStyles: DatePickerStyles(
                            currentDateStyle: currentDateStyle,
                            selectedDateStyle: selectedDateStyle),
                      );
                    },
                  ),
                );
              },
            ).then((value) {
              if (onChanged == null) return;
              if (value == null) return;
              onChanged!(value);
            }));
  }
}
