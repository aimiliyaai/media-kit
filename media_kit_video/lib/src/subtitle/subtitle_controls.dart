import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/widgets/video_state_inherited_widget.dart';

Widget _buildIcon({
  required double? iconSize,
  required Color? iconColor,
  required BuildContext context,
  required Widget icon,
}) {
  return SizedBox(
    width: iconSize ?? _theme(context).buttonBarButtonSize,
    height: iconSize ?? _theme(context).buttonBarButtonSize,
    child: icon,
  );
}

MaterialVideoControlsThemeData _theme(BuildContext context) {
  try {
    return MaterialVideoControlsTheme.of(context).normal;
  } catch (_) {
    return kDefaultMaterialVideoControlsThemeData;
  }
}

class SubtitleTrackButton extends StatefulWidget {
  final double? iconSize;
  final Color? iconColor;
  final Widget? offIcon;
  final Widget? onIcon;

  const SubtitleTrackButton({
    super.key,
    this.iconSize,
    this.iconColor,
    this.offIcon,
    this.onIcon,
  });

  @override
  SubtitleTrackButtonState createState() => SubtitleTrackButtonState();
}

class SubtitleTrackButtonState extends State<SubtitleTrackButton> {
  List<SubtitleTrack> tracks = [];
  SubtitleTrack current = const SubtitleTrack('no', null, null);
  StreamSubscription<Track>? trackSub;
  StreamSubscription<Tracks>? tracksSub;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    trackSub ??= controller(context).player.stream.track.listen((event) {
      setState(() {
        current = event.subtitle;
      });
    });
    tracksSub ??= controller(context).player.stream.tracks.listen((event) {
      setState(() {
        tracks = event.subtitle;
      });
    });
  }

  @override
  void dispose() {
    trackSub?.cancel();
    tracksSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme(context);
    final iconSize = widget.iconSize ?? theme.buttonBarButtonSize;
    final iconColor = widget.iconColor ?? theme.buttonBarButtonColor;

    final isOn = current.id != 'no';

    return PopupMenuButton<String>(
      tooltip: 'Subtitles',
      requestFocus: false,
      initialValue: current.id,
      color: Colors.black.withValues(alpha: 0.8),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            height: 35,
            value: 'no',
            onTap: () {
              controller(context).player.setSubtitleTrack(
                SubtitleTrack.no(),
              );
            },
            child: Text(
              'Off',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          if (tracks.isNotEmpty) const PopupMenuDivider(),
          for (final track in tracks)
            PopupMenuItem<String>(
              height: 35,
              value: track.id,
              onTap: () {
                controller(context).player.setSubtitleTrack(track);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      track.title ?? track.language ?? track.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (current.id == track.id)
                    Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
        ];
      },
      child: _buildIcon(
        iconSize: iconSize,
        iconColor: iconColor,
        context: context,
        icon: isOn
            ? (widget.onIcon ??
                const Icon(Icons.closed_caption_off_rounded, size: 22))
            : (widget.offIcon ??
                const Icon(Icons.closed_caption_off_outlined, size: 22)),
      ),
    );
  }
}

Future<void> showSubtitleSettingsPanel(BuildContext context) {
  final notifier = VideoStateInheritedWidget.of(context).videoViewParametersNotifier;
  final currentConfig = notifier.value.subtitleViewConfiguration;

  final initialFontSize = currentConfig.fontSize;
  final initialFontColor = currentConfig.fontColor;
  final initialBgColor = currentConfig.backgroundColor;
  final initialStrokeColor = currentConfig.strokeColor;
  final initialStrokeWidth = currentConfig.strokeWidth;
  final initialFontWeight = _extractFontWeightIndex(currentConfig);
  final initialShadow = currentConfig.shadow;

  void apply({
    required double fontSize,
    required Color fontColor,
    required Color? backgroundColor,
    required Color? strokeColor,
    required double strokeWidth,
    required bool shadow,
    required FontWeight fontWeight,
  }) {
    final config = SubtitleViewConfiguration(
      fontSize: fontSize,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      shadow: shadow,
      fontWeight: fontWeight,
      textScaleFactor: currentConfig.textScaleFactor,
      padding: currentConfig.padding,
    );
    notifier.value = notifier.value.copyWith(
      subtitleViewConfiguration: config,
    );
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SubtitleSettingsPanel(
      initialFontSize: initialFontSize,
      initialFontColor: initialFontColor,
      initialBgColor: initialBgColor,
      initialStrokeColor: initialStrokeColor,
      initialStrokeWidth: initialStrokeWidth,
      initialFontWeight: initialFontWeight,
      initialShadow: initialShadow,
      onApply: apply,
    ),
  );
}

int _extractFontWeightIndex(SubtitleViewConfiguration config) {
  final weights = FontWeight.values;
  for (int i = 0; i < weights.length; i++) {
    if (weights[i] == config.fontWeight) return i;
  }
  return 5;
}

class _SubtitleSettingsPanel extends StatefulWidget {
  final double initialFontSize;
  final Color initialFontColor;
  final Color? initialBgColor;
  final Color? initialStrokeColor;
  final double initialStrokeWidth;
  final int initialFontWeight;
  final bool initialShadow;
  final void Function({
    required double fontSize,
    required Color fontColor,
    required Color? backgroundColor,
    required Color? strokeColor,
    required double strokeWidth,
    required bool shadow,
    required FontWeight fontWeight,
  }) onApply;

  const _SubtitleSettingsPanel({
    required this.initialFontSize,
    required this.initialFontColor,
    required this.initialBgColor,
    required this.initialStrokeColor,
    required this.initialStrokeWidth,
    required this.initialFontWeight,
    required this.initialShadow,
    required this.onApply,
  });

  @override
  _SubtitleSettingsPanelState createState() => _SubtitleSettingsPanelState();
}

class _SubtitleSettingsPanelState extends State<_SubtitleSettingsPanel> {
  late double fontSize;
  late Color fontColor;
  late Color? bgColor;
  late Color? strokeColor;
  late double strokeWidth;
  late bool shadow;
  late int fontWeight;

  @override
  void initState() {
    super.initState();
    fontSize = widget.initialFontSize;
    fontColor = widget.initialFontColor;
    bgColor = widget.initialBgColor;
    strokeColor = widget.initialStrokeColor;
    strokeWidth = widget.initialStrokeWidth;
    shadow = widget.initialShadow;
    fontWeight = widget.initialFontWeight;
  }

  void _apply() {
    widget.onApply(
      fontSize: fontSize,
      fontColor: fontColor,
      backgroundColor: bgColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      shadow: shadow,
      fontWeight: FontWeight.values[fontWeight],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _SubtitleSettingsBody(
            fontSize: fontSize,
            fontColor: fontColor,
            bgColor: bgColor,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            shadow: shadow,
            fontWeight: fontWeight,
            onFontSizeChanged: (v) { setState(() => fontSize = v); _apply(); },
            onFontColorChanged: (v) { setState(() => fontColor = v); _apply(); },
            onBgColorChanged: (v) { setState(() => bgColor = v); _apply(); },
            onStrokeColorChanged: (v) { setState(() => strokeColor = v); _apply(); },
            onStrokeWidthChanged: (v) { setState(() => strokeWidth = v); _apply(); },
            onShadowChanged: (v) { setState(() => shadow = v); _apply(); },
            onFontWeightChanged: (v) { setState(() => fontWeight = v); _apply(); },
          ),
        ),
      ),
    );
  }
}

class _SubtitleSettingsBody extends StatelessWidget {
  final double fontSize;
  final Color fontColor;
  final Color? bgColor;
  final Color? strokeColor;
  final double strokeWidth;
  final bool shadow;
  final int fontWeight;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<Color> onFontColorChanged;
  final ValueChanged<Color?> onBgColorChanged;
  final ValueChanged<Color?> onStrokeColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final ValueChanged<bool> onShadowChanged;
  final ValueChanged<int> onFontWeightChanged;

  const _SubtitleSettingsBody({
    required this.fontSize,
    required this.fontColor,
    required this.bgColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.shadow,
    required this.onFontSizeChanged,
    required this.onFontColorChanged,
    required this.onBgColorChanged,
    required this.onStrokeColorChanged,
    required this.onStrokeWidthChanged,
    required this.onShadowChanged,
    required this.onFontWeightChanged,
  });

  static const _colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.cyan,
    Colors.purple,
    Colors.orange,
    Colors.grey,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        _buildSlider(
          theme: theme,
          label: '字体大小 ${fontSize.round()}px',
          resetLabel: '32',
          value: fontSize,
          min: 12,
          max: 96,
          divisions: 84,
          onChanged: onFontSizeChanged,
        ),
        _buildSlider(
          theme: theme,
          label: '描边宽度 ${strokeWidth.toStringAsFixed(1)}',
          resetLabel: '0',
          value: strokeWidth,
          min: 0,
          max: 8,
          divisions: 16,
          onChanged: onStrokeWidthChanged,
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('文字阴影', style: TextStyle(fontSize: 14)),
          value: shadow,
          onChanged: onShadowChanged,
        ),
        _buildSlider(
          theme: theme,
          label: '字重 ${fontWeight + 1}',
          resetLabel: '4',
          value: fontWeight.toDouble(),
          min: 0,
          max: 8,
          divisions: 8,
          onChanged: (v) => onFontWeightChanged(v.toInt()),
        ),
        const Divider(height: 8),
        _buildColorRow(
          label: '字体颜色',
          currentColor: fontColor,
          allowTransparent: false,
          onChanged: (c) {
            if (c != null) onFontColorChanged(c);
          },
        ),
        const Divider(height: 4),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('字幕背景', style: TextStyle(fontSize: 14)),
          value: bgColor != null,
          onChanged: (v) => onBgColorChanged(
            v ? const Color(0xaa000000) : null,
          ),
        ),
        if (bgColor != null)
          _buildColorRow(
            label: '背景色',
            currentColor: bgColor,
            allowTransparent: true,
            onChanged: onBgColorChanged,
          ),
        _buildColorRow(
          label: '描边颜色',
          currentColor: strokeColor,
          allowTransparent: true,
          onChanged: onStrokeColorChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSlider({
    required ThemeData theme,
    required String label,
    required String resetLabel,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.onInverseSurface,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              min: min,
              max: max,
              value: value,
              divisions: divisions,
              label: value.toStringAsFixed(1),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow({
    required String label,
    required Color? currentColor,
    required bool allowTransparent,
    required ValueChanged<Color?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ..._colors.map(
                (c) => GestureDetector(
                  onTap: () => onChanged(c),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentColor == c
                            ? Colors.grey[700]!
                            : Colors.grey[400]!,
                        width: currentColor == c ? 3 : 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (allowTransparent)
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentColor == null
                            ? Colors.grey[700]!
                            : Colors.grey[400]!,
                        width: currentColor == null ? 3 : 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A full-page subtitle settings screen that can be pushed via [Navigator.push]
/// or embedded in your app's settings section.
///
/// Returns the modified [SubtitleViewConfiguration] via [Navigator.pop] when back is pressed.
class SubtitleSettingsPage extends StatefulWidget {
  final SubtitleViewConfiguration initial;

  const SubtitleSettingsPage({super.key, required this.initial});

  @override
  State<SubtitleSettingsPage> createState() => _SubtitleSettingsPageState();
}

class _SubtitleSettingsPageState extends State<SubtitleSettingsPage> {
  late double fontSize;
  late Color fontColor;
  late Color? bgColor;
  late Color? strokeColor;
  late double strokeWidth;
  late bool shadow;
  late int fontWeight;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    fontSize = c.fontSize;
    fontColor = c.fontColor;
    bgColor = c.backgroundColor;
    strokeColor = c.strokeColor;
    strokeWidth = c.strokeWidth;
    shadow = c.shadow;
    fontWeight = _extractFontWeightIndex(c);
  }

  SubtitleViewConfiguration get current => SubtitleViewConfiguration(
    fontSize: fontSize,
    fontColor: fontColor,
    backgroundColor: bgColor,
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
    shadow: shadow,
    fontWeight: FontWeight.values[fontWeight],
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // 返回键 → 取消，不保存
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('字幕设置'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(current),
              child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: _settingsBody(),
      ),
    );
  }

  Widget _settingsBody() {
    return _SubtitleSettingsBody(
      fontSize: fontSize,
      fontColor: fontColor,
      bgColor: bgColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      shadow: shadow,
      fontWeight: fontWeight,
      onFontSizeChanged: (v) => setState(() => fontSize = v),
      onFontColorChanged: (v) => setState(() => fontColor = v),
      onBgColorChanged: (v) => setState(() => bgColor = v),
      onStrokeColorChanged: (v) => setState(() => strokeColor = v),
      onStrokeWidthChanged: (v) => setState(() => strokeWidth = v),
      onShadowChanged: (v) => setState(() => shadow = v),
      onFontWeightChanged: (v) => setState(() => fontWeight = v),
    );
  }
}

/// A [ListTile] that navigates to [SubtitleSettingsPage].
///
/// Place this in your app's settings page. It shows the current subtitle font size
/// as the subtitle and returns the user's configuration via [onChanged].
class SubtitleSettingsListTile extends StatelessWidget {
  final SubtitleViewConfiguration current;
  final ValueChanged<SubtitleViewConfiguration>? onChanged;

  const SubtitleSettingsListTile({
    super.key,
    required this.current,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.closed_caption),
      title: const Text('字幕样式'),
      subtitle: Text('字体大小 ${current.fontSize.round()}px'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await Navigator.push<SubtitleViewConfiguration>(
          context,
          MaterialPageRoute(
            builder: (_) => SubtitleSettingsPage(initial: current),
          ),
        );
        if (result != null && onChanged != null) {
          onChanged!(result);
        }
      },
    );
  }
}

class SubtitleUtils {
  static String _timecode(num seconds) {
    int h = seconds ~/ 3600;
    seconds %= 3600;
    int m = seconds ~/ 60;
    seconds %= 60;
    String sms = seconds.toStringAsFixed(3).padLeft(6, '0');
    return h == 0
        ? "${m.toString().padLeft(2, '0')}:$sms"
        : "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:$sms";
  }

  static String jsonToWebVTT(List<Map<String, dynamic>> list) {
    final sb = StringBuffer('WEBVTT\n\n');
    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (i > 0) sb.writeln();
      sb.writeln('${item['sid'] ?? i}');
      sb.writeln(
        '${_timecode((item['from'] as num))} --> ${_timecode((item['to'] as num))}',
      );
      sb.write((item['content'] as String).trim());
    }
    return sb.toString();
  }
}
