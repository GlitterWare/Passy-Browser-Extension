// ignore_for_file: depend_on_referenced_packages

@JS()
library passy_browser_extension;

import 'dart:js_interop';

@JS()
external JSObject get location;

@JS()
external bool isEmbed();

@JS()
external void unloadEmbed();

@JS()
external JSPromise<JSString> getPageUrl();

@JS()
external void autofillPassword(String username, String email, String password);

@JS()
external JSPromise isConnectorFound();

@JS()
external JSPromise runCommand(JSArray command);

@JS()
external JSPromise<JSString?> getLastUsername();

@JS()
external JSPromise setLastUsername(String username);

@JS()
external JSPromise<JSString?> getCurrentUsername();

@JS()
external JSPromise setCurrentUsername(String? username);

@JS()
external JSPromise<JSString?> getCurrentEntry();

@JS()
external JSPromise setCurrentEntry(String entry);

@JS()
external void createTab(String url);

@JS()
external JSPromise<JSString?> getBestFavicon(String url, JSArray suffixes);

@JS()
external JSPromise<JSUint8Array?> fetchFile(String url);

@JS()
external JSPromise<JSAny?> localGet(String key);

@JS()
external JSPromise localSet(String key, JSAny? value);
