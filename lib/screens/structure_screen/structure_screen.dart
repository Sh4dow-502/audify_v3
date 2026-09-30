import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: Text("Estructura de la canción"),
        titleAlignment: .centerLeft,
        prefixes: [
          FHeaderAction.back(
            onPress: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      child: Center(
        child: Text("Aquí se mostrará la estructura de la canción."),
      ),
    );
  }
}
