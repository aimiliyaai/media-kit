/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
import 'package:meta/meta.dart';

import 'package:media_kit/src/player/platform_player.dart';

void nativeEnsureInitialized({String? libmpv}) {}

class NativePlayer extends PlatformPlayer {
  NativePlayer({required super.configuration});

  /// Whether the [NativePlayer] is initialized for unit-testing.
  @visibleForTesting
  static bool test = false;

  /// Web / wasm-js 条件导出会选用本 [stub]；[Player.setProperty] 等仍按 [NativePlayer] 解析，
  /// 此处提供空实现以通过编译。浏览器实际播放由 [WebPlayer] 完成。
  Future<void> setProperty(
    String property,
    String value, {
    bool waitForInitialization = true,
  }) async {}

  Future<String> getProperty(
    String property, {
    bool waitForInitialization = true,
  }) async =>
      '';

  void setMediaHeader({
    String? userAgent,
    String? referer,
    Map<String, String>? headers,
  }) {}
}
