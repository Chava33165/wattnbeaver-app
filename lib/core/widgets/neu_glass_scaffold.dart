import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeuGlassScaffold extends StatefulWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;

  const NeuGlassScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.appBar,
  });

  @override
  State<NeuGlassScaffold> createState() => _NeuGlassScaffoldState();
}

class _NeuGlassScaffoldState extends State<NeuGlassScaffold> with SingleTickerProviderStateMixin {
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    // Animación lenta (8s) para los orbes de fondo
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: widget.appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        children: [
          // 1. Fondo degradado base
          Container(
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.fondoModoOscuro : AppColors.fondoModoClaro,
            ),
          ),
          
          // 2. Orbes decorativos animados
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Orbe 1 (Arriba Derecha)
                  Positioned(
                    top: -50 + (20 * _orbController.value),
                    right: -50 - (20 * _orbController.value),
                    child: Opacity(
                      opacity: 0.25,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cieloMedio,
                        ),
                      ),
                    ),
                  ),
                  // Orbe 2 (Centro Izquierda)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.4 - (30 * _orbController.value),
                    left: -100 + (30 * _orbController.value),
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mentaMedio,
                        ),
                      ),
                    ),
                  ),
                  // Orbe 3 (Abajo Centro)
                  Positioned(
                    bottom: -100 + (10 * _orbController.value),
                    right: MediaQuery.of(context).size.width * 0.2,
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.lavandaMedio,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // 3. Blur global (Glassmorphism base) para difuminar los orbes
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // 4. El contenido de la app
          SafeArea(
            bottom: false,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
