import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/datasources/auth_local_datasource.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;

  // Drives the determinate progress bar across the whole boot sequence.
  late final AnimationController _progressController;

  // Rotating, engaging status copy shown under the progress bar.
  static const List<String> _messages = [
    'Warming things up...',
    'Loading the marketplace...',
    'Lining up repair services...',
    'Almost there...',
  ];
  int _messageIndex = 0;

  // Total time the branding + progress bar are guaranteed to be visible.
  static const Duration _bootDuration = Duration(milliseconds: 2400);

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));
    _scaleIn = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _entryController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: _bootDuration,
    )..addListener(_onProgressTick);
    _progressController.forward();

    _navigateWhenReady();
  }

  void _onProgressTick() {
    // Advance the status text in step with the progress bar.
    final next = (_progressController.value * _messages.length).floor().clamp(
      0,
      _messages.length - 1,
    );
    if (next != _messageIndex) {
      setState(() => _messageIndex = next);
    }
  }

  Future<void> _navigateWhenReady() async {
    // Routing is decided from LOCAL state only (token + onboarding flag), both
    // of which resolve instantly. We never block the splash on the /Auth/me
    // network call — that request keeps running in the background via
    // authNotifierProvider, and the repo + router self-correct if the token
    // turns out to be stale (it gets cleared and the user is bounced to login).
    //
    // We still hold the branding for [_bootDuration] as a *minimum* so the
    // logo doesn't flash, but there is no network-bound maximum anymore.
    // Kick off the minimum branding hold and the (instant) local token read
    // together, then await both. Neither touches the network.
    final bootDelay = Future<void>.delayed(_bootDuration);
    final token = await ref.read(tokenStorageProvider).getToken();
    await bootDelay;
    if (!mounted) return;

    final hasToken = token != null && token.isNotEmpty;

    if (hasToken) {
      // Returning user — go straight in. The background /me refreshes the
      // profile and handles an expired token without holding up the UI.
      context.go(RouteNames.home);
      return;
    }

    final seenOnboarding = await ref
        .read(authLocalDataSourceProvider)
        .hasSeenOnboarding();
    if (!mounted) return;
    // Guests browse first; login is only asked for at order / booking time.
    context.go(seenOnboarding ? RouteNames.home : RouteNames.onboarding);
  }

  @override
  void dispose() {
    _progressController.removeListener(_onProgressTick);
    _progressController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleIn,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetConstants.logoWhite,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'sabmero',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Shop. Repair. Delivered.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 56),
                // Determinate progress bar synced to the boot sequence.
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 6,
                          backgroundColor: Colors.white.withAlpha(38),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withAlpha(230),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    _messages[_messageIndex],
                    key: ValueKey<int>(_messageIndex),
                    style: TextStyle(
                      color: Colors.white.withAlpha(190),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
