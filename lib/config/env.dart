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

  /// ImageKit file names that differ from the backend slug. Apostrophes and
  /// accented letters (ImageKit drops them, e.g. `Jiří` -> `ji`) are handled
  /// inconsistently on ImageKit, so these are mapped by hand. Keep the
  /// apostrophe raw: ImageKit returns 404 for `%27`.
  static const _fighterImageOverrides = {
    'adrian-luna-martinetti': 'adri-n-luna-martinetti',
    'aleksandar-rakic': 'aleksandar-raki',
    'benoit-saint-denis': 'beno-t-saint-denis',
    'brando-pericic': 'brando-peri-i',
    'brendan-o-reilly': 'brendan-oreilly',
    'casey-o-neill': 'casey-oneill',
    'chuck-o-neil': 'chuck-oneil',
    'cristian-quinonez': 'cristian-qui-onez',
    'da-mon-blackshear': 'damon-blackshear',
    'don-tale-mayes': 'dontale-mayes',
    'dusko-todorovic': 'du-ko-todorovi',
    'ernesta-kareckaite': 'ernesta-kareckait',
    'fares-ziam': 'far-s-ziam',
    'jan-blachowicz': 'jan-b-achowicz',
    'jessica-andrade': 'j-ssica-andrade',
    'jiri-prochazka': 'ji-proch-zka',
    'joel-alvarez': 'joel-lvarez',
    'julianna-pena': 'julianna-pe-a',
    'kaue-fernandes': 'kau-fernandes',
    'mantas-kondratavicius': 'mantas-kondratavi-ius',
    'mateusz-rebecki': 'mateusz-r-becki',
    'sean-o-connell': 'sean-oconnell',
    'sean-o-malley': "sean-o'malley",
    'thiago-moises': 'thiago-mois-s',
    'tj-o-brien': 'tj-obrien',
    'uros-medic': 'uro-medi',
  };

  static String fighterImageUrl(String slug) =>
      '$fighterImageBaseUrl/${_fighterImageOverrides[slug] ?? slug}.png';
}
