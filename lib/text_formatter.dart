import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// ---------- DECORATION MERGE ----------
TextDecoration? _mergeDecoration(TextDecoration? base, TextDecoration? added) {
  if (base == null) return added;
  if (added == null) return base;
  return TextDecoration.combine([base, added]);
}

/// ---------- NORMALIZATION ----------
/// Normalizes mixed formatting symbols into canonical order
String _normalizeFormatting(String input) {
  bool bold = false;
  bool underline = false;
  bool strike = false;
  bool italic = false;
  bool superScript = false;
  bool subScript = false;

  String text = input;

  void strip(String sym, void Function() flag) {
    if (text.contains(sym)) {
      flag();
      text = text.replaceAll(sym, '');
    }
  }

  strip('**', () => bold = true);
  strip('__', () => underline = true);
  strip('~~', () => strike = true);
  strip('^', () => superScript = true);
  strip('~', () => subScript = true);
  strip('_', () => italic = true);

  // rebuild in canonical order (inner → outer)
  if (italic) text = '_${text}_';
  if (subScript) text = '~${text}~';
  if (superScript) text = '^${text}^';
  if (strike) text = '~~${text}~~';
  if (underline) text = '__${text}__';
  if (bold) text = '**${text}**';

  return text;
}

/// ---------- STYLED SPAN ----------
InlineSpan _styledSpan(
  String inner,
  TextStyle style,
  TextStyle baseStyle,
  Function(String)? onOpenLink,
) {
  final mergedStyle = baseStyle.copyWith(
    fontWeight: style.fontWeight ?? baseStyle.fontWeight,
    fontStyle: style.fontStyle ?? baseStyle.fontStyle,
    fontSize: style.fontSize ?? baseStyle.fontSize,
    fontFeatures: style.fontFeatures ?? baseStyle.fontFeatures,
    decoration: _mergeDecoration(baseStyle.decoration, style.decoration),
  );

  return TextSpan(
    style: mergedStyle,
    children: buildFormattedSpan(
      inner,
      baseStyle: mergedStyle,
      onOpenLink: onOpenLink,
    ).children,
  );
}

/// ---------- MAIN FORMATTER ----------
TextSpan buildFormattedSpan(
  String line, {
  required TextStyle baseStyle,
  Function(String)? onOpenLink,
}) {
  final spans = <InlineSpan>[];

  // normalize the line FIRST
  line = _normalizeFormatting(line);

  final regex = RegExp(
    r'(\[\[.*?\]\]'
    r'|\*\*.*?\*\*'
    r'|__.*?__'
    r'|~~.*?~~'
    r'|\^.*?\^'
    r'|~.*?~'
    r'|_.*?_)',
  );

  int lastIndex = 0;

  for (final m in regex.allMatches(line)) {
    if (m.start > lastIndex) {
      spans.add(TextSpan(text: line.substring(lastIndex, m.start)));
    }

    final token = m.group(0)!;

    if (token.startsWith("**")) {
      spans.add(
        _styledSpan(
          token.substring(2, token.length - 2),
          const TextStyle(fontWeight: FontWeight.bold),
          baseStyle,
          onOpenLink,
        ),
      );
    } else if (token.startsWith("__")) {
      spans.add(
        _styledSpan(
          token.substring(2, token.length - 2),
          const TextStyle(decoration: TextDecoration.underline),
          baseStyle,
          onOpenLink,
        ),
      );
    } else if (token.startsWith("~~")) {
      spans.add(
        _styledSpan(
          token.substring(2, token.length - 2),
          const TextStyle(decoration: TextDecoration.lineThrough),
          baseStyle,
          onOpenLink,
        ),
      );
    } else if (token.startsWith("^")) {
      spans.add(
        _styledSpan(
          token.substring(1, token.length - 1),
          const TextStyle(
            fontFeatures: [FontFeature.superscripts()],
            fontSize: 20,
          ),
          baseStyle,
          onOpenLink,
        ),
      );
    } else if (token.startsWith("~")) {
      spans.add(
        _styledSpan(
          token.substring(1, token.length - 1),
          const TextStyle(
            fontFeatures: [FontFeature.subscripts()],
            fontSize: 20,
          ),
          baseStyle,
          onOpenLink,
        ),
      );
    } else if (token.startsWith("_")) {
      spans.add(
        _styledSpan(
          token.substring(1, token.length - 1),
          const TextStyle(fontStyle: FontStyle.italic),
          baseStyle,
          onOpenLink,
        ),
      );
    } else if (token.startsWith("[[")) {
      final content = token.substring(2, token.length - 2);
      final parts = content.split('|');

      spans.add(
        TextSpan(
          text: parts.first,
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            decoration: TextDecoration.underline,
          ),
          recognizer: onOpenLink == null
              ? null
              : (TapGestureRecognizer()..onTap = () => onOpenLink(parts.last)),
        ),
      );
    }

    lastIndex = m.end;
  }

  if (lastIndex < line.length) {
    spans.add(TextSpan(text: line.substring(lastIndex)));
  }

  return TextSpan(style: baseStyle, children: spans);
}
