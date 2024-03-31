import 'package:flutter/foundation.dart';
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
  List<String> _tags = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditNoteScreen.routeName);

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(
      context,
      SearchScreen.routeName,
      arguments: SearchScreenArgs(
        entryType: EntryType.note,
        selectedTags: tag == null ? [] : [tag],
        builder: (String terms, List<String> tags, void Function() rebuild) {
          final List<NoteMeta> found = [];
          final List<String> termsList = terms.trim().toLowerCase().split(' ');
          final List<NoteMeta> notes =
              ModalRoute.of(context)!.settings.arguments as List<NoteMeta>;
          for (NoteMeta note in notes) {
            {
              bool testNote(NoteMeta value) => note.key == value.key;

              if (found.any(testNote)) continue;
            }
            {
              bool tagMismatch = false;
              for (String tag in tags) {
                if (!note.tags.contains(tag)) {
                  tagMismatch = true;
                  break;
                }
              }
              if (tagMismatch) continue;
              int positiveCount = 0;
              for (String term in termsList) {
                if (note.title.toLowerCase().contains(term)) {
                  positiveCount++;
                  continue;
                }
              }
              if (positiveCount == termsList.length) {
                found.add(note);
              }
            }
          }
          if (found.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
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
                  (await data.getFavoriteIDCards())?[note.key]?.status ==
                      EntryStatus.alive;
              if (!mounted) return;
              Navigator.pushNamed(
                context,
                NoteScreen.routeName,
                arguments: EntryScreenArgs(entry: note, isFavorite: isFavorite),
              );
            },
            popupMenuItemBuilder: notePopupMenuBuilder,
          );
        },
      ),
    );
  }

  Future<void> _load() async {
    _isLoaded = true;
    _isLoading = true;
    List<String> newTags;
    try {
      newTags = await data.notesTags;
    } catch (_) {
      return;
    }
    newTags.sort();
    if (listEquals(newTags, _tags)) {
      return;
    }
    if (mounted) {
      setState(() {
        _tags = newTags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) _load().whenComplete(() => _isLoading = false);
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
                if (_tags.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: PassyTheme.passyPadding.top / 2,
                          bottom: PassyTheme.passyPadding.bottom / 2),
                      child: EntryTagList(
                        notSelected: _tags,
                        onAdded: (tag) => setState(() {
                          _onSearchPressed(tag: tag);
                        }),
                      ),
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
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    NoteScreen.routeName,
                    arguments:
                        EntryScreenArgs(entry: note, isFavorite: isFavorite),
                  ).then((value) {
                    if (_isLoading) return;
                    _load().then((value) => _isLoading = false);
                  });
                  
                }
              },
              popupMenuItemBuilder: notePopupMenuBuilder,
            ),
    );
  }
}
