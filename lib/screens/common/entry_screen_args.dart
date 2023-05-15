import 'package:passy_browser_extension/passy_data/passy_entry.dart';

class EntryScreenArgs {
  final PassyEntry entry;
  final bool isFavorite;

  EntryScreenArgs({
    required this.entry,
    required this.isFavorite,
  });
}
