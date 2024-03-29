import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../common/common.dart';
import '../passy_data/custom_field.dart';
import '../passy_data/entry_type.dart';
import '../passy_data/id_card.dart';
import '../passy_flutter/common/common.dart';
import '../passy_flutter/passy_flutter.dart';
import 'edit_id_card_screen.dart';
import 'id_cards_screen.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

class IDCardScreen extends StatefulWidget {
  const IDCardScreen({Key? key}) : super(key: key);

  static const routeName = '/idCard';

  @override
  State<StatefulWidget> createState() => _IDCardScreen();
}

class _IDCardScreen extends State<IDCardScreen> {
  bool isFavorite = false;
  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    final EntryScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as EntryScreenArgs;
    final IDCard idCard = args.entry as IDCard;
    if (!isLoaded) {
      isLoaded = true;
      isFavorite = args.isFavorite;
    }

    void onRemovePressed() {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              shape: PassyTheme.dialogShape,
              title: Text(localizations.removeIDCard),
              content:
                  Text('${localizations.idCardsCanOnlyBeRestoredFromABackup}.'),
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
                    await data.removeIDCard(idCard.key);
                    List<IDCardMeta> idCards =
                        (await data.getIDCardsMetadata())?.values.toList() ??
                            <IDCardMeta>[];
                    if (!mounted) return;
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, IDCardsScreen.routeName,
                        arguments: idCards);
                  },
                )
              ],
            );
          });
    }

    void onEditPressed() {
      Navigator.pushNamed(
        context,
        EditIDCardScreen.routeName,
        arguments: idCard,
      );
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.idCard,
        entryKey: idCard.key,
        title: Center(child: Text(localizations.idCard)),
        onRemovePressed: () => onRemovePressed(),
        onEditPressed: () => onEditPressed(),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await data.toggleFavoriteIDCard(idCard.key, false);
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
            await data.toggleFavoriteIDCard(idCard.key, true);
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
          if (idCard.nickname != '')
            PassyPadding(RecordButton(
              title: localizations.nickname,
              value: idCard.nickname,
            )),
          if (idCard.type != '')
            PassyPadding(RecordButton(
              title: localizations.type,
              value: idCard.type,
            )),
          if (idCard.idNumber != '')
            PassyPadding(RecordButton(
              title: localizations.idNumber,
              value: idCard.idNumber,
            )),
          if (idCard.name != '')
            PassyPadding(RecordButton(
              title: localizations.name,
              value: idCard.name,
            )),
          if (idCard.country != '')
            PassyPadding(RecordButton(
                title: localizations.country, value: idCard.country)),
          if (idCard.issDate != '')
            PassyPadding(RecordButton(
                title: localizations.dateOfIssue, value: idCard.issDate)),
          if (idCard.expDate != '')
            PassyPadding(RecordButton(
                title: localizations.expirationDate, value: idCard.expDate)),
          for (CustomField customField in idCard.customFields)
            PassyPadding(CustomFieldButton(customField: customField)),
          if (idCard.additionalInfo != '')
            PassyPadding(RecordButton(
                title: localizations.additionalInfo,
                value: idCard.additionalInfo)),
        ],
      ),
    );
  }
}
