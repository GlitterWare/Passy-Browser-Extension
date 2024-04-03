import 'package:passy_browser_extension/passy_data/entry_meta.dart';

import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';
import 'tfa.dart';

typedef Passwords = PassyEntries<Password>;

class PasswordMeta extends EntryMeta {
  final List<String> tags;
  final String nickname;
  final String username;
  String website;

  PasswordMeta(
      {required String key,
      required this.tags,
      required this.nickname,
      required this.username,
      required this.website})
      : super(key);

  PasswordMeta.fromJson(Map<String, dynamic> json)
      : tags = json.containsKey('tags')
            ? json['tags'].map<String>((e) => e.toString()).toList()
            : const [],
        nickname = json['nickname'] ?? '',
        username = json['username'] ?? '',
        website = json['website'] ?? '',
        super(json['key'] ?? '');

  @override
  toJson() => {
        'key': key,
        'tags': tags,
        'nickname': nickname,
        'username': username,
        'website': website,
      };
}

class Password extends PassyEntry<Password> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
  String nickname;
  String iconName;
  String username;
  String email;
  String password;
  TFA? tfa;
  String website;
  List<String> attachments;

  Password({
    String? key,
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.tfa,
    this.website = '',
    List<String>? attachments,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        attachments = attachments ?? [],
        super(key ?? DateTime.now().toUtc().toIso8601String());

  @override
  PasswordMeta get metadata => PasswordMeta(
      key: key,
      tags: tags.toList(),
      nickname: nickname,
      username: username,
      website: website);

  Password.fromJson(Map<String, dynamic> json)
      : customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] as String,
        tags =
            (json['tags'] as List?)?.map<String>((e) => e as String).toList() ??
                [],
        nickname = json['nickname'] ?? '',
        iconName = json['iconName'] ?? '',
        username = json['username'] ?? '',
        email = json['email'] ?? '',
        password = json['password'] ?? '',
        tfa = json['tfa'] != null ? TFA.fromJson(json['tfa']) : null,
        website = json['website'] ?? '',
        attachments = json['attachments'] == null
            ? []
            : (json['attachments'] as List<dynamic>)
                .map<String>((e) => e.toString())
                .toList(),
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Password._fromCSV(List csv)
      : customFields = (csv[1] as List<dynamic>?)
                ?.map((e) => CustomField.fromCSV(e))
                .toList() ??
            [],
        additionalInfo = csv[2] as String,
        tags =
            (csv[3] as List?)?.map<String>((e) => e as String).toList() ?? [],
        nickname = csv[4] ?? '',
        iconName = csv[5] ?? '',
        username = csv[6] ?? '',
        email = csv[7] ?? '',
        password = csv[8] ?? '',
        tfa = csv[9].isNotEmpty ? TFA.fromCSV(csv[9]) : null,
        website = csv[10] ?? '',
        attachments =
            (csv[11] as List<dynamic>).map<String>((e) => e.toString()).toList(),
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  factory Password.fromCSV(List csv) {
    if (csv.length == 11) csv.add([]);
    return Password._fromCSV(csv);
  }

  @override
  int compareTo(Password other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'nickname': nickname,
        'iconName': iconName,
        'username': username,
        'email': email,
        'password': password,
        'tfa': tfa?.toJson(),
        'website': website,
        'attachments': attachments,
      };

  @override
  List toCSV() => [
        key,
        customFields.map((e) => e.toCSV()).toList(),
        additionalInfo,
        tags,
        nickname,
        iconName,
        username,
        email,
        password,
        tfa?.toCSV() ?? [],
        website,
        attachments,
      ];
}
