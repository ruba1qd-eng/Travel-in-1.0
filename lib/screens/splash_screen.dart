import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'auth_screens.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
        ..forward();
  late final Animation<double> _scale =
      CurvedAnimation(parent: _c, curve: const Interval(0, .55, curve: Curves.easeOutBack));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: const Interval(.25, .75));

  late final AnimationController _car =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..repeat(reverse: true);

  late final AnimationController _glow =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..repeat(reverse: true);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), _go);
  }

  void _go() {
    if (!mounted) return;
    final user = context.read<AppState>().user;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => user == null
          ? const UserTypeScreen()
          : (user.role == 'developer'
              ? const DeveloperLoginScreen()
              : const OnboardingScreen()),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    _car.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TIColors.navy, TIColors.navyDark],
          ),
        ),
        child: SafeArea(
          child: Stack(children: [
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // الشعار مع توهج نابض
                AnimatedBuilder(
                  animation: _glow,
                  builder: (_, child) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: TIColors.gold
                              .withOpacity(.25 + .2 * _glow.value),
                          blurRadius: 60,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF12305E), Color(0xFF0A1F44)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: TIColors.gold, width: 2),
                      ),
                      child: const Icon(Icons.flight_takeoff,
                          size: 60, color: TIColors.gold),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'Travel In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    l.t('tagline2'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(.85),
                      fontSize: 16,
                      letterSpacing: .5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // سيارة متحركة على خط الطريق
                ClipRect(
                  child: SizedBox(
                    width: 230,
                    height: 46,
                    child: AnimatedBuilder(
                      animation: _car,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(-120 + 240 * _car.value, 0),
                        child: child,
                      ),
                      child: const Icon(Icons.directions_car_filled,
                          color: TIColors.teal, size: 36),
                    ),
                  ),
                ),
                Container(
                    width: 230,
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.white24,
                        TIColors.gold.withOpacity(.6),
                        Colors.white24,
                      ]),
                    )),
              ]),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(children: [
                const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                        color: TIColors.gold, strokeWidth: 2.5)),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: _go,
                    child: Text(l.t('skip'),
                        style: const TextStyle(color: Colors.white70))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
