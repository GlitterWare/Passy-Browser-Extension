// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:passy_browser_extension/common/browser_extension_data.dart';
import 'package:passy_browser_extension/passy_data/entry_type.dart';
import 'package:passy_browser_extension/passy_data/json_convertable.dart';

const String extensionVersion = '1.2.0';

late AppLocalizations localizations;
late BrowserExtensionData data;

AppLocalizations loadLocalizations(BuildContext context) {
  localizations = AppLocalizations.of(context)!;
  return localizations;
}

String csvEncode(List object) {
  String _encode(dynamic record) {
    if (record is String) {
      return record
          .replaceAll('\\', '\\\\')
          .replaceAll('\n', '\\n')
          .replaceAll(',', '\\,')
          .replaceAll('[', '\\[')
          .replaceAll(']', '\\]');
    }
    if (record is List) {
      String _encoded = '[';
      if (record.isNotEmpty) {
        for (int i = 0; i < record.length - 1; i++) {
          _encoded += _encode(record[i]) + ',';
        }
        _encoded += _encode(record[record.length - 1]);
      }
      _encoded += ']';
      return _encoded;
    }
    return record.toString();
  }

  String _result = '';
  if (object.isNotEmpty) {
    for (int i = 0; i < object.length - 1; i++) {
      _result += _encode(object[i]) + ',';
    }
    _result += _encode(object[object.length - 1]);
  }
  return _result;
}

List csvDecode(String source,
    {bool recursive = false, bool decodeBools = false}) {
  List _decode(String source) {
    if (source == '') return [];

    List<dynamic> _entry = [''];
    int v = 0;
    int _depth = 0;
    Iterator<String> _characters = source.characters.iterator;
    bool _escapeDetected = false;

    void _convert() {
      if (!decodeBools) return;
      if (_entry[v] == 'false') {
        _entry[v] = false;
      }

      if (_entry[v] == 'true') {
        _entry[v] = true;
      }
    }

    while (_characters.moveNext()) {
      String _currentCharacter = _characters.current;

      if (!_escapeDetected) {
        if (_characters.current == ',') {
          _convert();
          v++;
          _entry.add('');
          continue;
        } else if (_characters.current == '[') {
          _entry[v] += '[';
          _depth++;
          while (_characters.moveNext()) {
            _entry[v] += _characters.current;
            if (_characters.current == '\\') {
              if (!_characters.moveNext()) break;
              _entry[v] += _characters.current;
              continue;
            }
            if (_characters.current == '[') {
              _depth++;
            }
            if (_characters.current == ']') {
              _depth--;
              if (_depth == 0) break;
            }
          }
          if (recursive) {
            if (_entry[v] == '[]') {
              _entry[v] = [];
              continue;
            }
            String _entryString = _entry[v];
            _entry[v] =
                _decode(_entryString.substring(1, _entryString.length - 1));
          }
          continue;
        } else if (_characters.current == '\\') {
          _escapeDetected = true;
          continue;
        }
      } else {
        if (_characters.current == 'n') {
          _currentCharacter = '\n';
        }
      }

      _entry[v] += _currentCharacter;
      _escapeDetected = false;
    }

    _convert();

    return _entry;
  }

  return _decode(source);
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
