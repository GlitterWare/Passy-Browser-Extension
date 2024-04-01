import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
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
  bool _isMarkdown = false;
  List<String> _attachments = [];

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
        _isMarkdown = noteArgs.isMarkdown;
        _attachments = noteArgs.attachments;
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
            isMarkdown: _isMarkdown,
            attachments: _attachments,
          );
          Navigator.pushNamed(context, SplashScreen.routeName);
          await data.setNote(noteArgs);
          List<NoteMeta> notes =
              (await data.getNotesMetadata())?.values.toList() ?? <NoteMeta>[];
          bool isFavorite =
              (await data.getFavoriteNotes())?[noteArgs.key]?.status ==
                  EntryStatus.alive;
          if (!context.mounted) return;
          Navigator.popUntil(
              context, ModalRoute.withName(MainScreen.routeName));
          Navigator.pushNamed(context, NotesScreen.routeName, arguments: notes);
          Navigator.pushNamed(context, NoteScreen.routeName,
              arguments:
                  EntryScreenArgs(entry: noteArgs, isFavorite: isFavorite));
        },
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.enableMarkdown),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.arrow_downward_rounded),
          ),
          right: Switch(
            activeColor: Colors.greenAccent,
            value: _isMarkdown,
            onChanged: (value) => setState(() => _isMarkdown = value),
          ),
          onPressed: () => setState(() => _isMarkdown = !_isMarkdown),
        )),
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
        if (_isMarkdown)
          PassyPadding(Text(
            localizations.markdownPreview,
            style:
                const TextStyle(color: PassyTheme.lightContentSecondaryColor),
          )),
        if (_isMarkdown)
          Padding(
              padding: EdgeInsets.fromLTRB(
                  20,
                  PassyTheme.passyPadding.top,
                  PassyTheme.passyPadding.right,
                  PassyTheme.passyPadding.bottom),
              child: MarkdownBody(
                data: _note,
                selectable: true,
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                  <md.InlineSyntax>[
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                  ],
                ),
              )),
      ]),
    );
  }
}
