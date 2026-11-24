import 'package:flutter/material.dart';
import 'state.dart';
import 'ui.dart';

/// One slide of the welcome screen: a drawn placeholder plus two lines of text.
class IntroSlide {
  final IconData icon;
  final IconData badge;
  final String title;
  final String body;
  const IntroSlide(this.icon, this.badge, this.title, this.body);
}

const introSlides = [
  IntroSlide(Icons.icecream, Icons.ac_unit, 'Es krim, tetap beku.',
      'Pesan es krim favoritmu dari toko terdekat.'),
  IntroSlide(Icons.local_shipping_outlined, Icons.ac_unit,
      'Diantar dalam kotak dingin', 'Sampai di pintu rumah tanpa meleleh.'),
  IntroSlide(Icons.location_on_outlined, Icons.check, 'Pantau pesananmu',
      'Lihat posisi pesanan dari toko sampai tiba.'),
];

/// First-launch welcome screen. Shows before onboarding (address and store).
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final controller = PageController();
  int page = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: introSlides.length,
              onPageChanged: (i) => setState(() => page = i),
              itemBuilder: (_, i) => _SlideView(introSlides[i]),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < introSlides.length; i++)
              AnimatedContainer(
                key: ValueKey('intro-dot-$i'),
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == page ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                    color: i == page ? C.pri : C.line,
                    borderRadius: BorderRadius.circular(4)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: BigButton('Mulai', onPressed: s.finishIntro),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text(footerText, style: tMuted),
          ),
        ]),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final IntroSlide slide;
  const _SlideView(this.slide);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Drawn placeholder brand mark, no real logo.
          SizedBox(
            width: 190,
            height: 190,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                  decoration:
                      const BoxDecoration(color: C.tint, shape: BoxShape.circle)),
              Container(
                width: 130,
                height: 130,
                decoration:
                    const BoxDecoration(color: C.pri, shape: BoxShape.circle),
                child: Icon(slide.icon, size: 68, color: Colors.white),
              ),
              Positioned(
                right: 16,
                bottom: 22,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: C.acc,
                      shape: BoxShape.circle,
                      border: Border.all(color: C.bg, width: 3)),
                  child: Icon(slide.badge, size: 24, color: C.accInk),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 32),
          Text(slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: C.ink)),
          const SizedBox(height: 10),
          Text(slide.body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: C.muted, height: 1.4)),
        ]),
      );
}
