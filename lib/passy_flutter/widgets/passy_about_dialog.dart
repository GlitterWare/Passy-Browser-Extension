import 'package:flutter/material.dart';
import 'package:passy_browser_extension/common/raw_interop.dart';
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontFamily: 'FiraCode', fontSize: 24),
              children: [
                TextSpan(
                  text: ' v$extensionVersion',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'FiraCode',
                        fontSize: 24,
                        color: PassyTheme.lightContentSecondaryColor,
                      ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Made with 💜 by Gleammer',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontFamily: 'FiraCode', fontSize: 12),
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
            onPressed: () => createTab(
              'https://github.com/GlitterWare/Passy-Browser-Extension',
            ),
          )),
        ],
      ),
    );
  }
}
