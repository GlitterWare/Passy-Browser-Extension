import '../passy_data/custom_field.dart';
import '../passy_data/id_card.dart';
import '../passy_data/identity.dart';
import '../passy_data/note.dart';
import '../passy_data/password.dart';
import '../passy_data/payment_card.dart';
import 'common/common.dart';
import 'passy_flutter.dart';

class PassySort {
  static void sortPasswords(List<PasswordMeta> passwords) {
    passwords.sort((a, b) {
      int nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (nickComp == 0) {
        return alphabeticalCompare(a.username, b.username);
      }
      return nickComp;
    });
  }

  static void sortCustomFields(List<CustomField> customFields) {
    customFields.sort(
      (a, b) => alphabeticalCompare(a.title, b.title),
    );
  }

  static void sortPaymentCards(List<PaymentCardMeta> paymentCards) {
    paymentCards.sort((a, b) {
      int nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (nickComp == 0) {
        return alphabeticalCompare(a.cardholderName, b.cardholderName);
      }
      return nickComp;
    });
  }

  static void sortNotes(List<NoteMeta> notes) =>
      notes.sort((a, b) => alphabeticalCompare(a.title, b.title));

  static void sortIDCards(List<IDCardMeta> idCards) {
    idCards.sort((a, b) {
      int nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (nickComp == 0) {
        return alphabeticalCompare(a.name, b.name);
      }
      return nickComp;
    });
  }

  static void sortIdentities(List<IdentityMeta> identities) {
    identities.sort((a, b) {
      int nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (nickComp == 0) {
        return alphabeticalCompare(a.firstAddressLine, b.firstAddressLine);
      }
      return nickComp;
    });
  }

  static void sortEntries(List<SearchEntryData> entries) {
    entries.sort((a, b) {
      int nameComp = alphabeticalCompare(a.name, b.name);
      if (nameComp == 0) {
        return alphabeticalCompare(a.description, b.description);
      }
      return nameComp;
    });
  }
}
