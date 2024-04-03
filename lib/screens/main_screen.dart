import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passy_browser_extension/common/common.dart';
import 'package:passy_browser_extension/passy_data/entry_event.dart';
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
    String terms,
    List<String> tags, {
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
          meta: idCard,
          tags: idCard.tags));
    }
    for (IdentityMeta identity in identitiesMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: identity.nickname,
          description: identity.firstAddressLine,
          type: EntryType.identity,
          meta: identity,
          tags: identity.tags));
    }
    for (NoteMeta note in notesMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: note.title,
          description: '',
          type: EntryType.note,
          meta: note,
          tags: note.tags));
    }
    for (PasswordMeta password in passwordsMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: password.nickname,
          description: password.username,
          type: EntryType.password,
          meta: password,
          tags: password.tags));
    }
    for (PaymentCardMeta paymentCard in paymentCardsMetadata.values) {
      searchEntries.add(SearchEntryData(
          name: paymentCard.nickname,
          description: paymentCard.cardholderName,
          type: EntryType.paymentCard,
          meta: paymentCard,
          tags: paymentCard.tags));
    }
    for (SearchEntryData searchEntry in searchEntries) {
      {
        bool testSearchEntry(SearchEntryData value) =>
            searchEntry.meta.key == value.meta.key;

        if (found.any(testSearchEntry)) continue;
      }
      {
        bool tagMismatch = false;
        for (String tag in tags) {
          if (!searchEntry.tags.contains(tag)) {
            tagMismatch = true;
            break;
          }
        }
        if (tagMismatch) continue;
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
    String terms,
    List<String> tags,
    void Function() setState, {
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
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontFamily: 'Roboto'),
                        text: '${localizations.noFavorites}.',
                        children: [
                          TextSpan(text: '\n\n${localizations.noFavorites1}'),
                          const WidgetSpan(
                              child: Icon(Symbols.star_rounded, weight: 700)),
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
          meta: idCard,
          tags: idCard.tags));
    }
    for (EntryEvent event in favoriteIdentities.values) {
      if (event.status == EntryStatus.removed) continue;
      IdentityMeta? identity = identitiesMetadata[event.key];
      if (identity == null) continue;
      searchEntries.add(SearchEntryData(
          name: identity.nickname,
          description: identity.firstAddressLine,
          type: EntryType.identity,
          meta: identity,
          tags: identity.tags));
    }
    for (EntryEvent event in favoriteNotes.values) {
      if (event.status == EntryStatus.removed) continue;
      NoteMeta? note = notesMetadata[event.key];
      if (note == null) continue;
      searchEntries.add(SearchEntryData(
          name: note.title,
          description: '',
          type: EntryType.note,
          meta: note,
          tags: note.tags));
    }
    for (EntryEvent event in favoritePasswords.values) {
      if (event.status == EntryStatus.removed) continue;
      PasswordMeta? password = passwordsMetadata[event.key];
      if (password == null) continue;
      searchEntries.add(SearchEntryData(
          name: password.nickname,
          description: password.username,
          type: EntryType.password,
          meta: password,
          tags: password.tags));
    }
    for (EntryEvent event in favoritePaymentCards.values) {
      if (event.status == EntryStatus.removed) continue;
      PaymentCardMeta? paymentCard = paymentCardsMetadata[event.key];
      if (paymentCard == null) continue;
      searchEntries.add(SearchEntryData(
          name: paymentCard.nickname,
          description: paymentCard.cardholderName,
          type: EntryType.paymentCard,
          meta: paymentCard,
          tags: paymentCard.tags));
    }
    for (SearchEntryData searchEntry in searchEntries) {
      {
        bool testSearchEntry(SearchEntryData value) =>
            searchEntry.meta.key == value.meta.key;

        if (found.any(testSearchEntry)) continue;
      }
      {
        bool tagMismatch = false;
        for (String tag in tags) {
          if (!searchEntry.tags.contains(tag)) {
            tagMismatch = true;
            break;
          }
        }
        if (tagMismatch) continue;
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
        Navigator.pushNamed(context, routeName, arguments: args)
            .then((value) => setState());
      },
      popupMenuItemBuilder: passyEntryPopupMenuItemBuilder,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screenButtons = [
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Symbols.star_rounded, weight: 700, fill: 1),
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
          if (context.mounted) {
            Navigator.pushNamed(context, SearchScreen.routeName,
                arguments: SearchScreenArgs(
                  title: localizations.favorites,
                  entryType: null,
                  builder: (terms, tags, rebuild) => _favoritesSearchBuilder(
                    terms,
                    tags,
                    rebuild,
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
          if (context.mounted) {
            Navigator.pushNamed(context, SearchScreen.routeName,
                arguments: SearchScreenArgs(
                  entryType: null,
                  title: localizations.allEntries,
                  builder: (terms, tags, rebuild) => _searchBuilder(
                    terms,
                    tags,
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
          child: Icon(Symbols.password_rounded, weight: 700),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.passwords),
        onPressed: () async {
          List<PasswordMeta> passwords =
              (await data.getPasswordsMetadata())?.values.toList() ??
                  <PasswordMeta>[];
          if (context.mounted) {
            Navigator.pushNamed(context, PasswordsScreen.routeName,
                arguments: passwords);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Symbols.payment_rounded, weight: 700),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.paymentCards),
        onPressed: () async {
          List<PaymentCardMeta> paymentCards =
              (await data.getPaymentCardsMetadata())?.values.toList() ??
                  <PaymentCardMeta>[];
          if (context.mounted) {
            Navigator.pushNamed(context, PaymentCardsScreen.routeName,
                arguments: paymentCards);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Symbols.note_rounded, weight: 700, fill: 1),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.notes),
        onPressed: () async {
          List<NoteMeta> notes =
              (await data.getNotesMetadata())?.values.toList() ?? <NoteMeta>[];
          if (context.mounted) {
            Navigator.pushNamed(context, NotesScreen.routeName,
                arguments: notes);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Symbols.perm_identity_rounded, weight: 700),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.idCards),
        onPressed: () async {
          List<IDCardMeta> idCards =
              (await data.getIDCardsMetadata())?.values.toList() ??
                  <IDCardMeta>[];
          if (context.mounted) {
            Navigator.pushNamed(context, IDCardsScreen.routeName,
                arguments: idCards);
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Symbols.people_outline_rounded, weight: 700),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.identities),
        onPressed: () async {
          List<IdentityMeta> identities =
              (await data.getIdentitiesMetadata())?.values.toList() ??
                  <IdentityMeta>[];
          if (context.mounted) {
            Navigator.pushNamed(context, IdentitiesScreen.routeName,
                arguments: identities);
          }
        },
      )),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (isPopped) => logoutOnWillPop(this),
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
                if (context.mounted) {
                  Navigator.pushNamed(context, SearchScreen.routeName,
                      arguments: SearchScreenArgs(
                        entryType: null,
                        title: localizations.allEntries,
                        builder: (terms, tags, rebuild) => _searchBuilder(
                          terms,
                          tags,
                          idCardsMetadata: idCards,
                          identitiesMetadata: identities,
                          passwordsMetadata: passwords,
                          notesMetadata: notes,
                          paymentCardsMetadata: paymentCards,
                        ),
                      ));
                }
              },
              icon: const Icon(Symbols.search_rounded, weight: 700),
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
