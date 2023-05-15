import 'entry_event.dart';
import 'entry_type.dart';
import 'json_convertable.dart';

class Favorites with JsonConvertable {
  final Map<String, EntryEvent> passwords;
  final Map<String, EntryEvent> paymentCards;
  final Map<String, EntryEvent> notes;
  final Map<String, EntryEvent> idCards;
  final Map<String, EntryEvent> identities;

  int get length =>
      passwords.length +
      paymentCards.length +
      notes.length +
      idCards.length +
      identities.length;

  bool get hasFavorites {
    for (EntryEvent event in passwords.values) {
      if (event.status == EntryStatus.alive) return true;
    }
    for (EntryEvent event in paymentCards.values) {
      if (event.status == EntryStatus.alive) return true;
    }
    for (EntryEvent event in notes.values) {
      if (event.status == EntryStatus.alive) return true;
    }
    for (EntryEvent event in idCards.values) {
      if (event.status == EntryStatus.alive) return true;
    }
    for (EntryEvent event in identities.values) {
      if (event.status == EntryStatus.alive) return true;
    }
    return false;
  }

  Favorites({
    //this.version = 0,
    Map<String, EntryEvent>? passwords,
    Map<String, EntryEvent>? passwordIcons,
    Map<String, EntryEvent>? paymentCards,
    Map<String, EntryEvent>? notes,
    Map<String, EntryEvent>? idCards,
    Map<String, EntryEvent>? identities,
  })  : passwords = passwords ?? {},
        notes = notes ?? {},
        paymentCards = paymentCards ?? {},
        idCards = idCards ?? {},
        identities = identities ?? {};

  Favorites.from(Favorites other)
      : //version = other.version,
        passwords = Map<String, EntryEvent>.from(other.passwords),
        paymentCards = Map<String, EntryEvent>.from(other.paymentCards),
        notes = Map<String, EntryEvent>.from(other.notes),
        idCards = Map<String, EntryEvent>.from(other.idCards),
        identities = Map<String, EntryEvent>.from(other.identities);

  Favorites.fromJson(Map<String, dynamic> json)
      : //version = int.tryParse(json['version']) ?? 0,
        passwords = (json['passwords'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        paymentCards = (json['paymentCards'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        notes = (json['notes'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        idCards = (json['idCards'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        identities = (json['identities'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value)));

  @override
  Map<String, dynamic> toJson() => {
        //'version': version.toString(),
        'passwords': passwords.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'paymentCards': paymentCards.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'notes': notes.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'idCards': idCards.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'identities': identities.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
      };

  Map<String, EntryEvent> getEvents(EntryType type) {
    switch (type) {
      case EntryType.password:
        return passwords;
      case EntryType.paymentCard:
        return paymentCards;
      case EntryType.note:
        return notes;
      case EntryType.idCard:
        return idCards;
      case EntryType.identity:
        return identities;
      default:
        return {};
    }
  }

  void clearRemoved() {
    passwords.removeWhere((key, value) => value.status == EntryStatus.removed);
    paymentCards
        .removeWhere((key, value) => value.status == EntryStatus.removed);
    notes.removeWhere((key, value) => value.status == EntryStatus.removed);
    idCards.removeWhere((key, value) => value.status == EntryStatus.removed);
    identities.removeWhere((key, value) => value.status == EntryStatus.removed);
  }

  void renew() {
    DateTime time = DateTime.now().toUtc();
    passwords.forEach((key, value) => value.lastModified = time);
    paymentCards.forEach((key, value) => value.lastModified = time);
    notes.forEach((key, value) => value.lastModified = time);
    idCards.forEach((key, value) => value.lastModified = time);
    identities.forEach((key, value) => value.lastModified = time);
  }
}
