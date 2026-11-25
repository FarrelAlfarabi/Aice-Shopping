import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'consumer_extras.dart';
import 'logo.dart';
import 'state.dart';
import 'ui.dart';

/// One slide of the welcome screen: two lines of text under the logo.
class IntroSlide {
  final String title;
  final String body;
  const IntroSlide(this.title, this.body);
}

const introSlides = [
  IntroSlide('Es krim, tetap beku.',
      'Pesan es krim favoritmu dari toko terdekat.'),
  IntroSlide('Diantar dalam kotak dingin',
      'Sampai di pintu rumah tanpa meleleh.'),
  IntroSlide('Pantau pesananmu',
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(alignment: Alignment.centerRight, child: LangChips()),
          ),
          const Expanded(
              child: Center(
                  child: FittedBox(child: BrandLogo(size: 150)))),
          SizedBox(
            height: 120,
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                const Text('Demo:', style: tMuted),
                SmallChip('Konsumen',
                    key: const ValueKey('role-consumer'),
                    on: s.role == AppRole.consumer,
                    onTap: () => s.setRole(AppRole.consumer)),
                SmallChip('Admin',
                    key: const ValueKey('role-admin'),
                    on: s.role == AppRole.admin,
                    onTap: () => s.setRole(AppRole.admin)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
