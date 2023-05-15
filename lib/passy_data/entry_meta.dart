import 'entry_type.dart';
import 'json_convertable.dart';
import 'password.dart';
import 'payment_card.dart';
import 'id_card.dart';
import 'identity.dart';
import 'note.dart';

abstract class EntryMeta with JsonConvertable {
  final String key;

  EntryMeta(this.key);

  static EntryMeta Function(Map<String, dynamic> json) fromJson(
      EntryType type) {
    switch (type) {
      case EntryType.password:
        return PasswordMeta.fromJson;
      case EntryType.paymentCard:
        return PaymentCardMeta.fromJson;
      case EntryType.note:
        return NoteMeta.fromJson;
      case EntryType.idCard:
        return IDCardMeta.fromJson;
      case EntryType.identity:
        return IdentityMeta.fromJson;
    }
  }
}
