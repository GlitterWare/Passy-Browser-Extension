import 'entry_meta.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';

typedef Notes = PassyEntries<Note>;

class NoteMeta extends EntryMeta {
  final String title;

  NoteMeta({required String key, required this.title}) : super(key);

  NoteMeta.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        super(json['key'] ?? '');

  @override
  toJson() => {
        'key': key,
        'title': title,
      };
}

class Note extends PassyEntry<Note> {
  String title;
  String note;

  Note({
    String? key,
    this.title = '',
    this.note = '',
  }) : super(key ?? DateTime.now().toUtc().toIso8601String());

  @override
  EntryMeta get metadata => NoteMeta(key: key, title: title);

  Note.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        note = json['note'] ?? '',
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Note.fromCSV(List csv)
      : title = csv[1] ?? '',
        note = csv[2] ?? '',
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  @override
  int compareTo(Note other) => title.compareTo(other.title);

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'note': note,
      };

  @override
  List toCSV() => [
        key,
        title,
        note,
      ];
}
