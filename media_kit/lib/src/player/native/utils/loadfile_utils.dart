/// Utility for building mpv loadfile command arguments.
///
/// Extracted to enable unit testing without FFI dependencies.

/// Builds the mpv `loadfile` command arguments for a media URI.
///
/// Format (API < 0x20003): `loadfile <url> <flags> [<options>]`
/// Format (API >= 0x20003): `loadfile <url> <flags> <index> [<options>]`
///
/// When [extras] is non-empty, options are formatted as `key=value,key=value`.
/// When [apiVersion] >= 0x20003 (mpv 0.38+), an index argument (`-1` = append)
/// is inserted before options — required by the new `loadfile` signature.
List<String> buildLoadfileArgs(
  String uri,
  Map<String, dynamic>? extras, {
  int apiVersion = 0,
}) {
  final args = <String>['loadfile', uri, 'append'];
  if (extras != null && extras.isNotEmpty) {
    if (apiVersion >= 0x20003) {
      args.add('-1');
    }
    args.add(extras.entries.map((e) => '${e.key}=${e.value}').join(','));
  }
  return args;
}
