import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../passy_flutter.dart';

class RecordDialog extends StatelessWidget {
  final String value;
  final bool highlightSpecial;
  final TextAlign textAlign;
  final ShapeBorder? shape;
  final Color? specialColor;

  const RecordDialog({
    Key? key,
    required this.value,
    this.highlightSpecial = false,
    this.textAlign = TextAlign.center,
    this.shape = PassyTheme.dialogShape,
    this.specialColor = PassyTheme.lightContentSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (highlightSpecial) {
      List<InlineSpan> children = [];
      Iterator<String> iterator = value.characters.iterator;
      while (iterator.moveNext()) {
        if (iterator.current.contains(RegExp(r'[a-z]|[A-Z]'))) {
          children.add(TextSpan(
            text: iterator.current,
            style: GoogleFonts.firaCode(
              textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ));
        } else {
          children.add(TextSpan(
            text: iterator.current,
            style: GoogleFonts.firaCode(
              textStyle: Theme.of(context).textTheme.bodyMedium,
              color: specialColor,
            ),
          ));
        }
      }
      content = SelectableText.rich(
        TextSpan(text: '', children: children),
        textAlign: textAlign,
      );
    } else {
      content = SelectableText(
        value,
        textAlign: textAlign,
        style: GoogleFonts.firaCode(
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return AlertDialog(shape: shape, content: content);
  }
}
