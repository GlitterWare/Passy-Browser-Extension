import 'package:passy_browser_extension/common/common.dart';
import 'package:passy_browser_extension/common/js_interop.dart';
import 'package:passy_browser_extension/passy_data/entry_event.dart';
import 'package:passy_browser_extension/passy_data/entry_type.dart';
import 'package:passy_browser_extension/passy_data/id_card.dart';
import 'package:passy_browser_extension/passy_data/identity.dart';
import 'package:passy_browser_extension/passy_data/password.dart';
import 'package:passy_browser_extension/passy_data/passy_entry.dart';
import 'package:passy_browser_extension/passy_data/payment_card.dart';

import '../passy_data/account_credentials.dart';
import '../passy_data/entry_meta.dart';
import '../passy_data/note.dart';

class BrowserExtensionData {
  final bool isEmbed = JsInterop.getIsEmbed();
  final bool isConnectorFound;
  final String pageUrl;
  Map<String, AccountCredentials> _credentials;
  String _lastUsername;
  String get lastUsername => _lastUsername;
  String? _currentUsername;
  String? get currentUsername => _currentUsername;
  CurrentEntry? _currentEntry;
  CurrentEntry? get currentEntry => _currentEntry;
  bool get isLoggedIn => currentUsername != null;

  BrowserExtensionData._({
    required this.isConnectorFound,
    required this.pageUrl,
    required String lastUsername,
    String? currentUsername,
    CurrentEntry? currentEntry,
    Map<String, AccountCredentials>? credentials,
  })  : _lastUsername = lastUsername,
        _currentUsername = currentUsername,
        _currentEntry = currentEntry,
        _credentials = credentials ?? {};

  static Future<BrowserExtensionData?> load() async {
    bool isConnectorFound = await JsInterop.getIsConnectorFound();
    String pageUrl = await JsInterop.getPageUrl();
    String? lastUsername = await JsInterop.getLastUsername();
    lastUsername ??= '';
    String? currentUsername = await JsInterop.getCurrentUsername();
    CurrentEntry? currentEntry = await JsInterop.getCurrentEntry();
    if (currentUsername != null) {
      bool isLoggedIn = await JsInterop.isLoggedIn(currentUsername);
      if (!isLoggedIn) currentUsername = null;
    }
    BrowserExtensionData data = BrowserExtensionData._(
      isConnectorFound: isConnectorFound,
      pageUrl: pageUrl,
      lastUsername: lastUsername,
      currentUsername: currentUsername,
      currentEntry: currentEntry,
      credentials: {},
    );
    await data.reloadAccountCredentials();
    if (lastUsername.isEmpty) {
      if (data._credentials.isNotEmpty) {
        data._lastUsername = data._credentials.keys.first;
      }
    }
    return data;
  }

  Future<void> reloadAccountCredentials() async {
    _credentials = await JsInterop.getAccountCredentials() ?? {};
  }

  Iterable<String> get usernames => _credentials.keys;

  String? getPasswordHash(String username) =>
      _credentials[username]?.passwordHash;

  Future<void> setCurrentEntry(CurrentEntry? entry) {
    _currentEntry = entry;
    return JsInterop.setCurrentEntry(entry);
  }

  Future<bool> verify(String username, String password) async {
    await JsInterop.logoutAll();
    bool result = await JsInterop.verify(username, password);
    return result;
  }

  Future<bool> login(String username, String password) async {
    await JsInterop.logoutAll();
    bool result = await JsInterop.login(username, password);
    if (!result) return false;
    _lastUsername = username;
    await JsInterop.setLastUsername(username);
    _currentUsername = username;
    await JsInterop.setCurrentUsername(username);
    return true;
  }

  Future<void> logout() async {
    await JsInterop.setCurrentUsername(null);
    _currentUsername = null;
    await JsInterop.logoutAll();
  }

  Future<Map<String, EntryMeta>?> getEntriesMetadata(EntryType type) async {
    String? username = _currentUsername;
    if (username == null) return null;
    if (!(await JsInterop.isLoggedIn(username))) return null;
    Map<String, EntryMeta>? entriesMeta =
        await JsInterop.listEntries(username, type: type);
    return entriesMeta;
  }

  Future<Map<String, PasswordMeta>?> getPasswordsMetadata() async {
    Map<String, EntryMeta>? entriesMeta =
        await getEntriesMetadata(EntryType.password);
    if (entriesMeta == null) return null;
    return Map<String, PasswordMeta>.from(entriesMeta);
  }

  Future<Map<String, NoteMeta>?> getNotesMetadata() async {
    Map<String, EntryMeta>? entriesMeta =
        await getEntriesMetadata(EntryType.note);
    if (entriesMeta == null) return null;
    return Map<String, NoteMeta>.from(entriesMeta);
  }

  Future<Map<String, PaymentCardMeta>?> getPaymentCardsMetadata() async {
    Map<String, EntryMeta>? entriesMeta =
        await getEntriesMetadata(EntryType.paymentCard);
    if (entriesMeta == null) return null;
    return Map<String, PaymentCardMeta>.from(entriesMeta);
  }

  Future<Map<String, IDCardMeta>?> getIDCardsMetadata() async {
    Map<String, EntryMeta>? entriesMeta =
        await getEntriesMetadata(EntryType.idCard);
    if (entriesMeta == null) return null;
    return Map<String, IDCardMeta>.from(entriesMeta);
  }

  Future<Map<String, IdentityMeta>?> getIdentitiesMetadata() async {
    Map<String, EntryMeta>? entriesMeta =
        await getEntriesMetadata(EntryType.identity);
    if (entriesMeta == null) return null;
    return Map<String, IdentityMeta>.from(entriesMeta);
  }

  Future<PassyEntry?> getEntry(EntryType type, {required String key}) async {
    String? username = _currentUsername;
    if (username == null) return null;
    if (!(await JsInterop.isLoggedIn(username))) return null;
    return await JsInterop.getEntry(username, type: type, key: key);
  }

  Future<Password?> getPassword(String key) async =>
      (await getEntry(EntryType.password, key: key)) as Password?;
  Future<Note?> getNote(String key) async =>
      (await getEntry(EntryType.note, key: key)) as Note?;
  Future<PaymentCard?> getPaymentCard(String key) async =>
      (await getEntry(EntryType.paymentCard, key: key)) as PaymentCard?;
  Future<IDCard?> getIDCard(String key) async =>
      (await getEntry(EntryType.idCard, key: key)) as IDCard?;
  Future<Identity?> getIdentity(String key) async =>
      (await getEntry(EntryType.identity, key: key)) as Identity?;

  Future<bool> setEntry(EntryType type, {required PassyEntry entry}) async {
    String? username = _currentUsername;
    if (username == null) return false;
    if (!(await JsInterop.isLoggedIn(username))) return false;
    return await JsInterop.setEntry(username, type: type, entry: entry);
  }

  Future<bool> setPassword(Password password) =>
      setEntry(EntryType.password, entry: password);
  Future<bool> setNote(Note note) => setEntry(EntryType.note, entry: note);
  Future<bool> setPaymentCard(PaymentCard paymentCard) =>
      setEntry(EntryType.paymentCard, entry: paymentCard);
  Future<bool> setIDCard(IDCard idCard) =>
      setEntry(EntryType.idCard, entry: idCard);
  Future<bool> setIdentity(Identity identity) =>
      setEntry(EntryType.identity, entry: identity);

  Future<bool> removeEntry(EntryType type, {required String key}) async {
    String? username = _currentUsername;
    if (username == null) return false;
    if (!(await JsInterop.isLoggedIn(username))) return false;
    return await JsInterop.removeEntry(username, type: type, key: key);
  }

  Future<bool> removePassword(String key) =>
      removeEntry(EntryType.password, key: key);
  Future<bool> removeNote(String key) => removeEntry(EntryType.note, key: key);
  Future<bool> removePaymentCard(String key) =>
      removeEntry(EntryType.paymentCard, key: key);
  Future<bool> removeIDCard(String key) =>
      removeEntry(EntryType.idCard, key: key);
  Future<bool> removeIdentity(String key) =>
      removeEntry(EntryType.identity, key: key);

  Future<Map<String, EntryEvent>?> getFavoriteEntries(EntryType type) async {
    String? username = _currentUsername;
    if (username == null) return null;
    if (!(await JsInterop.isLoggedIn(username))) return null;
    Map<String, EntryEvent>? entriesMeta =
        await JsInterop.listFavorites(username, type: type);
    return entriesMeta;
  }

  Future<Map<String, EntryEvent>?> getFavoritePasswords() =>
      getFavoriteEntries(EntryType.password);
  Future<Map<String, EntryEvent>?> getFavoriteNotes() =>
      getFavoriteEntries(EntryType.note);
  Future<Map<String, EntryEvent>?> getFavoritePaymentCards() =>
      getFavoriteEntries(EntryType.paymentCard);
  Future<Map<String, EntryEvent>?> getFavoriteIDCards() =>
      getFavoriteEntries(EntryType.idCard);
  Future<Map<String, EntryEvent>?> getFavoriteIdentities() =>
      getFavoriteEntries(EntryType.identity);

  Future<bool> toggleFavoriteEntry({
    required EntryType type,
    required String key,
    required bool toggle,
  }) async {
    String? username = _currentUsername;
    if (username == null) return false;
    return await JsInterop.toggleFavoriteEntry(username,
        type: type, key: key, toggle: toggle);
  }

  Future<bool> toggleFavoritePassword(String key, bool toggle) =>
      toggleFavoriteEntry(type: EntryType.password, key: key, toggle: toggle);
  Future<bool> toggleFavoriteNote(String key, bool toggle) =>
      toggleFavoriteEntry(type: EntryType.note, key: key, toggle: toggle);
  Future<bool> toggleFavoritePaymentCard(String key, bool toggle) =>
      toggleFavoriteEntry(
          type: EntryType.paymentCard, key: key, toggle: toggle);
  Future<bool> toggleFavoriteIDCard(String key, bool toggle) =>
      toggleFavoriteEntry(type: EntryType.idCard, key: key, toggle: toggle);
  Future<bool> toggleFavoriteIdentity(String key, bool toggle) =>
      toggleFavoriteEntry(type: EntryType.identity, key: key, toggle: toggle);
}
