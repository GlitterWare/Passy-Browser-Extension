// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:passy_browser_extension/passy_data/common.dart';
import 'package:passy_browser_extension/passy_data/entry_meta.dart';
import 'package:passy_browser_extension/passy_data/passy_entry.dart';

import '../passy_data/entry_event.dart';
import '../passy_data/entry_type.dart';
import 'raw_interop.dart' as interop;

import '../passy_data/account_credentials.dart';
import 'common.dart';

abstract class JsInterop {
  static String get currentUrl =>
      (interop.location.getProperty('href'.toJS) as JSString).toDart;

  static bool isEmbed() {
    bool result;
    try {
      result = interop.isEmbed();
    } catch (e) {
      result = true;
    }
    return result;
  }

  static void unloadEmbed() {
    interop.unloadEmbed();
  }

  static Future<String> getPageUrl() async {
    return (await interop.getPageUrl().toDart).toDart;
  }

  static Future<Uri?> getPageUri() async {
    return Uri.tryParse(await getPageUrl());
  }

  static void autofillPassword(String username, String email, String password) {
    interop.autofillPassword(username, email, password);
  }

  static Future<bool> isConnectorFound() async {
    bool isConnectorFound;
    try {
      JSAny? jsResponse = await interop.isConnectorFound().toDart;
      if (jsResponse == null) {
        isConnectorFound = false;
      } else {
        isConnectorFound =
            ((jsResponse as JSObject).getProperty('response'.toJS) as JSBoolean)
                .toDart;
      }
    } catch (e) {
      isConnectorFound = false;
    }
    return isConnectorFound;
  }

  static final Map<int, Future<dynamic>> _commands = {};
  static int _curIndex = 0;
  static Future<dynamic> runCommand(List<String> args) async {
    _curIndex++;
    int i = _curIndex;
    if (_commands.isNotEmpty) {
      Future<dynamic> position = Future.value(null);
      _commands[i] = position;
      while (true) {
        List<Future<dynamic>> toWait = _commands.values.toList();
        toWait.removeRange(toWait.indexOf(position) + 1, toWait.length);
        await Future.wait(toWait);
        if (_commands.values.toList().indexOf(position) == 0) break;
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    Future<JSAny?> response = interop
        .runCommand([
          'passy_cli'.toJS,
          'run'.toJS,
          [...(args.map((e) => e.toJS))].toJS,
          getPassyHash(jsonEncode(args)).toString().toJS,
        ].toJS)
        .toDart;
    _commands[i] = response;
    JSAny? result = await response;
    _commands.remove(i);
    if (result == null) return null;
    try {
      return (result as JSObject).getProperty('response'.toJS).toString();
    } catch (_) {}
    return null;
  }

  static Future<Map<String, AccountCredentials>?>
      getAccountCredentials() async {
    dynamic credentials = await runCommand(['accounts', 'list']);
    if (credentials is! String) return null;
    Map<String, AccountCredentials> credentialsDecoded = {};
    for (String entry in credentials.split('\n')) {
      List<dynamic> entryDecoded;
      try {
        entryDecoded = csvDecode(entry);
      } catch (e) {
        continue;
      }
      if (entryDecoded.length < 2) continue;
      String username = entryDecoded[0].toString();
      credentialsDecoded[username] =
          AccountCredentials(username: username, passwordHash: entryDecoded[1]);
    }
    return credentialsDecoded;
  }

  static Future<String?> getLastUsername() async {
    JSString? result = await interop.getLastUsername().toDart;
    if (result == null) return null;
    return result.toDart;
  }

  static Future<void> setLastUsername(String username) {
    return interop.setLastUsername(username).toDart;
  }

  static Future<String?> getCurrentUsername() async {
    JSString? result = await interop.getCurrentUsername().toDart;
    if (result == null) return null;
    return result.toDart;
  }

  static Future<void> setCurrentUsername(String? username) {
    return interop.setCurrentUsername(username).toDart;
  }

  static Future<CurrentEntry?> getCurrentEntry() async {
    String? result = (await interop.getCurrentEntry().toDart)?.toDart;
    if (result == null) return null;
    try {
      return CurrentEntry.fromJson(jsonDecode(result));
    } catch (_) {}
    return null;
  }

  static Future<void> setCurrentEntry(CurrentEntry? entry) {
    return interop.setCurrentEntry(jsonEncode(entry?.toJson())).toDart;
  }

  static void createTab(String url) => interop.createTab(url);

  static Future<bool> verify(String username, String password) async {
    dynamic response =
        await runCommand(['accounts', 'verify', username, password]);
    if (response == 'true') return true;
    return false;
  }

  static Future<bool> login(String username, String password) async {
    dynamic response =
        await runCommand(['accounts', 'login', username, password]);
    if (response == 'true') return true;
    return false;
  }

  static Future<bool> isLoggedIn(String username) async {
    dynamic response = await runCommand(['accounts', 'is_logged_in', username]);
    if (response == 'true') return true;
    return false;
  }

  static Future<void> logout(String username) {
    return runCommand(['accounts', 'logout', username]);
  }

  static Future<void> logoutAll() {
    return runCommand(['accounts', 'logout', 'test']);
  }

  static Future<Map<String, EntryMeta>?> listEntries(
    String username, {
    required EntryType type,
  }) async {
    dynamic entries =
        await runCommand(['entries', 'list', username, type.name]);
    if (entries is! String) return null;
    Map<String, EntryMeta> entriesDecoded = {};
    for (String entry in entries.split('\n')) {
      dynamic entryDecoded;
      try {
        entryDecoded = jsonDecode(entry);
      } catch (e) {
        continue;
      }
      if (entryDecoded is! Map<String, dynamic>) continue;
      dynamic key = entryDecoded['key'];
      if (key is! String) continue;
      if (entryDecoded.length < 2) continue;
      entriesDecoded[key] = EntryMeta.fromJson(type)(entryDecoded);
    }
    return entriesDecoded;
  }

  static Future<PassyEntry?> getEntry(
    String username, {
    required EntryType type,
    required String key,
  }) async {
    dynamic password =
        await runCommand(['entries', 'get', username, type.name, key]);
    if (password is! String) return null;
    PassyEntry entryDecoded;
    try {
      entryDecoded =
          PassyEntry.fromCSV(type)(csvDecode(password, recursive: true));
    } catch (_) {
      return null;
    }
    return entryDecoded;
  }

  static Future<bool> setEntry(
    String username, {
    required EntryType type,
    required PassyEntry entry,
  }) async {
    dynamic response = await runCommand(
        ['entries', 'set', username, type.name, csvEncode(entry.toCSV())]);
    if (response == 'true') return true;
    return false;
  }

  static Future<bool> removeEntry(
    String username, {
    required EntryType type,
    required String key,
  }) async {
    dynamic response =
        await runCommand(['entries', 'remove', username, type.name, key]);
    if (response == 'true') return true;
    return false;
  }

  static Future<Map<String, EntryEvent>?> listFavorites(
    String username, {
    required EntryType type,
  }) async {
    dynamic entries =
        await runCommand(['favorites', 'list', username, type.name]);
    if (entries is! String) return null;
    Map<String, EntryEvent> entriesDecoded = {};
    for (String entry in entries.split('\n')) {
      dynamic entryDecoded;
      try {
        entryDecoded = jsonDecode(entry);
      } catch (e) {
        continue;
      }
      if (entryDecoded is! Map<String, dynamic>) continue;
      dynamic key = entryDecoded['key'];
      if (key is! String) continue;
      if (entryDecoded.length < 2) continue;
      entriesDecoded[key] = EntryEvent.fromJson(entryDecoded);
    }
    return entriesDecoded;
  }

  static Future<bool> toggleFavoriteEntry(
    String username, {
    required EntryType type,
    required String key,
    required bool toggle,
  }) async {
    dynamic response = await runCommand(
        ['favorites', 'toggle', username, type.name, key, toggle.toString()]);
    if (response == 'true') return true;
    return false;
  }

  Future<bool> renameTag(
    String username, {
    required EntryType type,
    required String tag,
    required String newTag,
  }) async {
    dynamic response =
        await runCommand(['tags', 'rename', username, type.name, tag, newTag]);
    if (response == 'true') return true;
    return false;
  }
}
