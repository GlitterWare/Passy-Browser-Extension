import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passy_browser_extension/screens/common/common.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import 'package:url_launcher/url_launcher_string.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/password.dart';
import '../passy_data/tfa.dart';
import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'edit_password_screen.dart';
import 'main_screen.dart';
import 'passwords_screen.dart';
import 'splash_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/password';

  @override
  State<StatefulWidget> createState() => _PasswordScreen();
}

class _PasswordScreen extends State<PasswordScreen> {
  final Completer<void> _onClosed = Completer<void>();
  List<String> _tags = [];
  List<String> _selected = [];
  bool _tagsLoaded = false;
  Password? password;
  Future<void>? generateTFA;
  String _tfaCode = '';
  double _tfaProgress = 0;
  Color _tfaColor = PassyTheme.lightContentSecondaryColor;
  bool isFavorite = false;

  Future<void> _generateTFA(TFA tfa) async {
    double tfaProgressLast = 1.0;

    while (true) {
      if (_onClosed.isCompleted) return;
      double tfaCycles =
          (DateTime.now().millisecondsSinceEpoch / 1000) / tfa.interval;
      setState(() {
        _tfaProgress = tfaCycles - tfaCycles.floor();
      });
      switch (_tfaColor.value) {
        case 4287679225:
          // Blue
          if (_tfaProgress < 0.60) break;
          setState(() {
            _tfaColor = Colors.yellow;
          });
          break;
        case 4294961979:
          // Yellow
          if (_tfaProgress < 0.85) break;
          setState(() {
            _tfaColor = Colors.red;
          });
          break;
        case 4294198070:
          // Red
          if (_tfaProgress > 0.60) break;
          setState(() {
            _tfaColor = PassyTheme.lightContentSecondaryColor;
          });
          break;
      }
      if (_tfaProgress < tfaProgressLast) {
        if (!mounted) return;
        setState(() => _tfaCode = tfa.generate());
      }
      tfaProgressLast = _tfaProgress;
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    _onClosed.complete();
  }

  void _onRemovePressed(Password password) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removePassword),
            content:
                Text('${localizations.passwordsCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () async {
                  Navigator.pushNamed(context, SplashScreen.routeName);
                  await data.removePassword(password.key);
                  List<PasswordMeta> passwords =
                      (await data.getPasswordsMetadata())?.values.toList() ??
                          <PasswordMeta>[];
                  if (!mounted) return;
                  Navigator.popUntil(
                      context, ModalRoute.withName(MainScreen.routeName));
                  Navigator.pushNamed(context, PasswordsScreen.routeName,
                      arguments: passwords);
                },
              )
            ],
          );
        });
  }

  void _onEditPressed(Password password) {
    Navigator.pushNamed(
      context,
      EditPasswordScreen.routeName,
      arguments: password,
    );
  }

  Future<void> _load() async {
    List<String> newTags = await data.tags;
    newTags.sort(tagSort);
    if (mounted) {
      setState(() {
        _tags = newTags;
        _selected = password!.tags.toList();
        _selected.sort(tagSort);
        for (String tag in _selected) {
          if (_tags.contains(tag)) {
            _tags.remove(tag);
          }
        }
        _tagsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password == null) {
      EntryScreenArgs args =
          ModalRoute.of(context)!.settings.arguments as EntryScreenArgs;
      password = args.entry as Password;
      isFavorite = args.isFavorite;
      if (password!.tfa != null) {
        if (password!.tfa!.type == TFAType.HOTP) {
          setState(() {
            _tfaCode = password!.tfa!.generate();
          });
        } else {
          generateTFA = _generateTFA(password!.tfa!);
        }
      }
      _load();
    }

    Widget? tfaWidget;
    if (password!.tfa != null) {
      if (password!.tfa!.type == TFAType.HOTP) {
        tfaWidget = Container(
          padding: EdgeInsets.only(right: PassyTheme.passyPadding.right),
          child: Row(
            children: [
              Flexible(
                child: PassyPadding(RecordButton(
                  title: localizations.tfaCode,
                  value: _tfaCode,
                )),
              ),
              FloatingActionButton(
                  heroTag: null,
                  tooltip: localizations.refresh,
                  onPressed: () async {
                    Navigator.pushNamed(context, SplashScreen.routeName);
                    password!.tfa!.interval++;
                    await data.setPassword(password!);
                    Map<String, PasswordMeta>? passwords =
                        await data.getPasswordsMetadata();
                    if (passwords == null) return;
                    if (!context.mounted) return;
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, PasswordsScreen.routeName,
                        arguments: passwords);
                    Navigator.pushNamed(context, PasswordScreen.routeName,
                        arguments: EntryScreenArgs(
                            entry: password!, isFavorite: isFavorite));
                  },
                  child: const Icon(Icons.refresh_rounded)),
            ],
          ),
        );
      } else {
        tfaWidget = Row(
          children: [
            SizedBox(
              width: PassyTheme.passyPadding.left * 2,
            ),
            SizedBox(
              child: CircularProgressIndicator(
                value: _tfaProgress,
                color: _tfaColor,
              ),
            ),
            Flexible(
              child: PassyPadding(RecordButton(
                title: localizations.tfaCode,
                value: _tfaCode,
              )),
            ),
          ],
        );
      }
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.password,
        entryKey: password!.key,
        title: Center(child: Text(localizations.password)),
        onRemovePressed: () => _onRemovePressed(password!),
        onEditPressed: () => _onEditPressed(password!),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await data.toggleFavoritePassword(password!.key, false);
            setState(() => isFavorite = false);
            if (mounted) {
              showSnackBar(
                  message: localizations.removedFromFavorites,
                  icon: const Icon(
                    Symbols.star_rounded,
                    weight: 700,
                    color: PassyTheme.darkContentColor,
                  ));
            }
          } else {
            await data.toggleFavoritePassword(password!.key, true);
            setState(() => isFavorite = true);
            if (mounted) {
              showSnackBar(
                  message: localizations.addedToFavorites,
                  icon: const Icon(
                    Symbols.star_rounded,
                    weight: 700,
                    fill: 1,
                    color: PassyTheme.darkContentColor,
                  ));
            }
          }
          setState(() {});
        },
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                  top: PassyTheme.passyPadding.top / 2,
                  bottom: PassyTheme.passyPadding.bottom / 2),
              child: !_tagsLoaded
                  ? const CircularProgressIndicator()
                  : EntryTagList(
                      showAddButton: true,
                      selected: _selected,
                      notSelected: _tags,
                      onSecondary: (tag) async {
                        String? newTag = await showDialog(
                          context: context,
                          builder: (ctx) => RenameTagDialog(tag: tag),
                        );
                        if (newTag == null) return;
                        if (newTag == tag) return;
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, SplashScreen.routeName);
                        try {
                          bool result =
                              await data.renameTag(tag: tag, newTag: newTag);
                          if (!result) throw Exception('Not implemented');
                        } catch (e) {
                          if (context.mounted) Navigator.pop(context);
                          showSnackBar(
                            message: localizations.somethingWentWrong,
                            icon: const Icon(Icons.error_outline_rounded,
                                color: PassyTheme.darkContentColor),
                          );
                          return;
                        }
                        password!.tags = _selected.toList();
                        if (password!.tags.contains(tag)) {
                          password!.tags.remove(tag);
                          password!.tags.add(newTag);
                        }
                        List<PasswordMeta> passwords =
                            (await data.getPasswordsMetadata())
                                    ?.values
                                    .toList() ??
                                <PasswordMeta>[];
                        if (!context.mounted) return;
                        Navigator.popUntil(context,
                            (r) => r.settings.name == MainScreen.routeName);
                        Navigator.pushNamed(context, PasswordsScreen.routeName,
                            arguments: passwords);
                        Navigator.pushNamed(context, PasswordScreen.routeName,
                            arguments: password!);
                      },
                      onAdded: (tag) async {
                        if (password!.tags.contains(tag)) return;
                        Navigator.pushNamed(context, SplashScreen.routeName);
                        password!.tags = _selected.toList();
                        password!.tags.add(tag);
                        await data.setPassword(password!);
                        List<PasswordMeta> passwords =
                            (await data.getPasswordsMetadata())
                                    ?.values
                                    .toList() ??
                                <PasswordMeta>[];
                        if (!context.mounted) return;
                        Navigator.popUntil(context,
                            (r) => r.settings.name == MainScreen.routeName);
                        Navigator.pushNamed(context, PasswordsScreen.routeName,
                            arguments: passwords);
                        Navigator.pushNamed(
                          context,
                          PasswordScreen.routeName,
                          arguments: EntryScreenArgs(
                              entry: password!, isFavorite: isFavorite),
                        );
                      },
                      onRemoved: (tag) async {
                        Navigator.pushNamed(context, SplashScreen.routeName);
                        password!.tags = _selected.toList();
                        password!.tags.remove(tag);
                        await data.setPassword(password!);
                        List<PasswordMeta> passwords =
                            (await data.getPasswordsMetadata())
                                    ?.values
                                    .toList() ??
                                <PasswordMeta>[];
                        if (!context.mounted) return;
                        Navigator.popUntil(context,
                            (r) => r.settings.name == MainScreen.routeName);
                        Navigator.pushNamed(context, PasswordsScreen.routeName,
                            arguments: passwords);
                        Navigator.pushNamed(
                          context,
                          PasswordScreen.routeName,
                          arguments: EntryScreenArgs(
                              entry: password!, isFavorite: isFavorite),
                        );
                      },
                    ),
            ),
          ),
          if (password!.nickname != '')
            PassyPadding(RecordButton(
              title: localizations.nickname,
              value: password!.nickname,
            )),
          if (password!.username != '')
            PassyPadding(RecordButton(
              title: localizations.username,
              value: password!.username,
            )),
          if (password!.email != '')
            PassyPadding(RecordButton(
                title: localizations.email, value: password!.email)),
          if (password!.password != '')
            PassyPadding(RecordButton(
              title: localizations.password,
              value: password!.password,
              obscureValue: true,
              isPassword: true,
            )),
          if (tfaWidget != null) tfaWidget,
          if (password!.website != '')
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: PassyTheme.passyPadding.left,
                      bottom: PassyTheme.passyPadding.bottom,
                      top: PassyTheme.passyPadding.top,
                    ),
                    child: RecordButton(
                      title: localizations.website,
                      value: password!.website,
                      left: FavIconImage(address: password!.website, width: 40),
                    ),
                  ),
                ),
                SizedBox(
                  child: PassyPadding(
                    FloatingActionButton(
                      heroTag: null,
                      tooltip: localizations.visit,
                      onPressed: () {
                        String url = password!.website;
                        if (!url.contains(RegExp('http:\\/\\/|https:\\/\\/'))) {
                          url = 'http://$url';
                        }
                        try {
                          launchUrlString(url);
                        } catch (_) {}
                      },
                      child: const Icon(Symbols.open_in_browser_rounded,
                          weight: 700),
                    ),
                  ),
                )
              ],
            ),
          for (CustomField customField in password!.customFields)
            PassyPadding(CustomFieldButton(customField: customField)),
          if (password!.additionalInfo != '')
            PassyPadding(RecordButton(
                title: localizations.additionalInfo,
                value: password!.additionalInfo)),
        ],
      ),
    );
  }
}
