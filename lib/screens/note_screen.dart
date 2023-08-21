import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../common/common.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/note.dart';
import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/entry_screen_args.dart';
import 'main_screen.dart';
import 'edit_note_screen.dart';
import 'notes_screen.dart';
import 'splash_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  static const routeName = '/note';

  @override
  State<StatefulWidget> createState() => _NoteScreen();
}

class _NoteScreen extends State<NoteScreen> {
  bool isFavorite = false;
  bool isLoaded = false;

  void _onRemovePressed(Note note) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removeNote),
            content:
                Text('${localizations.notesCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () async {
                  Navigator.pushNamed(context, SplashScreen.routeName);
                  await data.removeNote(note.key);
                  List<NoteMeta> notes =
                      (await data.getNotesMetadata())?.values.toList() ??
                          <NoteMeta>[];
                  if (!mounted) return;
                  Navigator.popUntil(
                      context, (r) => r.settings.name == MainScreen.routeName);
                  Navigator.pushNamed(context, NotesScreen.routeName,
                      arguments: notes);
                },
              )
            ],
          );
        });
  }

  void _onEditPressed(Note note) {
    Navigator.pushNamed(
      context,
      EditNoteScreen.routeName,
      arguments: note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final EntryScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as EntryScreenArgs;
    final Note note = args.entry as Note;
    if (!isLoaded) {
      isLoaded = true;
      isFavorite = args.isFavorite;
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.note,
        entryKey: note.key,
        title: Center(child: Text(localizations.note)),
        onRemovePressed: () => _onRemovePressed(note),
        onEditPressed: () => _onEditPressed(note),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await data.toggleFavoriteNote(note.key, false);
            setState(() => isFavorite = false);
            if (mounted) {
              showSnackBar(context,
                  message: localizations.removedFromFavorites,
                  icon: const Icon(
                    Symbols.star_rounded,
                    weight: 700,
                    color: PassyTheme.darkContentColor,
                  ));
            }
          } else {
            await data.toggleFavoriteNote(note.key, true);
            setState(() => isFavorite = true);
            if (mounted) {
              showSnackBar(context,
                  message: localizations.addedToFavorites,
                  icon: const Icon(
                    Symbols.star_rounded,
                    weight: 700,
                    fill: 1,
                    color: PassyTheme.darkContentColor,
                  ));
            }
          }
          setState(() {});
        },
      ),
      body: ListView(children: [
        if (note.title != '')
          PassyPadding(
              RecordButton(title: localizations.title, value: note.title)),
        if (note.note != '')
          PassyPadding(RecordButton(
            title: localizations.note,
            value: note.note,
            valueAlign: TextAlign.left,
          )),
      ]),
    );
  }
}
