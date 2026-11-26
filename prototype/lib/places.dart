import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'data.dart';

/// A small made-up map of Jakarta Barat for the DEMO address picker. Nothing
/// here calls a real map service. Positions are in km from the top-left
/// corner of an 8 x 8 km area. Street and kecamatan names are real public
/// names; house numbers, buildings and places are invented.

const double worldKm = 8;

class Region {
  final String name; // kecamatan
  final String city;
  final String postal;
  final Rect area;
  const Region(this.name, this.city, this.postal, this.area);
}

const regions = <Region>[
  Region('Kembangan', 'Jakarta Barat', '11610', Rect.fromLTRB(0, 0, 2.7, 4.6)),
  Region(
    'Kebon Jeruk',
    'Jakarta Barat',
    '11530',
    Rect.fromLTRB(2.7, 0, 5.4, 4.6),
  ),
  Region(
    'Grogol Petamburan',
    'Jakarta Barat',
    '11470',
    Rect.fromLTRB(5.4, 0, 8, 4.6),
  ),
  Region(
    'Kebayoran Lama',
    'Jakarta Selatan',
    '12240',
    Rect.fromLTRB(0, 4.6, 4.2, 8),
  ),
  Region('Palmerah', 'Jakarta Barat', '11480', Rect.fromLTRB(4.2, 4.6, 8, 8)),
];

Region regionAt(Offset p) => regions.firstWhere(
  (r) =>
      p.dx >= r.area.left &&
      p.dx < r.area.right &&
      p.dy >= r.area.top &&
      p.dy < r.area.bottom,
  orElse: () => regions.reduce(
    (a, b) =>
        (a.area.center - p).distance < (b.area.center - p).distance ? a : b,
  ),
);

class Road {
  final String name;
  final List<Offset> points;
  final bool major;
  const Road(this.name, this.points, {this.major = false});
}

const roads = <Road>[
  Road('Jl. Panjang', [
    Offset(2.7, 0),
    Offset(2.75, 4),
    Offset(2.6, 8),
  ], major: true),
  Road('Jl. Letjen S. Parman', [Offset(7.4, 0), Offset(7.3, 8)], major: true),
  Road('Jl. Meruya Ilir', [Offset(1.2, 0), Offset(1.3, 3.8), Offset(1.0, 6.6)]),
  Road('Jl. Kedoya Raya', [Offset(0, 1.2), Offset(2.7, 1.25)]),
  Road('Jl. Duri Kepa Raya', [Offset(2.7, 1.0), Offset(6.3, 0.9)]),
  Road('Jl. Arjuna Selatan', [Offset(2.75, 2.2), Offset(5.4, 2.3)]),
  Road('Jl. Kebon Jeruk Raya', [Offset(2.75, 3.4), Offset(6.3, 3.3)]),
  Road('Jl. Puri Kembangan', [Offset(0, 3.8), Offset(2.75, 3.9)]),
  Road('Jl. Tanjung Duren Raya', [Offset(6.3, 0), Offset(6.3, 4.6)]),
  Road('Jl. Kemanggisan Utama', [
    Offset(5.0, 4.6),
    Offset(5.9, 5.5),
    Offset(6.8, 6.9),
  ]),
  Road('Jl. Palmerah Barat', [Offset(4.2, 5.8), Offset(8, 5.7)], major: true),
  Road('Jl. Kebayoran Lama', [Offset(0.4, 7.2), Offset(4.2, 6.9)]),
];

/// Water and parks, drawn only.
const rivers = <List<Offset>>[
  [Offset(0.55, 0), Offset(0.7, 2.5), Offset(0.45, 5), Offset(0.7, 8)],
  [Offset(5.2, 0), Offset(5.05, 2.4), Offset(5.3, 4.6)],
];
const parks = <Rect>[
  Rect.fromLTWH(1.6, 1.6, 0.8, 0.6),
  Rect.fromLTWH(3.4, 4.9, 0.6, 0.5),
  Rect.fromLTWH(6.6, 2.4, 0.5, 0.6),
];

/// Store positions on the demo map, by store name.
const storePos = <String, Offset>{
  'Es Krim Sejahtera': Offset(3.9, 2.7),
  'Toko Beku Makmur': Offset(6.4, 6.2),
  'Dingin Berkah Frozen': Offset(6.7, 1.7),
};

/// The demo "my location": the first saved address.
const myLocation = Offset(5.9, 5.5);

class Place {
  final String name;
  final String sub;
  final Offset pos;
  final bool store;
  const Place(this.name, this.sub, this.pos, {this.store = false});
}

/// Places the search box can find. All buildings are made up.
final List<Place> places = [
  for (final s in stores)
    Place(s.name, '${s.area} · ${s.hours}', storePos[s.name]!, store: true),
  Place(
    'Jl. Kemanggisan Utama No. 27',
    'Palmerah, Jakarta Barat 11480',
    myLocation,
  ),
  const Place(
    'Apartemen Griya Kencana',
    'Kembangan, Jakarta Barat 11610',
    Offset(1.9, 3.1),
  ),
  const Place(
    'Kantor Arjuna Selatan No. 9',
    'Kebon Jeruk, Jakarta Barat 11530',
    Offset(3.3, 2.2),
  ),
  const Place(
    'Perumahan Puri Asri',
    'Kembangan, Jakarta Barat 11610',
    Offset(0.9, 3.0),
  ),
  const Place(
    'Taman Kota Kedoya',
    'Kembangan, Jakarta Barat 11610',
    Offset(2.0, 1.9),
  ),
  const Place(
    'Sekolah Bina Cendekia',
    'Kebon Jeruk, Jakarta Barat 11530',
    Offset(4.3, 1.4),
  ),
  const Place(
    'Klinik Sehat Sentosa',
    'Grogol Petamburan, Jakarta Barat 11470',
    Offset(6.0, 2.8),
  ),
  const Place(
    'Pasar Pagi Duri Kepa',
    'Kebon Jeruk, Jakarta Barat 11510',
    Offset(4.8, 0.8),
  ),
  const Place(
    'Stasiun Palmerah',
    'Palmerah, Jakarta Barat 11480',
    Offset(7.0, 5.9),
  ),
  const Place(
    'Rusun Kebayoran Asri',
    'Kebayoran Lama, Jakarta Selatan 12240',
    Offset(2.2, 6.6),
  ),
  for (final r in roads)
    Place(
      r.name,
      '${regionAt(_mid(r)).name}, ${regionAt(_mid(r)).city}',
      _mid(r),
    ),
];

/// A point in the middle of a road.
Offset _mid(Road r) => r.points.length.isOdd
    ? r.points[r.points.length ~/ 2]
    : (r.points[r.points.length ~/ 2 - 1] + r.points[r.points.length ~/ 2]) / 2;

/// Places whose name or area contains every typed word.
List<Place> searchPlaces(String q, {int limit = 6}) {
  final words = q.toLowerCase().split(' ').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return const [];
  return places
      .where((p) {
        final hay = '${p.name} ${p.sub}'.toLowerCase();
        return words.every(hay.contains);
      })
      .take(limit)
      .toList();
}

/// A made-up street address for a point on the map.
class PinAddress {
  final String street; // "Jl. Panjang No. 41" or "Dekat Jl. Panjang"
  final Region region;
  const PinAddress(this.street, this.region);
  String get area => '${region.name}, ${region.city} ${region.postal}';
  String get full => '$street, $area';
}

PinAddress reverseGeocode(Offset p) {
  Road? best;
  var bestD = double.infinity;
  var bestAlong = 0.0;
  for (final r in roads) {
    var along = 0.0;
    for (var i = 0; i + 1 < r.points.length; i++) {
      final a = r.points[i], b = r.points[i + 1];
      final ab = b - a;
      final len = ab.distance;
      final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / (len * len)).clamp(
        0.0,
        1.0,
      );
      final d = (a + ab * t - p).distance;
      if (d < bestD) {
        bestD = d;
        best = r;
        bestAlong = along + len * t;
      }
      along += len;
    }
  }
  final region = regionAt(p);
  if (best == null || bestD > 0.45) {
    return PinAddress('Dekat ${region.name}', region);
  }
  // About 40 house numbers per km, odd on one side and even on the other.
  final n = (bestAlong * 40).round() + 1;
  return PinAddress('${best.name} No. $n', region);
}

/// Nearest store to a point, with its distance in km.
(Store, double) nearestStore(Offset p) {
  var best = stores.first;
  var d = double.infinity;
  for (final s in stores) {
    final sd = (storePos[s.name]! - p).distance;
    if (sd < d) {
      d = sd;
      best = s;
    }
  }
  // Roads are not straight lines: add a fifth for the detour.
  return (best, d * 1.2);
}

/// Farthest a store delivers in this demo.
const deliveryRadiusKm = 5.0;

/// Minutes to deliver over [km], rounded up to 5.
int etaMinutes(double km) => (((10 + km * 4) / 5).ceil() * 5).toInt();

String kmText(double km) => '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

double clampKm(double v) => math.min(worldKm, math.max(0, v));
