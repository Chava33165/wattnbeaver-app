import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../services/storage/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: '¡Bienvenido a WattBeaver!',
      description:
          'Tu asistente IoT para monitorear y ahorrar energía y agua en tiempo real.',
      icon: Icons.home_rounded,
      gradientColors: [AppColors.crema, AppColors.mentaClaro],
      iconColor: AppColors.mentaOscuro,
    ),
    _OnboardingSlide(
      title: 'Panel de control',
      description:
          'Ve un resumen completo de tu consumo: potencia actual, flujo de agua y tus dispositivos conectados.',
      icon: Icons.dashboard_rounded,
      gradientColors: AppColors.energyGradient,
      iconColor: AppColors.mentaOscuro,
    ),
    _OnboardingSlide(
      title: 'Energía y Agua',
      description:
          'Consulta gráficas detalladas, historial por día, semana o mes, y el costo estimado de tu consumo.',
      icon: Icons.bolt,
      secondIcon: Icons.water_drop,
      gradientColors: AppColors.waterGradient,
      iconColor: AppColors.waterDark,
    ),
    _OnboardingSlide(
      title: 'Tus dispositivos',
      description:
          'Conecta sensores ESP32, revisa sus lecturas en tiempo real y gestiona todos tus dispositivos desde un solo lugar.',
      icon: Icons.devices_rounded,
      gradientColors: [AppColors.arena, AppColors.mentaMedio],
      iconColor: AppColors.mentaOscuro,
    ),
    _OnboardingSlide(
      title: 'Retos y logros',
      description:
          'Gana puntos ahorrando energía y agua, completa retos y compite con otros usuarios en el ranking.',
      icon: Icons.emoji_events_rounded,
      gradientColors: AppColors.gamificationGradient,
      iconColor: AppColors.lavandaMedio,
      isLast: true,
    ),
  ];

  Future<void> _finish() async {
    await StorageService.saveOnboardingCompleted();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // ── Slides ──
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
          ),

          // ── Botón Omitir (arriba derecha) ──
          if (!isLast)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Omitir',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // ── Indicadores + botón (abajo) ──
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _slides[_currentPage].iconColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isLast ? '¡Empezar!' : 'Siguiente',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _slides[_currentPage].iconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget de un slide ────────────────────────────────────────────────────────
class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Ícono(s)
              if (slide.secondIcon != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconCircle(slide.icon),
                    const SizedBox(width: 20),
                    _iconCircle(slide.secondIcon!),
                  ],
                )
              else
                _iconCircle(slide.icon),

              const SizedBox(height: 48),

              // Título
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.title1.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 56, color: Colors.white),
    );
  }
}

// ── Modelo de slide (inmutable, const) ───────────────────────────────────────
class _OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final IconData? secondIcon;
  final List<Color> gradientColors;
  final Color iconColor;
  final bool isLast;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    this.secondIcon,
    this.isLast = false,
  });
}
