abstract class Env {
  /// Backend base URL. Defaults to the Render deployment.
  /// For a local backend, run with
  /// `--dart-define=API_BASE_URL=http://localhost:8080` and
  /// `adb reverse tcp:8080 tcp:8080` on a physical device.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://octapulse-backend.onrender.com',
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
