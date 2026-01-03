import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:arted/flags.dart';

class FlagEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'flag';

  @override
  Widget build(
    BuildContext context,
    quill.EmbedContext embedContext,
  ) {
    // Extract flag code from the embed node
    final flagCode = embedContext.node.value.data as String;
    final flagFile = FlagsFeature.getFlagFile(flagCode);

    if (flagFile != null && flagFile.existsSync()) {
      return SizedBox(
        height: FlagsFeature.flagHeight,
        child: Image.file(flagFile, fit: BoxFit.contain),
      );
    }

    // Fallback if flag not found
    return Text(
      '[flag:$flagCode]',
      style: const TextStyle(color: Colors.grey),
    );
  }
}