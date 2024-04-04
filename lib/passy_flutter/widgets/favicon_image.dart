import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_browser_extension/common/js_interop.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../common/assets.dart';
import '../passy_flutter.dart';
import 'package:image/image.dart' as img;

bool _isFaviconManagerStarted = false;
Completer _faviconManagerCompleter = Completer();
Map<String, dynamic> _favicons = {};
Map<String, Future<String?>> _faviconFutures = {};
bool _saveRequested = false;

class _FavIconData {
  final String url;
  final Uint8List data;

  _FavIconData(this.url, this.data);
}

class FavIconImage extends StatelessWidget {
  final String address;
  final double width;

  const FavIconImage({
    Key? key,
    required this.address,
    this.width = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic file;
    if (!_isFaviconManagerStarted) {
      _isFaviconManagerStarted = true;
      Future(() async {
        file = await JsInterop.localGet('passyFavicons');
        if (file == null) {
          file = jsonEncode({'favicons': _favicons});
          await JsInterop.localSet('passyFavicons', file);
        } else {
          Map<String, dynamic> contents = jsonDecode(file);
          dynamic favicons = contents['favicons'];
          if (favicons is! Map<String, dynamic>) {
            favicons = {};
            contents['favicons'] = favicons;
            await JsInterop.localSet('passyFavicons', jsonEncode(contents));
          }
          _favicons = favicons;
        }
        _faviconManagerCompleter.complete();
        Future<void> faviconManager() async {
          if (_saveRequested) {
            await JsInterop.localSet(
                'passyFavicons', jsonEncode({'favicons': _favicons}));
          }
          Future.delayed(const Duration(seconds: 5), faviconManager);
        }

        faviconManager();
      });
    }
    String url = address;
    Widget placeholder = SvgPicture(
      const AssetBytesLoader(logoCircleSvg),
      colorFilter:
          const ColorFilter.mode(PassyTheme.lightContentColor, BlendMode.srcIn),
      width: width,
      height: width,
    );
    url = 'http://${url.replaceFirst(RegExp('https://|http://'), '')}';
    return FutureBuilder(
      future: () async {
        await _faviconManagerCompleter.future;
        dynamic imageURL = _favicons[url];
        if (imageURL is String) {
          Uint8List? data;
          data = await JsInterop.fetchFile(imageURL);
          if (data == null) {
            _favicons.remove(url);
            _saveRequested = true;
          } else {
            return _FavIconData(url, data);
          }
        }
        String? icon;
        try {
          Future<String?>? faviconFuture = _faviconFutures[url];
          //faviconFuture ??= compute<String, Favicon?>(
          //    (url) async => await FaviconFinder.getBest(url,
          //        suffixes: ['png', 'jpg', 'jpeg', 'ico']),
          //    url);
          faviconFuture ??= Future.value(JsInterop.getBestFavicon(
              url, ['png', 'jpg', 'jpeg', 'ico', 'bmp']));
          _faviconFutures[url] = faviconFuture;
          icon = await faviconFuture;
          _faviconFutures.remove(url);
        } catch (_) {
          _faviconFutures.remove(url);
          return null;
        }
        if (icon == null) return null;
        Uint8List? data = await JsInterop.fetchFile(icon);
        if (data == null) {
          _favicons.remove(url);
          _saveRequested = true;
          return null;
        }
        _favicons[url] = icon;
        _saveRequested = true;
        return _FavIconData(icon, data);
      }(),
      builder: (BuildContext context, AsyncSnapshot<_FavIconData?> snapshot) {
        _FavIconData? favicon = snapshot.data;
        if (favicon == null) return placeholder;
        if (favicon.url.endsWith('.svg')) {
          return SvgPicture.memory(
            favicon.data,
            placeholderBuilder: (context) => placeholder,
            width: width,
            fit: BoxFit.fill,
          );
        }
        return Image.memory(
          img.encodeBmp(img.decodeImage(favicon.data)!),
          errorBuilder: (ctx, obj, s) {
            _favicons.remove(url);
            _saveRequested = true;
            return placeholder;
          },
          width: width,
          fit: BoxFit.fill,
        );
      },
    );
  }
}
