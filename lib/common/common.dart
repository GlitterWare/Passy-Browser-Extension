// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:passy_browser_extension/common/browser_extension_data.dart';
import 'package:passy_browser_extension/passy_data/entry_type.dart';
import 'package:passy_browser_extension/passy_data/json_convertable.dart';

const String extensionVersion = '1.0.1';

late AppLocalizations localizations;
late BrowserExtensionData data;

AppLocalizations loadLocalizations(BuildContext context) {
  localizations = AppLocalizations.of(context)!;
  return localizations;
}

String csvEncode(List object) {
  String encode(dynamic record) {
    if (record is String) {
      return record
          .replaceAll('\\', '\\\\')
          .replaceAll('\n', '\\n')
          .replaceAll(',', '\\,')
          .replaceAll('[', '\\[');
    }
    if (record is List) {
      String encoded = '[';
      if (record.isNotEmpty) {
        for (int i = 0; i < record.length - 1; i++) {
          encoded += '${encode(record[i])},';
        }
        encoded += encode(record[record.length - 1]);
      }
      encoded += ']';
      return encoded;
    }
    return record.toString();
  }

  String result = '';
  if (object.isNotEmpty) {
    for (int i = 0; i < object.length - 1; i++) {
      result += '${encode(object[i])},';
    }
    result += encode(object[object.length - 1]);
  }
  return result;
}

List csvDecode(String source,
    {bool recursive = false, bool decodeBools = false}) {
  List decode(String source) {
    if (source == '') return [];

    List<dynamic> entry = [''];
    int v = 0;
    int depth = 0;
    Iterator<String> characters = source.characters.iterator;
    bool escapeDetected = false;

    void convert() {
      if (!decodeBools) return;
      if (entry[v] == 'false') {
        entry[v] = false;
      }

      if (entry[v] == 'true') {
        entry[v] = true;
      }
    }

    while (characters.moveNext()) {
      String currentCharacter = characters.current;

      if (!escapeDetected) {
        if (characters.current == ',') {
          convert();
          v++;
          entry.add('');
          continue;
        } else if (characters.current == '[') {
          entry[v] += '[';
          depth++;
          while (characters.moveNext()) {
            entry[v] += characters.current;
            if (characters.current == ']') {
              depth--;
              if (depth == 0) break;
            }
            if (characters.current == '\\') {
              escapeDetected = true;
            }
            if (escapeDetected) {
              escapeDetected = false;
              continue;
            }
            if (characters.current == '[') {
              depth++;
            }
          }
          if (recursive) {
            if (entry[v] == '[]') {
              entry[v] = [];
              continue;
            }
            String entryString = entry[v];
            entry[v] = decode(entryString.substring(1, entryString.length - 1));
          }
          continue;
        } else if (characters.current == '\\') {
          escapeDetected = true;
          continue;
        }
      } else {
        if (characters.current == 'n') {
          currentCharacter = '\n';
        }
      }

      entry[v] += currentCharacter;
      escapeDetected = false;
    }

    convert();

    return entry;
  }

  return decode(source);
}

class CurrentEntry with JsonConvertable {
  final String key;
  final EntryType type;

  CurrentEntry({
    required this.key,
    required this.type,
  });

  CurrentEntry.fromJson(Map<String, dynamic> json)
      : key = json['key'] ?? '',
        type = json.containsKey('type')
            ? entryTypeFromName(json['type']) ?? EntryType.password
            : EntryType.password;

  @override
  toJson() {
    return {
      'key': key,
      'type': type.name,
    };
  }
}
