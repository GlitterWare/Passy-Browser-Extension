import 'package:passy_browser_extension/passy_data/password.dart';

class PassySearch {
  static List<PasswordMeta> searchPasswords({
    required Iterable<PasswordMeta> passwords,
    required String terms,
    List<String> tags = const [],
  }) {
    final List<PasswordMeta> found = [];
    final List<String> termsSplit = terms.trim().toLowerCase().split(' ');
    for (PasswordMeta password in passwords) {
      if (password.tags.length < tags.length) continue;
      {
        bool testPassword(PasswordMeta value) => password.key == value.key;

        if (found.any(testPassword)) continue;
      }
      {
        int positiveCount = 0;
        bool tagMismatch = false;
        for (String tag in tags) {
          if (!password.tags.contains(tag)) {
            tagMismatch = true;
            break;
          }
        }
        if (tagMismatch) continue;
        for (String term in termsSplit) {
          if (password.username.toLowerCase().contains(term)) {
            positiveCount++;
            continue;
          }
          if (password.nickname.toLowerCase().contains(term)) {
            positiveCount++;
            continue;
          }
          if (password.website.toLowerCase().contains(term)) {
            positiveCount++;
            continue;
          }
        }
        if (positiveCount == termsSplit.length) {
          found.add(password);
        }
      }
    }
    return found;
  }
}
