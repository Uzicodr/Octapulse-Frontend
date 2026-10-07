abstract class Env {
  /// Backend base URL. Defaults to localhost so a physical device can reach the
  /// local backend through `adb reverse tcp:8080 tcp:8080`.
  /// Override with `--dart-define=API_BASE_URL=https://...`.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const fighterImageBaseUrl =
      'https://ik.imagekit.io/ohgsl5bks/fighterimages';

  /// ImageKit file names that differ from the backend slug. Apostrophes in
  /// names are handled inconsistently on ImageKit, so these are mapped by
  /// hand. Keep the apostrophe raw: ImageKit returns 404 for `%27`.
  static const _fighterImageOverrides = {
    'brendan-o-reilly': 'brendan-oreilly',
    'casey-o-neill': 'casey-oneill',
    'chuck-o-neil': 'chuck-oneil',
    'da-mon-blackshear': 'damon-blackshear',
    'don-tale-mayes': 'dontale-mayes',
    'sean-o-connell': 'sean-oconnell',
    'sean-o-malley': "sean-o'malley",
    'tj-o-brien': 'tj-obrien',
  };

  static String fighterImageUrl(String slug) =>
      '$fighterImageBaseUrl/${_fighterImageOverrides[slug] ?? slug}.png';
}
