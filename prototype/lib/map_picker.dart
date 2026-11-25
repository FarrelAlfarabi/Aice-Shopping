import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Text;

import 'i18n.dart';
import 'places.dart';
import 'state.dart';
import 'ui.dart';

/// DEMO address picker that works like a map app: search with live
/// suggestions, drag and zoom a drawn map under a fixed centre pin, and see
/// the address, nearest store and delivery time update. No real map service,
/// no API key and no location permission are used.
class MapPickerScreen extends StatefulWidget {
  /// Where the map opens. Defaults to the demo "my location".
  final Offset? start;
  const MapPickerScreen({super.key, this.start});
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

/// Opens the map picker. Returns the saved address, or null.
Future<String?> openMapPicker(BuildContext context) => Navigator.of(
  context,
).push<String>(MaterialPageRoute(builder: (_) => const MapPickerScreen()));

class _MapPickerScreenState extends State<MapPickerScreen>
    with SingleTickerProviderStateMixin {
  static const double _basePx = 120; // px per km at zoom 1
  static const double _minZoom = 0.7, _maxZoom = 3.2;

  late Offset center = widget.start ?? myLocation;
  double zoom = 1.4;
  bool dragging = false;
  bool showMe = false;

  final search = TextEditingController();
  final focus = FocusNode();
  String q = '';

  late final AnimationController anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  Animation<Offset>? _centerAnim;
  Animation<double>? _zoomAnim;

  // Gesture start values.
  Offset _startCenter = Offset.zero;
  Offset _startFocal = Offset.zero;
  double _startZoom = 1;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    anim.addListener(() {
      setState(() {
        center = _centerAnim!.value;
        zoom = _zoomAnim!.value;
      });
    });
    focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    anim.dispose();
    search.dispose();
    focus.dispose();
    super.dispose();
  }

  double get _scale => _basePx * zoom;

  Offset _clamp(Offset c) => Offset(clampKm(c.dx), clampKm(c.dy));

  void _flyTo(Offset to, {double? toZoom}) {
    final curve = CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic);
    _centerAnim = Tween(begin: center, end: _clamp(to)).animate(curve);
    _zoomAnim = Tween(begin: zoom, end: toZoom ?? zoom).animate(curve);
    anim.forward(from: 0);
  }

  void _pick(Place p) {
    search.text = p.name;
    focus.unfocus();
    setState(() => q = '');
    _flyTo(p.pos, toZoom: math.max(zoom, 2.2));
  }

  void _zoomBy(double f) =>
      _flyTo(center, toZoom: (zoom * f).clamp(_minZoom, _maxZoom));

  void _onScaleStart(ScaleStartDetails d) {
    anim.stop();
    focus.unfocus();
    _startCenter = center;
    _startFocal = d.localFocalPoint;
    _startZoom = zoom;
    setState(() => dragging = true);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final half = Offset(_size.width / 2, _size.height / 2);
    final startScale = _basePx * _startZoom;
    // The map point under the fingers stays under the fingers.
    final anchor = _startCenter + (_startFocal - half) / startScale;
    final z = (_startZoom * d.scale).clamp(_minZoom, _maxZoom);
    setState(() {
      zoom = z;
      center = _clamp(anchor - (d.localFocalPoint - half) / (_basePx * z));
    });
  }

  void _onScaleEnd(ScaleEndDetails d) => setState(() => dragging = false);

  void _onWheel(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      setState(() {
        zoom = (zoom * math.exp(-e.scrollDelta.dy / 400)).clamp(
          _minZoom,
          _maxZoom,
        );
      });
    }
  }

  void _myLocation() {
    setState(() => showMe = true);
    _flyTo(myLocation, toZoom: math.max(zoom, 2.2));
  }

  void _use(AppState s) {
    final a = reverseGeocode(center);
    final (store, km) = nearestStore(center);
    s.addAddress(a.full);
    s.setAddress(a.full);
    s.chooseStore(store);
    s.setDistance(km);
    Navigator.of(context).pop(a.full);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final addr = reverseGeocode(center);
    final (store, km) = nearestStore(center);
    final inRange = km <= deliveryRadiusKm;
    final hits = searchPlaces(q);
    final showHits = focus.hasFocus && q.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih lokasi')),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                _size = Size(c.maxWidth, c.maxHeight);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRect(
                        child: Listener(
                          onPointerSignal: _onWheel,
                          child: GestureDetector(
                            key: const ValueKey('map-canvas'),
                            behavior: HitTestBehavior.opaque,
                            onScaleStart: _onScaleStart,
                            onScaleUpdate: _onScaleUpdate,
                            onScaleEnd: _onScaleEnd,
                            child: Semantics(
                              label: tr(
                                'Peta contoh. Geser untuk pindah titik.',
                              ),
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _MapPainter(
                                  center: center,
                                  scale: _scale,
                                  showMe: showMe,
                                  lang: appLang,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Centre pin. It lifts while the map moves.
                    IgnorePointer(
                      child: Center(
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 150),
                          offset: Offset(0, dragging ? -0.75 : -0.5),
                          child: const Icon(
                            Icons.location_on,
                            key: ValueKey('map-pin'),
                            size: 48,
                            color: C.acc,
                            shadows: [
                              Shadow(color: Color(0x55000000), blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: dragging ? 6 : 10,
                          height: dragging ? 3 : 5,
                          decoration: BoxDecoration(
                            color: const Color(0x44000000),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                    // Map buttons.
                    Positioned(
                      right: Sp.m,
                      bottom: Sp.m,
                      child: Column(
                        children: [
                          _MapButton(
                            Icons.add,
                            'Perbesar',
                            () => _zoomBy(1.4),
                            key: const ValueKey('map-zoom-in'),
                          ),
                          const SizedBox(height: Sp.s),
                          _MapButton(
                            Icons.remove,
                            'Perkecil',
                            () => _zoomBy(1 / 1.4),
                            key: const ValueKey('map-zoom-out'),
                          ),
                          const SizedBox(height: Sp.m),
                          _MapButton(
                            Icons.my_location,
                            'Lokasi saya',
                            _myLocation,
                            key: const ValueKey('map-my-location'),
                            primary: true,
                          ),
                        ],
                      ),
                    ),
                    // Search box with live suggestions.
                    Positioned(
                      left: Sp.m,
                      right: Sp.m,
                      top: Sp.m,
                      child: Material(
                        elevation: 3,
                        shadowColor: const Color(0x33000000),
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              key: const ValueKey('map-search'),
                              controller: search,
                              focusNode: focus,
                              onChanged: (v) => setState(() => q = v),
                              onSubmitted: (_) {
                                if (hits.isNotEmpty) _pick(hits.first);
                              },
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: tr('Cari jalan, gedung atau daerah'),
                                prefixIcon: const Icon(Icons.search),
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                suffixIcon: search.text.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: tr('Hapus'),
                                        icon: const Icon(Icons.close),
                                        onPressed: () => setState(() {
                                          search.clear();
                                          q = '';
                                        }),
                                      ),
                              ),
                            ),
                            if (showHits) ...[
                              const Divider(height: 1),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: c.maxHeight * 0.55,
                                ),
                                child: hits.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(Sp.l),
                                        child: Text(
                                          'Tidak ditemukan. Coba nama jalan atau daerah.',
                                          style: tMuted,
                                        ),
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: hits.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(
                                              height: 1,
                                              indent: 52,
                                            ),
                                        itemBuilder: (_, i) => ListRow(
                                          key: ValueKey('map-hit-$i'),
                                          icon: hits[i].store
                                              ? Icons.storefront_outlined
                                              : Icons.place_outlined,
                                          title: hits[i].name,
                                          subtitle: hits[i].sub,
                                          chevron: false,
                                          onTap: () => _pick(hits[i]),
                                        ),
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Address panel.
          Material(
            color: Colors.white,
            elevation: 8,
            shadowColor: const Color(0x22000000),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.l, Sp.l, Sp.l, Sp.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.place, color: C.pri),
                        ),
                        const SizedBox(width: Sp.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addr.street,
                                key: const ValueKey('map-street'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tH3,
                              ),
                              Text(addr.area, style: tMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.m),
                    if (inRange)
                      Row(
                        key: const ValueKey('map-store'),
                        children: [
                          const Icon(Icons.storefront_outlined, color: C.muted),
                          const SizedBox(width: Sp.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Toko terdekat: ${store.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${kmText(km)} · ±${etaMinutes(km)} menit',
                                  key: const ValueKey('map-eta'),
                                  style: tMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      const Notice(
                        'Di luar area antar. Geser pin lebih dekat ke toko.',
                      ),
                    const SizedBox(height: Sp.m),
                    BigButton(
                      'Gunakan lokasi ini',
                      key: const ValueKey('map-use'),
                      onPressed: inRange ? () => _use(s) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _MapButton(
    this.icon,
    this.label,
    this.onTap, {
    super.key,
    this.primary = false,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 2,
    shadowColor: const Color(0x33000000),
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: tr(label),
      onPressed: onTap,
      icon: Icon(icon, color: primary ? C.pri : C.ink),
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
    ),
  );
}

/// Draws the demo map: kecamatan areas, parks, rivers, streets with names,
/// stores and the "my location" dot. Light and calm so the pin stands out.
class _MapPainter extends CustomPainter {
  final Offset center;
  final double scale;
  final bool showMe;
  final String lang; // repaint when the language changes
  _MapPainter({
    required this.center,
    required this.scale,
    required this.showMe,
    required this.lang,
  });

  static const _land = Color(0xFFF4F3EF);
  static const _park = Color(0xFFD9EED3);
  static const _water = Color(0xFFBFDCF2);
  static const _road = Colors.white;
  static const _casing = Color(0xFFDCDDE2);
  static const _major = Color(0xFFFFF3C9);
  static const _majorCasing = Color(0xFFE9D48C);
  static const _label = Color(0xFF6B6F80);

  @override
  void paint(Canvas canvas, Size size) {
    final half = Offset(size.width / 2, size.height / 2);
    Offset px(Offset km) => (km - center) * scale + half;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE9EAEE),
    );
    canvas.drawRect(
      Rect.fromPoints(px(Offset.zero), px(const Offset(worldKm, worldKm))),
      Paint()..color = _land,
    );

    // Small blocks: a light grid of side streets.
    final side = Paint()
      ..color = _road
      ..strokeWidth = math.max(1.2, scale * 0.018);
    if (scale > 110) {
      for (var x = 0.2; x < worldKm; x += 0.4) {
        canvas.drawLine(px(Offset(x, 0)), px(Offset(x, worldKm)), side);
      }
      for (var y = 0.2; y < worldKm; y += 0.4) {
        canvas.drawLine(px(Offset(0, y)), px(Offset(worldKm, y)), side);
      }
    }

    for (final p in parks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(px(p.topLeft), px(p.bottomRight)),
          Radius.circular(scale * 0.05),
        ),
        Paint()..color = _park,
      );
    }

    final water = Paint()
      ..color = _water
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(4, scale * 0.08);
    for (final r in rivers) {
      canvas.drawPath(_path(r, px), water);
    }

    // Kecamatan borders and names.
    final border = Paint()
      ..color = const Color(0xFFC9CBD3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final r in regions) {
      canvas.drawRect(
        Rect.fromPoints(px(r.area.topLeft), px(r.area.bottomRight)),
        border,
      );
    }

    // Roads: casing first, then fill, then names on top.
    for (final major in [false, true]) {
      for (final r in roads.where((r) => r.major == major)) {
        final w = (major ? 0.12 : 0.085) * scale;
        canvas.drawPath(
          _path(r.points, px),
          Paint()
            ..color = major ? _majorCasing : _casing
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = math.max(4, w + 2),
        );
        canvas.drawPath(
          _path(r.points, px),
          Paint()
            ..color = major ? _major : _road
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = math.max(2.5, w),
        );
      }
    }

    for (final r in regions) {
      _text(
        canvas,
        r.name.toUpperCase(),
        px(r.area.center + const Offset(0, -0.9)),
        size: 10,
        color: const Color(0xFF9A9DAA),
        weight: FontWeight.w600,
        spacing: 1.2,
      );
    }

    if (scale > 150) {
      for (final r in roads) {
        // Name on the longest segment, turned to follow it.
        var bi = 0;
        var bl = 0.0;
        for (var i = 0; i + 1 < r.points.length; i++) {
          final l = (r.points[i + 1] - r.points[i]).distance;
          if (l > bl) {
            bl = l;
            bi = i;
          }
        }
        final a = px(r.points[bi]), b = px(r.points[bi + 1]);
        var ang = math.atan2(b.dy - a.dy, b.dx - a.dx);
        if (ang > math.pi / 2) ang -= math.pi;
        if (ang < -math.pi / 2) ang += math.pi;
        _text(
          canvas,
          r.name,
          (a + b) / 2,
          size: 10.5,
          color: _label,
          angle: ang,
          halo: true,
        );
      }
    }

    // Stores.
    for (final e in storePos.entries) {
      final c = px(e.value);
      canvas.drawCircle(c, 15, Paint()..color = Colors.white);
      canvas.drawCircle(c, 12.5, Paint()..color = C.pri);
      _icon(canvas, Icons.storefront, c, 15, Colors.white);
      if (scale > 150) {
        _text(
          canvas,
          e.key,
          c + const Offset(0, 24),
          size: 11,
          color: C.priDark,
          weight: FontWeight.w600,
          halo: true,
        );
      }
    }

    if (showMe) {
      final c = px(myLocation);
      canvas.drawCircle(c, 22, Paint()..color = const Color(0x332F7DE1));
      canvas.drawCircle(c, 9, Paint()..color = Colors.white);
      canvas.drawCircle(c, 6.5, Paint()..color = const Color(0xFF2F7DE1));
    }
  }

  Path _path(List<Offset> pts, Offset Function(Offset) px) {
    final p = Path()..moveTo(px(pts.first).dx, px(pts.first).dy);
    for (final o in pts.skip(1)) {
      p.lineTo(px(o).dx, px(o).dy);
    }
    return p;
  }

  void _text(
    Canvas canvas,
    String s,
    Offset at, {
    double size = 11,
    Color color = _label,
    FontWeight weight = FontWeight.w500,
    double angle = 0,
    double spacing = 0,
    bool halo = false,
  }) {
    TextPainter tp(Paint? fg) => TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: fg == null ? color : null,
          foreground: fg,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    if (halo) {
      final h = tp(
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white,
      );
      h.paint(canvas, Offset(-h.width / 2, -h.height / 2));
    }
    final t = tp(null);
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
    canvas.restore();
  }

  void _icon(Canvas canvas, IconData icon, Offset at, double size, Color c) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: c,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.center != center ||
      old.scale != scale ||
      old.showMe != showMe ||
      old.lang != lang;
}
