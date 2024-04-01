import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/identity.dart';
import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'common/entry_screen_args.dart';
import 'main_screen.dart';
import 'edit_identity_screen.dart';
import 'identities_screen.dart';
import 'splash_screen.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({Key? key}) : super(key: key);

  static const routeName = '/identity';

  @override
  State<StatefulWidget> createState() => _IdentityScreen();
}

class _IdentityScreen extends State<IdentityScreen> {
  List<String> _tags = [];
  List<String> _selected = [];
  bool _tagsLoaded = false;
  bool isFavorite = false;
  bool isLoaded = false;

  Future<void> _load(Identity identity) async {
    List<String> newTags = await data.tags;
    newTags.sort();
    if (mounted) {
      setState(() {
        _tags = newTags;
        _selected = identity.tags.toList();
        _selected.sort();
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
    final EntryScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as EntryScreenArgs;
    final Identity identity = args.entry as Identity;
    if (!isLoaded) {
      isLoaded = true;
      _load(identity);
      isFavorite = args.isFavorite;
    }

    void onRemovePressed() {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removeIdentity),
            content: Text(
                '${localizations.identitiesCanOnlyBeRestoredFromABackup}.'),
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
                  await data.removeIdentity(identity.key);
                  List<IdentityMeta> identities =
                      (await data.getIdentitiesMetadata())?.values.toList() ??
                          <IdentityMeta>[];
                  if (!context.mounted) return;
                  Navigator.popUntil(
                      context, (r) => r.settings.name == MainScreen.routeName);
                  Navigator.pushNamed(context, IdentitiesScreen.routeName,
                      arguments: identities);
                },
              )
            ],
          );
        },
      );
    }

    void onEditPressed() {
      Navigator.pushNamed(
        context,
        EditIdentityScreen.routeName,
        arguments: identity,
      );
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.identity,
        entryKey: identity.key,
        title: Center(child: Text(localizations.identity)),
        onRemovePressed: onRemovePressed,
        onEditPressed: onEditPressed,
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await data.toggleFavoriteIdentity(identity.key, false);
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
            await data.toggleFavoriteIdentity(identity.key, true);
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
                        identity.tags = _selected.toList();
                        if (identity.tags.contains(tag)) {
                          identity.tags.remove(tag);
                          identity.tags.add(newTag);
                        }
                        List<IdentityMeta> identities =
                            (await data.getIdentitiesMetadata())
                                    ?.values
                                    .toList() ??
                                <IdentityMeta>[];
                        if (!context.mounted) return;
                        Navigator.popUntil(context,
                            (r) => r.settings.name == MainScreen.routeName);
                        Navigator.pushNamed(context, IdentitiesScreen.routeName,
                            arguments: identities);
                        Navigator.pushNamed(context, IdentityScreen.routeName,
                            arguments: identity);
                      },
                      onAdded: (tag) async {
                        if (identity.tags.contains(tag)) return;
                        Navigator.pushNamed(context, SplashScreen.routeName);
                        identity.tags = _selected.toList();
                        identity.tags.add(tag);
                        await data.setIdentity(identity);
                        List<IdentityMeta> identities =
                            (await data.getIdentitiesMetadata())
                                    ?.values
                                    .toList() ??
                                <IdentityMeta>[];
                        if (!context.mounted) return;
                        Navigator.popUntil(context,
                            (r) => r.settings.name == MainScreen.routeName);
                        Navigator.pushNamed(context, IdentitiesScreen.routeName,
                            arguments: identities);
                        Navigator.pushNamed(
                          context,
                          IdentityScreen.routeName,
                          arguments: EntryScreenArgs(
                              entry: identity, isFavorite: isFavorite),
                        );
                      },
                      onRemoved: (tag) async {
                        Navigator.pushNamed(context, SplashScreen.routeName);
                        identity.tags = _selected.toList();
                        identity.tags.remove(tag);
                        await data.setIdentity(identity);
                        List<IdentityMeta> identities =
                            (await data.getIdentitiesMetadata())
                                    ?.values
                                    .toList() ??
                                <IdentityMeta>[];
                        if (!context.mounted) return;
                        Navigator.popUntil(context,
                            (r) => r.settings.name == MainScreen.routeName);
                        Navigator.pushNamed(context, IdentitiesScreen.routeName,
                            arguments: identities);
                        Navigator.pushNamed(
                          context,
                          IdentityScreen.routeName,
                          arguments: EntryScreenArgs(
                              entry: identity, isFavorite: isFavorite),
                        );
                      },
                    ),
            ),
          ),
          if (identity.nickname != '')
            PassyPadding(RecordButton(
              title: localizations.nickname,
              value: identity.nickname,
            )),
          PassyPadding(RecordButton(
              title: localizations.title,
              value: capitalize(identity.title.name))),
          if (identity.firstName != '')
            PassyPadding(RecordButton(
              title: localizations.firstName,
              value: identity.firstName,
            )),
          if (identity.middleName != '')
            PassyPadding(RecordButton(
              title: localizations.middleName,
              value: identity.middleName,
            )),
          if (identity.lastName != '')
            PassyPadding(RecordButton(
              title: localizations.lastName,
              value: identity.lastName,
            )),
          PassyPadding(RecordButton(
            title: localizations.gender,
            value: genderToReadableName(identity.gender),
          )),
          if (identity.email != '')
            PassyPadding(RecordButton(
              title: localizations.email,
              value: identity.email,
            )),
          if (identity.number != '')
            PassyPadding(RecordButton(
              title: localizations.phoneNumber,
              value: identity.number,
            )),
          if (identity.firstAddressLine != '')
            PassyPadding(RecordButton(
                title: localizations.firstAddresssLine,
                value: identity.firstAddressLine)),
          if (identity.secondAddressLine != '')
            PassyPadding(RecordButton(
                title: localizations.secondAddressLine,
                value: identity.secondAddressLine)),
          if (identity.zipCode != '')
            PassyPadding(RecordButton(
              title: localizations.zipCode,
              value: identity.zipCode,
            )),
          if (identity.city != '')
            PassyPadding(RecordButton(
              title: localizations.city,
              value: identity.city,
            )),
          if (identity.country != '')
            PassyPadding(RecordButton(
              title: localizations.country,
              value: identity.country,
            )),
          for (CustomField customField in identity.customFields)
            PassyPadding(CustomFieldButton(customField: customField)),
          if (identity.additionalInfo != '')
            PassyPadding(RecordButton(
                title: localizations.additionalInfo,
                value: identity.additionalInfo)),
        ],
      ),
    );
  }
}
