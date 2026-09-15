import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class GeneralControl extends StatelessWidget {
  const GeneralControl({super.key});

  @override
  Widget build(BuildContext context) {
    return FButton.icon(onPress: () {}, child: Icon(FLucideIcons.settings2));
  }
}
