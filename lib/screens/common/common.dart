import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy_browser_extension/passy_flutter/passy_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../common/common.dart';
import '../../passy_data/entry_type.dart';
import '../../passy_data/id_card.dart';
import '../../passy_data/identity.dart';
import '../../passy_data/note.dart';
import '../../passy_data/password.dart';
import '../../passy_data/payment_card.dart';
import '../../passy_flutter/common/common.dart';
import '../login_screen.dart';

void logOut(State state) {
  showDialog(
    context: state.context,
    builder: (ctx) {
      return AlertDialog(
        shape: PassyTheme.dialogShape,
        title: Text(localizations.logOut),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                localizations.stay,
                style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor),
              )),
          TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await data.logout();
                if (state.mounted) {
                  Navigator.pushReplacementNamed(
                      state.context, LoginScreen.routeName);
                }
              },
              child: Text(
                localizations.logOut,
                style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor),
              )),
        ],
        content: Text(localizations.areYouSureYouWantToLogOutQuestion),
      );
    },
  );
}

Future<bool> logoutOnWillPop(State state) {
  logOut(state);
  return Future.value(false);
}

PopupMenuItem getIconedPopupMenuItem({
  required Widget content,
  required Widget icon,
  void Function()? onTap,
}) {
  return PopupMenuItem(
    onTap: onTap,
    child: Row(
      children: [icon, const SizedBox(width: 20), content],
    ),
  );
}

List<PopupMenuEntry> idCardPopupMenuBuilder(
    State state, IDCardMeta idCardMeta) {
  return [
    getIconedPopupMenuItem(
      content: const Text('ID number'),
      icon: const Icon(Icons.numbers_outlined),
      onTap: () async {
        IDCard? idCard = await data.getIDCard(idCardMeta.key);
        if (idCard == null) return;
        Clipboard.setData(ClipboardData(text: idCard.idNumber));
        if (state.mounted) {
          showSnackBar(state.context,
              message: 'ID number copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        }
      },
    ),
    if (idCardMeta.name != '')
      getIconedPopupMenuItem(
        content: const Text('Name'),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(ClipboardData(text: idCardMeta.name));
          showSnackBar(state.context,
              message: 'Name copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
  ];
}

List<PopupMenuEntry> identityPopupMenuBuilder(
    State state, IdentityMeta identityMeta) {
  return [
    getIconedPopupMenuItem(
      content: const Text('Name'),
      icon: const Icon(Icons.person_outline_rounded),
      onTap: () async {
        Identity? identity = await data.getIdentity(identityMeta.key);
        if (identity == null) return;
        String name = identity.firstName;
        if (name == '') {
          name = identity.middleName;
        } else {
          name += ' ${identity.middleName}';
        }
        if (name == '') {
          name = identity.lastName;
        } else {
          name += ' ${identity.lastName}';
        }
        Clipboard.setData(ClipboardData(text: name));
        if (state.mounted) {
          showSnackBar(state.context,
              message: 'Name copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        }
      },
    ),
    getIconedPopupMenuItem(
      content: const Text('Email'),
      icon: const Icon(Icons.mail_outline_rounded),
      onTap: () async {
        Identity? identity = await data.getIdentity(identityMeta.key);
        if (identity == null) return;
        Clipboard.setData(ClipboardData(text: identity.email));
        if (state.mounted) {
          showSnackBar(state.context,
              message: 'Email copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        }
      },
    ),
    if (identityMeta.firstAddressLine != '')
      getIconedPopupMenuItem(
        content: const Text('Address line'),
        icon: const Icon(Icons.house_outlined),
        onTap: () {
          Clipboard.setData(ClipboardData(text: identityMeta.firstAddressLine));
          if (state.mounted) {
            showSnackBar(state.context,
                message: 'Address line copied',
                icon: const Icon(Icons.copy_rounded,
                    color: PassyTheme.darkContentColor));
          }
        },
      ),
  ];
}

List<PopupMenuEntry> notePopupMenuBuilder(State state, NoteMeta noteMeta) {
  return [
    getIconedPopupMenuItem(
      content: const Text('Copy'),
      icon: const Icon(Icons.copy_rounded),
      onTap: () async {
        Note? note = await data.getNote(noteMeta.key);
        if (note == null) return;
        Clipboard.setData(ClipboardData(text: note.note));
        if (state.mounted) {
          showSnackBar(state.context,
              message: 'Note copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        }
      },
    ),
  ];
}

List<PopupMenuEntry> passwordPopupMenuBuilder(
    State state, PasswordMeta passwordMeta) {
  return [
    if (passwordMeta.username != '')
      getIconedPopupMenuItem(
        content: const Text('Username'),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(ClipboardData(text: passwordMeta.username));
          showSnackBar(state.context,
              message: 'Username copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    getIconedPopupMenuItem(
      content: const Text('Email'),
      icon: const Icon(Icons.mail_outline_rounded),
      onTap: () async {
        Password? password = await data.getPassword(passwordMeta.key);
        if (password == null) return;
        Clipboard.setData(ClipboardData(text: password.email));
        if (state.mounted) {
          showSnackBar(state.context,
              message: 'Email copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        }
      },
    ),
    getIconedPopupMenuItem(
      content: const Text('Password'),
      icon: const Icon(Icons.lock_outline_rounded),
      onTap: () async {
        Password? password = await data.getPassword(passwordMeta.key);
        if (password == null) return;
        Clipboard.setData(ClipboardData(text: password.password));
        if (state.mounted) {
          showSnackBar(state.context,
              message: 'Password copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        }
      },
    ),
    if (passwordMeta.website != '')
      getIconedPopupMenuItem(
        content: const Text('Visit'),
        icon: const Icon(Icons.open_in_browser_outlined),
        onTap: () async {
          String? url = (await data.getPassword(passwordMeta.key))?.website;
          if (url == null) return;
          if (!url.contains(RegExp('http:\\/\\/|https:\\/\\/'))) {
            url = 'http://$url';
          }
          try {
            launchUrlString(url);
          } catch (_) {}
        },
      ),
  ];
}

List<PopupMenuEntry> paymentCardPopupMenuBuilder(
    State state, PaymentCardMeta paymentCardMeta) {
  return [
    if (paymentCardMeta.cardNumber != '')
      getIconedPopupMenuItem(
        content: const Text('Card number'),
        icon: const Icon(Icons.numbers_outlined),
        onTap: () async {
          PaymentCard? paymentCard =
              await data.getPaymentCard(paymentCardMeta.key);
          if (paymentCard == null) return;
          Clipboard.setData(ClipboardData(text: paymentCard.cardNumber));
          if (state.mounted) {
            showSnackBar(state.context,
                message: 'Card number copied',
                icon: const Icon(Icons.copy_rounded,
                    color: PassyTheme.darkContentColor));
          }
        },
      ),
    if (paymentCardMeta.cardholderName != '')
      getIconedPopupMenuItem(
        content: const Text('Card holder name'),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(
              ClipboardData(text: paymentCardMeta.cardholderName));
          showSnackBar(state.context,
              message: 'Card holder name copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    if (paymentCardMeta.exp != '')
      getIconedPopupMenuItem(
        content: const Text('Expiration date'),
        icon: const Icon(Icons.date_range_outlined),
        onTap: () {
          Clipboard.setData(ClipboardData(text: paymentCardMeta.exp));
          showSnackBar(state.context,
              message: 'Expiration date copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    getIconedPopupMenuItem(
      content: const Text('CVV'),
      icon: const Icon(Icons.password_outlined),
      onTap: () async {
        PaymentCard? paymentCard =
            await data.getPaymentCard(paymentCardMeta.key);
        if (paymentCard == null) return;
        Clipboard.setData(ClipboardData(text: paymentCard.cvv));
        if (state.mounted) {
          showSnackBar(state.context,
              message: 'CVV copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        }
      },
    ),
  ];
}

List<PopupMenuEntry> passyEntryPopupMenuItemBuilder(
    State state, SearchEntryData entry) {
  switch (entry.type) {
    case EntryType.idCard:
      return idCardPopupMenuBuilder(state, entry.meta as IDCardMeta);
    case EntryType.identity:
      return identityPopupMenuBuilder(state, entry.meta as IdentityMeta);
    case EntryType.note:
      return notePopupMenuBuilder(state, entry.meta as NoteMeta);
    case EntryType.password:
      return passwordPopupMenuBuilder(state, entry.meta as PasswordMeta);
    case EntryType.paymentCard:
      return paymentCardPopupMenuBuilder(state, entry.meta as PaymentCardMeta);
  }
}

String genderToReadableName(Gender gender) {
  switch (gender) {
    case Gender.notSpecified:
      return localizations.notSpecified;
    case Gender.male:
      return localizations.male;
    case Gender.female:
      return localizations.female;
    case Gender.other:
      return localizations.other;
  }
}
