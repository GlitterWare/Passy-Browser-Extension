import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../passy_flutter/passy_theme.dart';

const String logoSvg = 'assets/images/logo.svg.vec';
const String logoCircleSvg = 'assets/images/logo_circle.svg.vec';

Widget logoCircle50White = const SvgPicture(
  AssetBytesLoader(logoCircleSvg),
  colorFilter:
      ColorFilter.mode(PassyTheme.lightContentColor, BlendMode.srcIn),
  width: 50,
  height: 50,
);

Widget logo60Purple = const SvgPicture(
  AssetBytesLoader(logoSvg),
  colorFilter: ColorFilter.mode(Colors.purple, BlendMode.srcIn),
  width: 60,
);

Widget logo15Purple = const SvgPicture(
  AssetBytesLoader(logoSvg),
  colorFilter: ColorFilter.mode(Colors.purple, BlendMode.srcIn),
  width: 10,
);
