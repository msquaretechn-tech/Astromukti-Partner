class KundliData {
  final dynamic lagna;
  final dynamic moon;
  final dynamic sun;
  final dynamic navamansha;
  final dynamic astro;
  final List planets;
  final List ayanamsha;
  final dynamic ghat;
  final List majorDasha;
  final List currentDasha;

  KundliData({
    this.lagna,
    this.moon,
    this.sun,
    this.navamansha,
    this.astro,
    required this.planets,
    required this.ayanamsha,
    this.ghat,
    required this.majorDasha,
    required this.currentDasha,
  });
}
