import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passy_browser_extension/common/common.dart';
import 'package:passy_browser_extension/passy_data/entry_event.dart';
import 'package:passy_browser_extension/passy_data/entry_meta.dart';
import 'package:passy_browser_extension/passy_data/id_card.dart';
import 'package:passy_browser_extension/passy_data/identity.dart';
import 'package:passy_browser_extension/passy_data/note.dart';
import 'package:passy_browser_extension/passy_data/payment_card.dart';
import 'package:passy_browser_extension/screens/common/entry_screen_args.dart';

import '../passy_data/entry_type.dart';
import '../passy_data/password.dart';
import '../passy_data/passy_entry.dart';
import '../passy_flutter/passy_flutter.dart';
import 'common/common.dart';
import 'id_card_screen.dart';
import 'id_cards_screen.dart';
import 'identities_screen.dart';
import 'identity_screen.dart';
import 'note_screen.dart';
import 'notes_screen.dart';
import 'password_screen.dart';
import 'passwords_screen.dart';
import 'payment_card_screen.dart';
import 'payment_cards_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  static bool shouldLockScreen = true;

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Widget _searchBuilder(
    String terms, {
    required Map<String, IDCardMeta> idCardsMetadata,
    required Map<String, IdentityMeta> identitiesMetadata,
    required Map<String, NoteMeta> notesMetadata,
    required Map<String, PasswordMeta> passwordsMetadata,
    required Map<String, PaymentCardMeta> paymentCardsMetadata,
  }) {
    final List<SearchEntryData> found = [];
    final List<String> termsSplit = terms.trim().toLowerCase().split(' ');
    final List<SearchEntryData> searchEntries = [];
    if (idCardsMetadata.isEmpty &&
        identitiesMetadata.isEmpty &&
        notesMetadata.isEmpty &&
        passwordsMetadata.isEmpty &&
        paymentCardsMetadata.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                const Spacer(flex: 7),
                Text(
                  localizations.noEntries,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 7),
              ],
            ),
          ),
        ],
      );
    }
    for (IDCardMeta idCard in idCardsMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: idCard.nickname,
          description: idCard.name,
          type: EntryType.idCard,
          meta: idCard));
    }
    for (IdentityMeta identity in identitiesMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: identity.nickname,
          description: identity.firstAddressLine,
          type: EntryType.identity,
          meta: identity));
    }
    for (NoteMeta note in notesMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: note.title, description: '', type: EntryType.note, meta: note));
    }
    for (PasswordMeta password in passwordsMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: password.nickname,
          description: password.username,
          type: EntryType.password,
          meta: password));
    }
    for (PaymentCardMeta paymentCard in paymentCardsMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: paymentCard.nickname,
          description: paymentCard.cardholderName,
          type: EntryType.paymentCard,
          meta: paymentCard));
    }
    for (SearchEntryData searchEntry in searchEntries) {
      {
        bool testSearchEntry(SearchEntryData value) =>
            searchEntry.meta.key == value.meta.key;

        if (found.any(testSearchEntry)) continue;
      }
      {
        int positiveCount = 0;
        for (String term in termsSplit) {
          if (searchEntry.name.toLowerCase().contains(term)) {
            positiveCount++;
            continue;
          }
          if (searchEntry.description.toLowerCase().contains(term)) {
            positiveCount++;
            continue;
          }
        }
        if (positiveCount == termsSplit.length) {
          found.add(searchEntry);
        }
      }
    }
    if (found.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                const Spacer(flex: 7),
                Text(
                  localizations.noSearchResults,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 7),
              ],
            ),
          ),
        ],
      );
    }
    return PassyEntryButtonListView(
      entries: found,
      shouldSort: true,
      onPressed: (searchEntry) async {
        PassyEntry? entry =
            await data.getEntry(searchEntry.type, key: searchEntry.meta.key);

        if (entry == null) return;
        bool isFavorite = (await data.getFavoriteEntries(
                    searchEntry.type))?[searchEntry.meta.key]
                ?.status ==
            EntryStatus.alive;
        EntryScreenArgs args =
            EntryScreenArgs(entry: entry, isFavorite: isFavorite);

        if (!mounted) return;
        String routeName = '';
        switch (searchEntry.type) {
          case EntryType.idCard:
            routeName = IDCardScreen.routeName;
            break;
          case EntryType.identity:
            routeName = IdentityScreen.routeName;
            break;
          case EntryType.note:
            routeName = NoteScreen.routeName;
            break;
          case EntryType.password:
            routeName = PasswordScreen.routeName;
            break;
          case EntryType.paymentCard:
            routeName = PaymentCardScreen.routeName;
            break;
        }
        Navigator.pushNamed(context, routeName, arguments: args);
      },
      popupMenuItemBuilder: passyEntryPopupMenuItemBuilder,
    );
  }

  Widget _favoritesSearchBuilder(
    String terms, {
    required Map<String, IDCardMeta> idCardsMetadata,
    required Map<String, IdentityMeta> identitiesMetadata,
    required Map<String, NoteMeta> notesMetadata,
    required Map<String, PasswordMeta> passwordsMetadata,
    required Map<String, PaymentCardMeta> paymentCardsMetadata,
    required Map<String, EntryEvent> favoriteIDCards,
    required Map<String, EntryEvent> favoriteIdentities,
    required Map<String, EntryEvent> favoriteNotes,
    required Map<String, EntryEvent> favoritePasswords,
    required Map<String, EntryEvent> favoritePaymentCards,
  }) {
    if (favoriteIDCards.isEmpty &&
        favoriteIdentities.isEmpty &&
        favoriteNotes.isEmpty &&
        favoritePasswords.isEmpty &&
        favoritePaymentCards.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                const Spacer(flex: 7),
                PassyPadding(RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: GoogleFonts.roboto(
                            textStyle: Theme.of(context).textTheme.bodyMedium),
                        text: '${localizations.noFavorites}.',
                        children: [
                          TextSpan(text: '\n\n${localizations.noFavorites1}'),
                          const WidgetSpan(
                              child: Icon(Icons.star_outline_rounded)),
                          TextSpan(text: ' ${localizations.noFavorites2}.'),
                        ]))),
                const Spacer(flex: 7),
              ],
            ),
          ),
        ],
      );
    }
    final List<SearchEntryData> found = [];
    final List<String> termsSplit = terms.trim().toLowerCase().split(' ');
    final List<SearchEntryData> searchEntries = [];
    for (EntryEvent event in favoriteIDCards.values) {
      if (event.status == EntryStatus.removed) continue;
      IDCardMeta? idCard = idCardsMetadata[event.key];
      if (idCard == null) continue;
      searchEntries.add(SearchEntryData(
          name: idCard.nickname,
          description: idCard.name,
          type: EntryType.idCard,
          meta: idCard));
    }
    for (EntryEvent event in favoriteIdentities.values) {
      if (event.status == EntryStatus.removed) continue;
      IdentityMeta? identity = identitiesMetadata[event.key];
      if (identity == null) continue;
      searchEntries.add(SearchEntryData(
          name: identity.nickname,
          description: identity.firstAddressLine,
          type: EntryType.identity,
          meta: identity));
    }
    for (EntryEvent event in favoriteNotes.values) {
      if (event.status == EntryStatus.removed) continue;
      NoteMeta? note = notesMetadata[event.key];
      if (note == null) continue;
      searchEntries.add(SearchEntryData(
          name: note.title, description: '', type: EntryType.note, meta: note));
    }
    for (EntryEvent event in favoritePasswords.values) {
      if (event.status == EntryStatus.removed) continue;
      PasswordMeta? password = passwordsMetadata[event.key];
      if (password == null) continue;
      searchEntries.add(SearchEntryData(
          name: password.nickname,
          description: password.username,
          type: EntryType.password,
          meta: password));
    }
    for (EntryEvent event in favoritePaymentCards.values) {
      if (event.status == EntryStatus.removed) continue;
      PaymentCardMeta? paymentCard = paymentCardsMetadata[event.key];
      if (paymentCard == null) continue;
      searchEntries.add(SearchEntryData(
          name: paymentCard.nickname,
          description: paymentCard.cardholderName,
          type: EntryType.paymentCard,
          meta: paymentCard));
    }
    for (SearchEntryData searchEntry in searchEntries) {
      {
        bool testSearchEntry(SearchEntryData value) =>
            searchEntry.meta.key == value.meta.key;

        if (found.any(testSearchEntry)) continue;
      }
      {
        int positiveCount = 0;
        for (String term in termsSplit) {
          if (searchEntry.name.toLowerCase().contains(term)) {
            positiveCount++;
            continue;
          }
          if (searchEntry.description.toLowerCase().contains(term)) {
            positiveCount++;
            continue;
          }
        }
        if (positiveCount == termsSplit.length) {
          found.add(searchEntry);
        }
      }
    }
    if (found.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                const Spacer(flex: 7),
                Text(
                  localizations.noSearchResults,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 7),
              ],
            ),
          ),
        ],
      );
    }
    return PassyEntryButtonListView(
      entries: found,
      shouldSort: true,
      onPressed: (searchEntry) async {
        PassyEntry? entry =
            await data.getEntry(searchEntry.type, key: searchEntry.meta.key);

        if (entry == null) return;
        bool isFavorite = (await data.getFavoriteEntries(
                    searchEntry.type))?[searchEntry.meta.key]
                ?.status ==
            EntryStatus.alive;
        EntryScreenArgs args =
            EntryScreenArgs(entry: entry, isFavorite: isFavorite);

        if (!mounted) return;
        String routeName = '';
        switch (searchEntry.type) {
          case EntryType.idCard:
            routeName = IDCardScreen.routeName;
            break;
          case EntryType.identity:
            routeName = IdentityScreen.routeName;
            break;
          case EntryType.note:
            routeName = NoteScreen.routeName;
            break;
          case EntryType.password:
            routeName = PasswordScreen.routeName;
            break;
          case EntryType.paymentCard:
            routeName = PaymentCardScreen.routeName;
            break;
        }
        Navigator.pushNamed(context, routeName, arguments: args);
      },
      popupMenuItemBuilder: passyEntryPopupMenuItemBuilder,
    );
  }

  @override
  void initState() {
    super.initState();
    CurrentEntry? currentEntry = data.currentEntry;
    if (currentEntry != null) {
      Future(() async {
        dynamic entries = (await data.getEntriesMetadata(currentEntry.type))
                ?.values
                .toList() ??
            <EntryMeta>[];
        switch (currentEntry.type) {
          case EntryType.password:
            entries = List<PasswordMeta>.from(entries);
            break;
          case EntryType.paymentCard:
            entries = List<PaymentCardMeta>.from(entries);
            break;
          case EntryType.note:
            entries = List<NoteMeta>.from(entries);
            break;
          case EntryType.idCard:
            entries = List<IDCardMeta>.from(entries);
            break;
          case EntryType.identity:
            entries = List<IdentityMeta>.from(entries);
            break;
        }
        PassyEntry? entry =
            await data.getEntry(currentEntry.type, key: currentEntry.key);
        bool isFavorite = (await data
                    .getFavoriteEntries(currentEntry.type))?[currentEntry.key]
                ?.status ==
            EntryStatus.alive;
        if (entry == null) {
          data.setCurrentEntry(null);
          return;
        }
        if (!mounted) return;
        Navigator.pushNamed(
            context, entryTypeToEntriesScreenName(currentEntry.type),
            arguments: entries);
        Navigator.pushNamed(
            context, entryTypeToEntryScreenName(currentEntry.type),
            arguments: EntryScreenArgs(entry: entry, isFavorite: isFavorite));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screenButtons = [
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.star_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.favorites),
        onPressed: () async {
          Map<String, IDCardMeta>? idCards = await data.getIDCardsMetadata();
          if (idCards == null) return;
          Map<String, IdentityMeta>? identities =
              await data.getIdentitiesMetadata();
          if (identities == null) return;
          Map<String, PasswordMeta>? passwords =
              await data.getPasswordsMetadata();
          if (passwords == null) return;
          Map<String, NoteMeta>? notes = await data.getNotesMetadata();
          if (notes == null) return;
          Map<String, PaymentCardMeta>? paymentCards =
              await data.getPaymentCardsMetadata();
          if (paymentCards == null) return;
          Map<String, EntryEvent>? favoriteIDCards =
              await data.getFavoriteIDCards();
          if (favoriteIDCards == null) return;
          Map<String, EntryEvent>? favoriteIdentities =
              await data.getFavoriteIdentities();
          if (favoriteIdentities == null) return;
          Map<String, EntryEvent>? favoritePasswords =
              await data.getFavoritePasswords();
          if (favoritePasswords == null) return;
          Map<String, EntryEvent>? favoriteNotes =
              await data.getFavoriteNotes();
          if (favoriteNotes == null) return;
          Map<String, EntryEvent>? favoritePaymentCards =
              await data.getFavoritePaymentCards();
          if (favoritePaymentCards == null) return;
          if (mounted) {
            Navigator.pushNamed(context, SearchScreen.routeName,
                arguments: SearchScreenArgs(
                  title: localizations.favorites,
                  builder: (terms) => _favoritesSearchBuilder(
                    terms,
                    idCardsMetadata: idCards,
                    identitiesMetadata: identities,
                    passwordsMetadata: passwords,
                    notesMetadata: notes,
                    paymentCardsMetadata: paymentCards,
                    favoriteIDCards: favoriteIDCards,
                    favoriteIdentities: favoriteIdentities,
                    favoriteNotes: favoriteNotes,
                    favoritePasswords: favoritePasswords,
                    favoritePaymentCards: favoritePaymentCards,
                  ),
                ));
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(CupertinoIcons.globe),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.searchAllEntries),
        onPressed: () async {
          Map<String, IDCardMeta>? idCards = await data.getIDCardsMetadata();
          if (idCards == null) return;
          Map<String, IdentityMeta>? identities =
              await data.getIdentitiesMetadata();
          if (identities == null) return;
          Map<String, PasswordMeta>? passwords =
              await data.getPasswordsMetadata();
          if (passwords == null) return;
          Map<String, NoteMeta>? notes = await data.getNotesMetadata();
          if (notes == null) return;
          Map<String, PaymentCardMeta>? paymentCards =
              await data.getPaymentCardsMetadata();
          if (paymentCards == null) return;
          if (mounted) {
            Navigator.pushNamed(context, SearchScreen.routeName,
                arguments: SearchScreenArgs(
                  title: localizations.allEntries,
                  builder: (terms) => _searchBuilder(
                    terms,
                    idCardsMetadata: idCards,
                    identitiesMetadata: identities,
                    passwordsMetadata: passwords,
                    notesMetadata: notes,
                    paymentCardsMetadata: paymentCards,
                  ),
                ));
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.password_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.passwords),
        onPressed: () async {
          List<PasswordMeta> passwords =
              (await data.getPasswordsMetadata())?.values.toList() ??
                  <PasswordMeta>[];
          if (mounted) {
            Navigator.pushNamed(context, PasswordsScreen.routeName,
                arguments: passwords);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.payment_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.paymentCards),
        onPressed: () async {
          List<PaymentCardMeta> paymentCards =
              (await data.getPaymentCardsMetadata())?.values.toList() ??
                  <PaymentCardMeta>[];
          if (mounted) {
            Navigator.pushNamed(context, PaymentCardsScreen.routeName,
                arguments: paymentCards);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.note_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.notes),
        onPressed: () async {
          List<NoteMeta> notes =
              (await data.getNotesMetadata())?.values.toList() ?? <NoteMeta>[];
          if (mounted) {
            Navigator.pushNamed(context, NotesScreen.routeName,
                arguments: notes);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.perm_identity_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.idCards),
        onPressed: () async {
          List<IDCardMeta> idCards =
              (await data.getIDCardsMetadata())?.values.toList() ??
                  <IDCardMeta>[];
          if (mounted) {
            Navigator.pushNamed(context, IDCardsScreen.routeName,
                arguments: idCards);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.people_outline_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.identities),
        onPressed: () async {
          List<IdentityMeta> identities =
              (await data.getIdentitiesMetadata())?.values.toList() ??
                  <IdentityMeta>[];
          if (mounted) {
            Navigator.pushNamed(context, IdentitiesScreen.routeName,
                arguments: identities);
          }
        },
      )),
    ];

    return WillPopScope(
      onWillPop: () => logoutOnWillPop(this),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Passy'),
          leading: IconButton(
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            padding: PassyTheme.appBarButtonPadding,
            tooltip: localizations.logOut,
            icon: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: const Icon(Icons.exit_to_app_rounded),
            ),
            onPressed: () => logOut(this),
          ),
          actions: [
            IconButton(
              padding: PassyTheme.appBarButtonPadding,
              tooltip: localizations.search,
              onPressed: () async {
                Map<String, IDCardMeta>? idCards =
                    await data.getIDCardsMetadata();
                if (idCards == null) return;
                Map<String, IdentityMeta>? identities =
                    await data.getIdentitiesMetadata();
                if (identities == null) return;
                Map<String, PasswordMeta>? passwords =
                    await data.getPasswordsMetadata();
                if (passwords == null) return;
                Map<String, NoteMeta>? notes = await data.getNotesMetadata();
                if (notes == null) return;
                Map<String, PaymentCardMeta>? paymentCards =
                    await data.getPaymentCardsMetadata();
                if (paymentCards == null) return;
                if (mounted) {
                  Navigator.pushNamed(context, SearchScreen.routeName,
                      arguments: SearchScreenArgs(
                        title: localizations.allEntries,
                        builder: (terms) => _searchBuilder(
                          terms,
                          idCardsMetadata: idCards,
                          identitiesMetadata: identities,
                          passwordsMetadata: passwords,
                          notesMetadata: notes,
                          paymentCardsMetadata: paymentCards,
                        ),
                      ));
                }
              },
              icon: const Icon(Icons.search_rounded),
              splashRadius: PassyTheme.appBarButtonSplashRadius,
            ),
            IconButton(
              padding: PassyTheme.appBarButtonPadding,
              tooltip: localizations.settings,
              onPressed: () =>
                  Navigator.pushNamed(context, SettingsScreen.routeName),
              icon: const Icon(Icons.settings),
              splashRadius: PassyTheme.appBarButtonSplashRadius,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (ctx, constr) {
            if (constr.maxWidth >= 1100) {
              return Row(children: [
                Expanded(
                    child: ListView(
                  children: [
                    screenButtons[0],
                    screenButtons[1],
                    screenButtons[2],
                  ],
                )),
                Expanded(
                    child: ListView(
                  children: [
                    screenButtons[3],
                    screenButtons[4],
                    screenButtons[5],
                  ],
                )),
                Expanded(
                    child: ListView(
                  children: [
                    screenButtons[6],
                    screenButtons[7],
                  ],
                ))
              ]);
            }
            if (constr.maxWidth >= 700) {
              return Row(children: [
                Expanded(
                  child: ListView(children: [
                    screenButtons[0],
                    screenButtons[1],
                    screenButtons[2],
                    screenButtons[3],
                  ]),
                ),
                Expanded(
                    child: ListView(
                  children: [
                    screenButtons[4],
                    screenButtons[5],
                    screenButtons[6],
                    screenButtons[7],
                  ],
                )),
              ]);
            }
            return ListView(children: screenButtons);
          },
        ),
      ),
    );
  }
}
