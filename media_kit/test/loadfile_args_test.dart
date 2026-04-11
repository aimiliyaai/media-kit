import 'package:test/test.dart';
import 'package:media_kit/src/player/native/utils/loadfile_utils.dart';

void main() {
  group('buildLoadfileArgs', () {
    test('extras 为 null 时只有 3 个参数', () {
      final args = buildLoadfileArgs('http://example.com/video.m4s', null);
      expect(args, ['loadfile', 'http://example.com/video.m4s', 'append']);
    });

    test('extras 为空 map 时只有 3 个参数', () {
      final args = buildLoadfileArgs('http://example.com/video.m4s', {});
      expect(args, ['loadfile', 'http://example.com/video.m4s', 'append']);
    });

    test('extras 包含 audio-files 时作为第 4 个参数传入 (旧 API)', () {
      final args = buildLoadfileArgs(
        'http://example.com/video.m4s',
        {'audio-files': '"http://example.com/audio.m4s"'},
        apiVersion: 0x10000,
      );
      expect(args, [
        'loadfile',
        'http://example.com/video.m4s',
        'append',
        'audio-files="http://example.com/audio.m4s"',
      ]);
    });

    test('API >= 0x20003 时 extras 前插入 index=-1', () {
      final args = buildLoadfileArgs(
        'http://example.com/video.m4s',
        {'audio-files': '"http://example.com/audio.m4s"'},
        apiVersion: 0x20003,
      );
      expect(args, [
        'loadfile',
        'http://example.com/video.m4s',
        'append',
        '-1',
        'audio-files="http://example.com/audio.m4s"',
      ]);
    });

    test('API > 0x20003 也插入 index=-1', () {
      final args = buildLoadfileArgs(
        'http://example.com/video.m4s',
        {'audio-files': '"http://example.com/audio.m4s"'},
        apiVersion: 0x20100,
      );
      expect(args.length, 5);
      expect(args[3], '-1');
      expect(args[4], 'audio-files="http://example.com/audio.m4s"');
    });

    test('多个 extras 用逗号连接', () {
      final args = buildLoadfileArgs(
        'http://example.com/video.m4s',
        {
          'audio-files': '"http://example.com/audio.m4s"',
          'start': '10',
        },
        apiVersion: 0x20003,
      );
      expect(args.length, 5);
      expect(args[0], 'loadfile');
      expect(args[1], 'http://example.com/video.m4s');
      expect(args[2], 'append');
      expect(args[3], '-1');
      expect(args[4], contains('audio-files="http://example.com/audio.m4s"'));
      expect(args[4], contains('start=10'));
      expect(args[4].split(',').length, 2);
    });

    test('apiVersion 默认为 0（不插入 index）', () {
      final args = buildLoadfileArgs(
        'http://example.com/video.m4s',
        {'audio-files': '"http://example.com/audio.m4s"'},
      );
      expect(args.length, 4);
      expect(args[3], 'audio-files="http://example.com/audio.m4s"');
    });

    test('无 extras 时 apiVersion 不影响结果', () {
      final argsOld = buildLoadfileArgs('http://example.com/video.m4s', null, apiVersion: 0x10000);
      final argsNew = buildLoadfileArgs('http://example.com/video.m4s', null, apiVersion: 0x20003);
      expect(argsOld, argsNew);
      expect(argsOld.length, 3);
    });

    test('dynamic 类型值正确转为字符串', () {
      final args = buildLoadfileArgs(
        'http://example.com/video.m4s',
        <String, dynamic>{'audio-files': 42, 'flag': true},
        apiVersion: 0x20003,
      );
      expect(args[4], contains('audio-files=42'));
      expect(args[4], contains('flag=true'));
    });
  });
}
