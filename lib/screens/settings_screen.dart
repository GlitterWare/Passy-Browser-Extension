import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passy_browser_extension/common/raw_interop.dart';
import 'package:passy_browser_extension/passy_flutter/passy_flutter.dart';
import 'package:vector_graphics/vector_graphics.dart';
import '../common/common.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/settings';

  @override
  State<StatefulWidget> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.settings),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                PassyPadding(ThreeWidgetButton(
                  center: Text(localizations.donate),
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.money_rounded),
                  ),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () =>
                      createTab('https://github.com/sponsors/GlitterWare'),
                )),
                PassyPadding(ThreeWidgetButton(
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: SvgPicture(
                      AssetBytesLoader('assets/images/github_icon.svg.vec'),
                      width: 26,
                      colorFilter: ColorFilter.mode(
                          PassyTheme.lightContentColor, BlendMode.srcIn),
                    ),
                  ),
                  center: Text(localizations.requestAFeature),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => createTab(
                    'https://github.com/GlitterWare/Passy/issues',
                  ),
                )),
                PassyPadding(ThreeWidgetButton(
                  center: Text(localizations.privacyPolicy),
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Symbols.shield_moon_rounded, weight: 700),
                  ),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => createTab(
                      'https://github.com/GlitterWare/Passy/blob/main/PRIVACY-POLICY.md'),
                )),
                PassyPadding(ThreeWidgetButton(
                  center: Text(localizations.about),
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.info_outline_rounded),
                  ),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => const PassyAboutDialog());
                  },
                )),
                const Spacer(),
                PassyPadding(Center(
                    child: Text(
                  '${localizations.extensionSettingsNote}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ))),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
