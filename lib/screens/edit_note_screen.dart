import 'package:flutter/material.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/note.dart';
import '../passy_flutter/passy_flutter.dart';
import 'note_screen.dart';
import 'notes_screen.dart';
import 'splash_screen.dart';
import 'main_screen.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({Key? key}) : super(key: key);

  static const routeName = '${NoteScreen.routeName}/edit';

  @override
  State<StatefulWidget> createState() => _EditNoteScreen();
}

class _EditNoteScreen extends State<EditNoteScreen> {
  bool _isLoaded = false;
  bool _isNew = true;

  String? _key;
  String _title = '';
  String _note = '';

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? args = ModalRoute.of(context)!.settings.arguments;
      _isNew = args == null;
      if (!_isNew) {
        Note noteArgs = args as Note;
        _key = noteArgs.key;
        _title = noteArgs.title;
        _note = noteArgs.note;
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.note.toLowerCase(),
        isNew: _isNew,
        onSave: () async {
          Note noteArgs = Note(
            key: _key,
            title: _title,
            note: _note,
          );
          Navigator.pushNamed(context, SplashScreen.routeName);
          await data.setNote(noteArgs);
          List<NoteMeta> notes =
              (await data.getNotesMetadata())?.values.toList() ?? <NoteMeta>[];
          bool isFavorite =
              (await data.getFavoriteNotes())?[noteArgs.key]?.status ==
                  EntryStatus.alive;
          if (!mounted) return;
          Navigator.popUntil(
              context, ModalRoute.withName(MainScreen.routeName));
          Navigator.pushNamed(context, NotesScreen.routeName, arguments: notes);
          Navigator.pushNamed(context, NoteScreen.routeName,
              arguments:
                  EntryScreenArgs(entry: noteArgs, isFavorite: isFavorite));
        },
      ),
      body: ListView(children: [
        PassyPadding(TextFormField(
          initialValue: _title,
          decoration: InputDecoration(labelText: localizations.title),
          onChanged: (value) => setState(() => _title = value.trim()),
        )),
        PassyPadding(TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          initialValue: _note,
          decoration: InputDecoration(
            labelText: localizations.note,
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
          onChanged: (value) => setState(() => _note = value),
        )),
      ]),
    );
  }
}
