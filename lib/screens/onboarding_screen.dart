import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final pages = [
      (Icons.directions_car_filled, l.t('onboard1Title'), l.t('onboard1Desc')),
      (Icons.hotel, l.t('onboard2Title'), l.t('onboard2Desc')),
      (Icons.map, l.t('onboard3Title'), l.t('onboard3Desc')),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: 3,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final (icon, title, desc) = pages[i];
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: TIColors.teal.withOpacity(.12),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: TIColors.teal, width: 1.5),
                        ),
                        child: Icon(icon, size: 64, color: TIColors.teal),
                      ),
                      const SizedBox(height: 32),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Text(desc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).hintColor,
                              height: 1.5)),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? TIColors.gold : Colors.grey.withOpacity(.4),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              if (_page < 2)
                TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const MainShell()),
                            (r) => false),
                    child: Text(l.t('skip'))),
              const Spacer(),
              FilledButton(
                  onPressed: _next,
                  child: Text(_page < 2 ? l.t('next') : l.t('start'))),
            ]),
          ),
        ]),
      ),
    );
  }
}
