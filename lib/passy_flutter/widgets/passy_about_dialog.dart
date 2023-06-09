import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../common/assets.dart';
import '../../common/common.dart';
import '../passy_theme.dart';
import 'passy_padding.dart';
import 'three_widget_button.dart';

class PassyAboutDialog extends StatelessWidget {
  const PassyAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: PassyTheme.dialogShape,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Center(
              child: WebsafeSvg.asset(
            logoSvg,
            colorFilter: const ColorFilter.mode(Colors.purple, BlendMode.srcIn),
            width: 128,
          )),
          const SizedBox(height: 32),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: localizations.passyBrowserExtension,
              style: GoogleFonts.firaCode(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                fontSize: 24,
              ),
              children: [
                TextSpan(
                  text: ' v$extensionVersion',
                  style: GoogleFonts.firaCode(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    color: PassyTheme.lightContentSecondaryColor,
                    fontSize: 24,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Made with 💜 by Gleammer',
            textAlign: TextAlign.center,
            style: GoogleFonts.firaCode(
              textStyle: Theme.of(context).textTheme.bodyMedium,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
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
            center: const Text('GitHub'),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => launchUrlString(
              'https://github.com/GlitterWare/Passy-Browser-Extension',
            ),
          )),
        ],
      ),
    );
  }
}
