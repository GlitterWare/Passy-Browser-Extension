import 'package:flutter/material.dart';

import '../passy_data/entry_meta.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/id_card.dart';
import '../passy_data/identity.dart';
import '../passy_data/note.dart';
import '../passy_data/password.dart';
import '../passy_data/payment_card.dart';
import 'passy_flutter.dart';

String _nameFromEntry(EntryType type, EntryMeta entry) {
  switch (type) {
    case EntryType.idCard:
      return (entry as IDCardMeta).nickname;
    case EntryType.identity:
      return (entry as IdentityMeta).nickname;
    case EntryType.note:
      return (entry as NoteMeta).title;
    case EntryType.password:
      return (entry as PasswordMeta).nickname;
    case EntryType.paymentCard:
      return (entry as PaymentCardMeta).nickname;
    default:
      return '';
  }
}

String _descriptionFromEntry(EntryType type, EntryMeta entry) {
  switch (type) {
    case EntryType.idCard:
      return (entry as IDCardMeta).name;
    case EntryType.identity:
      return (entry as IdentityMeta).firstAddressLine;
    case EntryType.note:
      return '';
    case EntryType.password:
      return (entry as PasswordMeta).username;
    case EntryType.paymentCard:
      return (entry as PaymentCardMeta).cardholderName;
    default:
      return '';
  }
}

class SearchEntryData {
  final String name;
  final String description;
  final EntryType type;
  final EntryMeta meta;

  SearchEntryData({
    required this.name,
    required this.description,
    required this.type,
    required this.meta,
  });

  SearchEntryData.fromEntry({
    required this.type,
    required this.meta,
  })  : name = _nameFromEntry(type, meta),
        description = _descriptionFromEntry(type, meta);

  static List<SearchEntryData> fromEntries({
    List<IDCardMeta>? idCards,
    List<IdentityMeta>? identities,
    List<NoteMeta>? notes,
    List<PasswordMeta>? passwords,
    List<PaymentCardMeta>? paymentCards,
  }) {
    List<SearchEntryData> result = [];
    idCards?.forEach((idCard) => result.add(SearchEntryData(
        name: idCard.nickname,
        description: idCard.name,
        type: EntryType.idCard,
        meta: idCard)));
    identities?.forEach((identity) => result.add(SearchEntryData(
        name: identity.nickname,
        description: identity.firstAddressLine,
        type: EntryType.identity,
        meta: identity)));
    notes?.forEach((note) => result.add(SearchEntryData(
        name: note.title, description: '', type: EntryType.note, meta: note)));
    passwords?.forEach((password) => result.add(SearchEntryData(
        name: password.nickname,
        description: password.username,
        type: EntryType.password,
        meta: password)));
    paymentCards?.forEach((paymentCard) => result.add(SearchEntryData(
        name: paymentCard.nickname,
        description: paymentCard.cardholderName,
        type: EntryType.paymentCard,
        meta: paymentCard)));
    return result;
  }

  Widget toWidget(
      {void Function()? onPressed,
      List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
          popupMenuItemBuilder}) {
    switch (type) {
      case EntryType.idCard:
        return IDCardButton(
          idCard: meta as IDCardMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.identity:
        return IdentityButton(
          identity: meta as IdentityMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.note:
        return NoteButton(
          note: meta as NoteMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.password:
        return PasswordButton(
          password: meta as PasswordMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.paymentCard:
        return PaymentCardButtonMini(
          paymentCard: meta as PaymentCardMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
    }
  }
}
