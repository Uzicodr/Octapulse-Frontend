import 'package:flutter/material.dart';

/// Emoji flag for a country name as the backend spells it.
class CountryFlag extends StatelessWidget {
  const CountryFlag(this.country, {super.key, this.size = 16});

  final String? country;
  final double size;

  @override
  Widget build(BuildContext context) {
    final emoji = flagEmoji(country);
    if (emoji == null) return const SizedBox.shrink();
    return Text(emoji, style: TextStyle(fontSize: size, height: 1));
  }
}

String? flagEmoji(String? country) {
  if (country == null) return null;
  final key = country.trim().toLowerCase();
  final special = _subdivisions[key];
  if (special != null) return special;
  final code = _isoCodes[key];
  if (code == null) return null;
  return String.fromCharCodes(code.codeUnits.map((c) => 0x1F1E6 + c - 0x41));
}

const _subdivisions = {
  'england': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}',
  'scotland': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}',
  'wales': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0077}\u{E006C}\u{E0073}\u{E007F}',
};

const _isoCodes = {
  'afghanistan': 'AF', 'albania': 'AL', 'algeria': 'DZ', 'angola': 'AO',
  'argentina': 'AR', 'armenia': 'AM', 'aruba': 'AW', 'australia': 'AU',
  'austria': 'AT', 'azerbaijan': 'AZ', 'bahrain': 'BH', 'belarus': 'BY',
  'belgium': 'BE', 'bolivia': 'BO', 'bosnia and herzegovina': 'BA',
  'brazil': 'BR', 'bulgaria': 'BG', 'cameroon': 'CM', 'canada': 'CA',
  'chile': 'CL', 'china': 'CN', 'colombia': 'CO', 'congo': 'CG',
  'costa rica': 'CR', 'croatia': 'HR', 'cuba': 'CU', 'cyprus': 'CY',
  'czechia': 'CZ', 'czech republic': 'CZ', 'denmark': 'DK',
  'dominican republic': 'DO', 'ecuador': 'EC', 'egypt': 'EG', 'estonia': 'EE',
  'finland': 'FI', 'france': 'FR', 'georgia': 'GE', 'germany': 'DE',
  'ghana': 'GH', 'greece': 'GR', 'guam': 'GU', 'hungary': 'HU', 'iceland': 'IS',
  'india': 'IN', 'indonesia': 'ID', 'iran': 'IR', 'iraq': 'IQ', 'ireland': 'IE',
  'israel': 'IL', 'italy': 'IT', 'jamaica': 'JM', 'japan': 'JP', 'jordan': 'JO',
  'kazakhstan': 'KZ', 'kyrgyzstan': 'KG', 'latvia': 'LV', 'lebanon': 'LB',
  'lithuania': 'LT', 'mexico': 'MX', 'moldova': 'MD', 'mongolia': 'MN',
  'montenegro': 'ME', 'morocco': 'MA', 'myanmar': 'MM', 'netherlands': 'NL',
  'new zealand': 'NZ', 'nigeria': 'NG', 'northern ireland': 'GB', 'norway': 'NO',
  'panama': 'PA', 'paraguay': 'PY', 'peru': 'PE', 'philippines': 'PH',
  'poland': 'PL', 'portugal': 'PT', 'puerto rico': 'PR', 'romania': 'RO',
  'russia': 'RU', 'saudi arabia': 'SA', 'serbia': 'RS', 'singapore': 'SG',
  'slovakia': 'SK', 'slovenia': 'SI', 'south africa': 'ZA', 'south korea': 'KR',
  'korea': 'KR', 'spain': 'ES', 'suriname': 'SR', 'sweden': 'SE',
  'switzerland': 'CH', 'taiwan': 'TW', 'tajikistan': 'TJ', 'thailand': 'TH',
  'tunisia': 'TN', 'turkey': 'TR', 'turkmenistan': 'TM', 'uganda': 'UG',
  'ukraine': 'UA', 'united arab emirates': 'AE', 'uae': 'AE',
  'united kingdom': 'GB', 'uk': 'GB', 'united states': 'US', 'usa': 'US',
  'uruguay': 'UY', 'uzbekistan': 'UZ', 'venezuela': 'VE', 'vietnam': 'VN',
};
