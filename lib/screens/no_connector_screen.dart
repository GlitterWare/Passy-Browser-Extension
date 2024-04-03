import 'package:flutter/material.dart';
import 'package:passy_browser_extension/common/common.dart';
import 'package:passy_browser_extension/common/raw_interop.dart';
import 'package:passy_browser_extension/passy_browser_extension_flutter/passy_browser_extensions_flutter.dart';
import 'package:passy_browser_extension/passy_flutter/passy_flutter.dart';

class NoConnectorScreen extends StatefulWidget {
  static const String routeName = '/noConnector';

  const NoConnectorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NoConnectorScreen();
}

class _NoConnectorScreen extends State<NoConnectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrowserExtensionAppbar(
        title: Text(localizations.noConnectorFound),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(),
                PassyPadding(Center(
                    child: Text(
                  '${localizations.noConnectorFound}!',
                  textAlign: TextAlign.center,
                ))),
                const SizedBox(height: 10),
                PassyPadding(ThreeWidgetButton(
                  center: Center(child: Text(localizations.download)),
                  left: const Icon(Icons.download_rounded),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => createTab(
                    'https://github.com/GlitterWare/Passy/blob/dev/DOWNLOADS.md',
                  ),
                )),
                const SizedBox(height: 10),
                PassyPadding(Center(
                    child: Text(
                  '${localizations.pleaseDownloadAndInstallTheMainPassyApplication}.',
                  textAlign: TextAlign.center,
                ))),
                const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
