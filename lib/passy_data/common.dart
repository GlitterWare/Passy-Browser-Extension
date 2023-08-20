import 'dart:convert';

import 'package:crypto/crypto.dart';

bool? boolFromString(String value) {
  if (value == 'true') return true;
  if (value == 'false') return false;
  return null;
}

Digest getPassyHash(String value) => sha512.convert(utf8.encode(value));
