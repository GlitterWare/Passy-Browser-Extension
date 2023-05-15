import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../passy_flutter/passy_flutter.dart';

const String logoSvg = 'assets/images/logo.svg';
const String logoCircleSvg = 'assets/images/logo_circle.svg';

Widget logoCircle50White = WebsafeSvg.asset(
  logoCircleSvg,
  colorFilter:
      const ColorFilter.mode(PassyTheme.lightContentColor, BlendMode.srcIn),
  width: 50,
  height: 50,
);

Widget logo60Purple = WebsafeSvg.asset(
  logoSvg,
  colorFilter: const ColorFilter.mode(Colors.purple, BlendMode.srcIn),
  width: 60,
);

Widget logo15Purple = WebsafeSvg.asset(
  logoSvg,
  colorFilter: const ColorFilter.mode(Colors.purple, BlendMode.srcIn),
  width: 10,
);
