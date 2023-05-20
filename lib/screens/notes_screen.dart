import 'package:flutter/material.dart';

import '../common/common.dart';
import '../passy_data/entry_event.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/note.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'common/entry_screen_args.dart';
import 'main_screen.dart';
import 'note_screen.dart';
import 'search_screen.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/notes';

  @override
  State<StatefulWidget> createState() => _NotesScreen();
}

class _NotesScreen extends State<NotesScreen> {
  void _onAddPressed() =>
      Navigator.pushNamed(context, EditNoteScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(builder: (String terms) {
      List<NoteMeta> notesMetadata =
          ModalRoute.of(context)!.settings.arguments as List<NoteMeta>;
      final List<NoteMeta> found = [];
      final List<String> termsSplit = terms.trim().toLowerCase().split(' ');
      for (NoteMeta note in notesMetadata) {
        {
          bool testNote(NoteMeta value) => note.key == value.key;

          if (found.any(testNote)) continue;
        }
        {
          int positiveCount = 0;
          for (String term in termsSplit) {
            if (note.title.toLowerCase().contains(term)) {
              positiveCount++;
              continue;
            }
          }
          if (positiveCount == termsSplit.length) {
            found.add(note);
          }
        }
      }
      if (found.isEmpty) {
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: [
                  const Spacer(flex: 7),
                  Text(
                    localizations.noSearchResults,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 7),
                ],
              ),
            ),
          ],
        );
      }
      return NoteButtonListView(
        notes: found,
        shouldSort: true,
        onPressed: (noteMeta) async {
          Note? note = await data.getNote(noteMeta.key);
          if (note == null) return;
          bool isFavorite =
              (await data.getFavoriteNotes())?[noteMeta.key]?.status ==
                  EntryStatus.alive;
          if (mounted) {
            Navigator.pushNamed(
              context,
              NoteScreen.routeName,
              arguments: EntryScreenArgs(entry: note, isFavorite: isFavorite),
            );
          }
        },
        popupMenuItemBuilder: notePopupMenuBuilder,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    List<NoteMeta> notes =
        ModalRoute.of(context)!.settings.arguments as List<NoteMeta>;
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.note,
          title: Center(child: Text(localizations.notes)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: notes.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noNotes,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditNoteScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : NoteButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addNote,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () =>
                        Navigator.pushNamed(context, EditNoteScreen.routeName),
                  ),
                ),
              ],
              notes: notes,
              shouldSort: true,
              onPressed: (noteMeta) async {
                Note? note = await data.getNote(noteMeta.key);
                if (note == null) return;
                bool isFavorite =
                    (await data.getFavoriteNotes())?[noteMeta.key]?.status ==
                        EntryStatus.alive;
                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    NoteScreen.routeName,
                    arguments:
                        EntryScreenArgs(entry: note, isFavorite: isFavorite),
                  );
                }
              },
              popupMenuItemBuilder: notePopupMenuBuilder,
            ),
    );
  }
}
