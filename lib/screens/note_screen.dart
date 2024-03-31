import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

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
  List<String> _tags = [];
  List<String> _selected = [];
  bool _tagsLoaded = false;
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

  Future<void> _load(Note note) async {
    List<String> newTags = await data.notesTags;
    newTags.sort();
    if (mounted) {
      setState(() {
        _tags = newTags;
        _selected = note.tags.toList();
        _selected.sort();
        for (String tag in _selected) {
          if (_tags.contains(tag)) {
            _tags.remove(tag);
          }
        }
        _tagsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final EntryScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as EntryScreenArgs;
    final Note note = args.entry as Note;
    if (!isLoaded) {
      isLoaded = true;
      _load(note);
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
              showSnackBar(
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
              showSnackBar(
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
        Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: PassyTheme.passyPadding.top / 2,
                bottom: PassyTheme.passyPadding.bottom / 2),
            child: !_tagsLoaded
                ? const CircularProgressIndicator()
                : EntryTagList(
                    showAddButton: true,
                    selected: _selected,
                    notSelected: _tags,
                    onSecondary: (tag) async {
                      String? newTag = await showDialog(
                        context: context,
                        builder: (ctx) => RenameTagDialog(tag: tag),
                      );
                      if (newTag == null) return;
                      if (newTag == tag) return;
                      if (!context.mounted) return;
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      try {
                        bool result =
                            await data.renameTag(tag: tag, newTag: newTag);
                        if (!result) throw Exception('Not implemented');
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                        showSnackBar(
                          message: localizations.somethingWentWrong,
                          icon: const Icon(Icons.error_outline_rounded,
                              color: PassyTheme.darkContentColor),
                        );
                        return;
                      }
                      note.tags = _selected.toList();
                      if (note.tags.contains(tag)) {
                        note.tags.remove(tag);
                        note.tags.add(newTag);
                      }
                      List<NoteMeta> notes =
                          (await data.getNotesMetadata())?.values.toList() ??
                              <NoteMeta>[];
                      if (!context.mounted) return;
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, NotesScreen.routeName,
                          arguments: notes);
                      Navigator.pushNamed(context, NoteScreen.routeName,
                          arguments: note);
                    },
                    onAdded: (tag) async {
                      if (note.tags.contains(tag)) return;
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      note.tags = _selected.toList();
                      note.tags.add(tag);
                      await data.setNote(note);
                      List<NoteMeta> notes =
                          (await data.getNotesMetadata())?.values.toList() ??
                              <NoteMeta>[];
                      if (!context.mounted) return;
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, NotesScreen.routeName,
                          arguments: notes);
                      Navigator.pushNamed(
                        context,
                        NoteScreen.routeName,
                        arguments: EntryScreenArgs(
                            entry: note, isFavorite: isFavorite),
                      );
                    },
                    onRemoved: (tag) async {
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      note.tags = _selected.toList();
                      note.tags.remove(tag);
                      await data.setNote(note);
                      List<NoteMeta> notes =
                          (await data.getNotesMetadata())?.values.toList() ??
                              <NoteMeta>[];
                      if (!context.mounted) return;
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, NotesScreen.routeName,
                          arguments: notes);
                      Navigator.pushNamed(
                        context,
                        NotesScreen.routeName,
                        arguments: EntryScreenArgs(
                            entry: note, isFavorite: isFavorite),
                      );
                    },
                  ),
          ),
        ),
        if (note.title != '')
          PassyPadding(
              RecordButton(title: localizations.title, value: note.title)),
        if (note.note != '')
          if (!note.isMarkdown)
            PassyPadding(RecordButton(
              title: localizations.note,
              value: note.note,
              valueAlign: TextAlign.left,
            )),
        if (note.isMarkdown)
          PassyPadding(Text(
            localizations.note,
            style:
                const TextStyle(color: PassyTheme.lightContentSecondaryColor),
          )),
        if (note.isMarkdown)
          Padding(
            padding: EdgeInsets.fromLTRB(20, PassyTheme.passyPadding.top,
                PassyTheme.passyPadding.right, PassyTheme.passyPadding.bottom),
            child: MarkdownBody(
              data: note.note,
              selectable: true,
              extensionSet: md.ExtensionSet(
                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                <md.InlineSyntax>[
                  md.EmojiSyntax(),
                  ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                ],
              ),
            ),
          ),
      ]),
    );
  }
}
