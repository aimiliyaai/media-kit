/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:media_kit_video/src/video_controller/video_controller.dart';

class SubtitleView extends StatefulWidget {
  final VideoController controller;
  final SubtitleViewConfiguration configuration;

  const SubtitleView({
    super.key,
    required this.controller,
    required this.configuration,
  });

  @override
  SubtitleViewState createState() => SubtitleViewState();
}

class SubtitleViewState extends State<SubtitleView> {
  late List<String> subtitle = widget.controller.player.state.subtitle;
  late EdgeInsets padding = widget.configuration.padding;
  late Duration duration = const Duration(milliseconds: 100);

  StreamSubscription<List<String>>? subscription;

  static const kTextScaleFactorReferenceWidth = 1920.0;
  static const kTextScaleFactorReferenceHeight = 1080.0;

  @override
  void initState() {
    subscription = widget.controller.player.stream.subtitle.listen((value) {
      setState(() {
        subtitle = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  void setPadding(
    EdgeInsets padding, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    if (this.duration != duration) {
      setState(() {
        this.duration = duration;
      });
    }
    setState(() {
      this.padding = padding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nr = (constraints.maxWidth * constraints.maxHeight);
        const dr =
            kTextScaleFactorReferenceWidth * kTextScaleFactorReferenceHeight;
        final computedScale = sqrt((nr / dr).clamp(0.0, 1.0));
        final scale =
            widget.configuration.textScaleFactor ?? computedScale;
        final textScaler = widget.configuration.textScaler ??
            TextScaler.linear(scale);

        final text = [
          for (final line in subtitle)
            if (line.trim().isNotEmpty) line.trim(),
        ].join('\n');

        Widget textWidget = Text(
          text,
          style: widget.configuration.resolveStyle,
          textAlign: widget.configuration.textAlign,
          textScaler: textScaler,
        );

        final bg = widget.configuration.backgroundColor;
        if (bg != null) {
          textWidget = Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: textWidget,
          );
        }

        return Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            padding: padding,
            duration: duration,
            alignment: Alignment.bottomCenter,
            child: textWidget,
          ),
        );
      },
    );
  }
}

class SubtitleViewConfiguration {
  final bool visible;
  final double fontSize;
  final Color fontColor;
  final Color? backgroundColor;
  final Color? strokeColor;
  final double strokeWidth;
  final bool shadow;
  final FontWeight fontWeight;
  final double height;
  final TextAlign textAlign;
  final TextScaler? textScaler;
  final double? textScaleFactor;
  final EdgeInsets padding;

  const SubtitleViewConfiguration({
    this.visible = true,
    this.fontSize = 32.0,
    this.fontColor = const Color(0xffffffff),
    this.backgroundColor = const Color(0xaa000000),
    this.strokeColor,
    this.strokeWidth = 0.0,
    this.shadow = false,
    this.fontWeight = FontWeight.normal,
    this.height = 1.4,
    this.textAlign = TextAlign.center,
    this.textScaler,
    this.textScaleFactor,
    this.padding = const EdgeInsets.fromLTRB(
      16.0,
      0.0,
      16.0,
      24.0,
    ),
  });

  TextStyle get resolveStyle {
    final list = <Shadow>[];
    if (strokeColor != null && strokeWidth > 0) {
      final sw = strokeWidth;
      list.addAll([
        Shadow(color: strokeColor!, offset: Offset(-sw, 0), blurRadius: 0.5),
        Shadow(color: strokeColor!, offset: Offset(sw, 0), blurRadius: 0.5),
        Shadow(color: strokeColor!, offset: Offset(0, -sw), blurRadius: 0.5),
        Shadow(color: strokeColor!, offset: Offset(0, sw), blurRadius: 0.5),
      ]);
    }
    if (shadow) {
      list.add(const Shadow(color: Colors.black, offset: Offset(2, 4), blurRadius: 3));
    }
    return TextStyle(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: 0.0,
      wordSpacing: 0.0,
      shadows: list.isNotEmpty ? list : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubtitleViewConfiguration &&
          other.visible == visible &&
          other.fontSize == fontSize &&
          other.fontColor == fontColor &&
          other.backgroundColor == backgroundColor &&
          other.strokeColor == strokeColor &&
          other.strokeWidth == strokeWidth &&
          other.shadow == shadow &&
          other.fontWeight == fontWeight &&
          other.height == height &&
          other.textAlign == textAlign &&
          other.textScaler == textScaler &&
          other.textScaleFactor == textScaleFactor &&
          other.padding == padding;

  @override
  int get hashCode =>
      visible.hashCode ^
      fontSize.hashCode ^
      fontColor.hashCode ^
      backgroundColor.hashCode ^
      strokeColor.hashCode ^
      strokeWidth.hashCode ^
      shadow.hashCode ^
      fontWeight.hashCode ^
      height.hashCode ^
      textAlign.hashCode ^
      textScaler.hashCode ^
      textScaleFactor.hashCode ^
      padding.hashCode;
}
