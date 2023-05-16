import 'package:flutter/material.dart';
import 'package:passy_browser_extension/passy_flutter/passy_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:websafe_svg/websafe_svg.dart';
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
                  onPressed: () => launchUrlString(
                      'https://github.com/sponsors/GlitterWare'),
                )),
                PassyPadding(ThreeWidgetButton(
                  left: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: WebsafeSvg.asset(
                      'assets/images/github_icon.svg',
                      width: 26,
                      colorFilter: const ColorFilter.mode(
                          PassyTheme.lightContentColor, BlendMode.srcIn),
                    ),
                  ),
                  center: Text(localizations.requestAFeature),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => launchUrlString(
                    'https://github.com/GlitterWare/Passy/issues',
                  ),
                )),
                PassyPadding(ThreeWidgetButton(
                  center: Text(localizations.privacyPolicy),
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.shield_moon_outlined),
                  ),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => launchUrlString(
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
