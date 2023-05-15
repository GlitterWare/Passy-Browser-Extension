import 'package:passy_browser_extension/passy_data/password.dart';

class PassySearch {
  static List<PasswordMeta> searchPasswords(
      {required Iterable<PasswordMeta> passwords, required String terms}) {
    final List<PasswordMeta> found = [];
    final List<String> terms0 = terms.trim().toLowerCase().split(' ');
    for (PasswordMeta password in passwords) {
      {
        bool testPassword(PasswordMeta value) => password.key == value.key;

        if (found.any(testPassword)) continue;
      }
      {
        int positiveCount = 0;
        for (String term in terms0) {
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
        if (positiveCount == terms0.length) {
          found.add(password);
        }
      }
    }
    return found;
  }
}
