// ignore_for_file: depend_on_referenced_packages

@JS()
library passy_browser_extension;

import 'package:js/js.dart';

@JS()
external isEmbed();

@JS()
external unloadEmbed();

@JS()
external getPageUrl();

@JS()
external autofillPassword(username, email, password);

@JS()
external isConnectorFound();

@JS()
external sendCommand(command);

@JS()
external getLastUsername();

@JS()
external setLastUsername(username);

@JS()
external getCurrentUsername();

@JS()
external setCurrentUsername(username);
