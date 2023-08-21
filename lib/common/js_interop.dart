// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js_util';
import 'dart:html';
import 'package:passy_browser_extension/passy_data/common.dart';
import 'package:passy_browser_extension/passy_data/entry_meta.dart';
import 'package:passy_browser_extension/passy_data/passy_entry.dart';

import '../passy_data/entry_event.dart';
import '../passy_data/entry_type.dart';
import 'raw_interop.dart' as interop;

import '../passy_data/account_credentials.dart';
import 'common.dart';

abstract class JsInterop {
  static String get currentUrl => window.location.href;

  static bool getIsEmbed() {
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

  static Future<String> getPageUrl() {
    return promiseToFuture(interop.getPageUrl());
  }

  static Future<Uri?> getPageUri() async {
    return Uri.tryParse(await promiseToFuture(interop.getPageUrl()));
  }

  static void autofillPassword(String username, String email, String password) {
    interop.autofillPassword(username, email, password);
  }

  static Future<bool> getIsConnectorFound() async {
    bool isConnectorFound;
    try {
      isConnectorFound = await promiseToFuture(interop.isConnectorFound());
    } catch (e) {
      isConnectorFound = false;
    }
    return isConnectorFound;
  }

  static Future<dynamic> runCommand(List<String> args) {
    return promiseToFuture(interop.sendCommand([
      'passy_cli',
      'run',
      args,
      getPassyHash(jsonEncode(args)).toString(),
    ]));
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

  static Future<String?> getLastUsername() {
    return promiseToFuture(interop.getLastUsername());
  }

  static Future<void> setLastUsername(String username) {
    return promiseToFuture(interop.setLastUsername(username));
  }

  static Future<String?> getCurrentUsername() {
    return promiseToFuture(interop.getCurrentUsername());
  }

  static Future<void> setCurrentUsername(String? username) {
    return promiseToFuture(interop.setCurrentUsername(username));
  }

  static Future<CurrentEntry?> getCurrentEntry() async {
    dynamic result = await promiseToFuture(interop.getCurrentEntry());
    try {
      return CurrentEntry.fromJson(jsonDecode(result));
    } catch (_) {}
    return null;
  }

  static Future<void> setCurrentEntry(CurrentEntry? entry) {
    return promiseToFuture(
        interop.setCurrentEntry(jsonEncode(entry?.toJson())));
  }

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
}
