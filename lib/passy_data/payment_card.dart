import 'custom_field.dart';
import 'entry_meta.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';

typedef PaymentCards = PassyEntries<PaymentCard>;

class PaymentCardMeta extends EntryMeta {
  final List<String> tags;
  final String nickname;
  final String cardNumber;
  final String cardholderName;
  final String exp;

  PaymentCardMeta({
    required String key,
    required this.tags,
    required this.nickname,
    required this.cardNumber,
    required this.cardholderName,
    required this.exp,
  }) : super(key);

  PaymentCardMeta.fromJson(Map<String, dynamic> json)
      : tags = json.containsKey('tags')
            ? json['tags'].map<String>((e) => e.toString()).toList()
            : const [],
        nickname = json['nickname'] ?? '',
        cardNumber = json['cardNumber'] ?? '',
        cardholderName = json['cardholderName'] ?? '',
        exp = json['exp'] ?? '',
        super(json['key'] ?? '');

  @override
  toJson() => {
        'key': key,
        'tags': tags,
        'nickname': nickname,
        'cardholderName': cardholderName,
      };
}

class PaymentCard extends PassyEntry<PaymentCard> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
  String nickname;
  String cardNumber;
  String cardholderName;
  String cvv;
  String exp;
  List<String> attachments;

  PaymentCard({
    String? key,
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    this.cardNumber = '',
    this.cardholderName = '',
    this.cvv = '',
    this.exp = '',
    List<String>? attachments,
  })  : attachments = attachments ?? [],
        customFields = customFields ?? [],
        tags = tags ?? [],
        super(key ?? DateTime.now().toUtc().toIso8601String());

  @override
  PaymentCardMeta get metadata => PaymentCardMeta(
      key: key,
      tags: tags.toList(),
      nickname: nickname,
      cardNumber: cardNumber.length < 5
          ? cardNumber
          : cardNumber.replaceRange(4, null, '************'),
      cardholderName: cardholderName,
      exp: exp);

  PaymentCardMeta get uncensoredMetadata => PaymentCardMeta(
      key: key,
      tags: tags,
      nickname: nickname,
      cardNumber: cardNumber,
      cardholderName: cardholderName,
      exp: exp);

  PaymentCard.fromJson(Map<String, dynamic> json)
      : customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List?)?.map<String>((e) => e as String).toList() ?? [],
        nickname = json['nickname'] ?? '',
        cardNumber = json['cardNumber'] ?? '',
        cardholderName = json['cardholderName'] ?? '',
        cvv = json['cvv'] ?? '',
        exp = json['exp'] ?? '',
        attachments = json['attachments'] == null
            ? []
            : (json['attachments'] as List<dynamic>)
                .map<String>((e) => e.toString())
                .toList(),
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  PaymentCard._fromCSV(List csv)
      : customFields =
            (csv[1] as List?)?.map((e) => CustomField.fromCSV(e)).toList() ??
                [],
        additionalInfo = csv[2] ?? '',
        tags =
            (csv[3] as List?)?.map<String>((e) => e as String).toList() ?? [],
        nickname = csv[4] ?? '',
        cardNumber = csv[5] ?? '',
        cardholderName = csv[6] ?? '',
        cvv = csv[7] ?? '',
        exp = csv[8] ?? '',
        attachments =
            (csv[9] as List<dynamic>).map<String>((e) => e.toString()).toList(),
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  factory PaymentCard.fromCSV(List csv) {
    if (csv.length == 9) csv.add([]);
    return PaymentCard._fromCSV(csv);
  }

  @override
  int compareTo(PaymentCard other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'nickname': nickname,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'cvv': cvv,
        'exp': exp,
        'attachments': attachments,
      };

  @override
  List toCSV() => [
        key,
        customFields.map((e) => e.toCSV()).toList(),
        additionalInfo,
        tags,
        nickname,
        cardNumber,
        cardholderName,
        cvv,
        exp,
        attachments,
      ];
}
